import 'package:delivery_app/services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as getx;
import 'package:get_storage/get_storage.dart';

import '../constants.dart';

/// 🌐 Service API - Alpha Delivery App
///
/// Service centralisé pour toutes les communications avec le backend.
/// Gère l'authentification, les intercepteurs, et les erreurs.
class ApiService extends getx.GetxService {
  // ==========================================================================
  // 📦 PROPRIÉTÉS
  // ==========================================================================

  late final Dio _dio;
  String? _authToken;
  bool _isRefreshing = false;

  // ==========================================================================
  // 🚀 INITIALISATION
  // ==========================================================================

  @override
  Future<void> onInit() async {
    super.onInit();
    debugPrint('🌐 Initialisation ApiService...');

    _initializeDio();
    _setupInterceptors();

    debugPrint('✅ ApiService initialisé');
  }

  /// Initialise Dio avec la configuration de base
  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: ApiConfig.defaultHeaders,
      validateStatus: (status) {
        // Considère les codes 200-299 comme succès
        return status != null && status >= 200 && status < 300;
      },
    ));
  }

  /// Configure les intercepteurs Dio
  void _setupInterceptors() {
    // Intercepteur de requête
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        debugPrint('🚀 ${options.method} ${options.path}');

        // Toujours tenter d'attacher un token à chaque requête (hot-reload safe)
        final token = _getToken();
        if (token != null && (options.headers['Authorization'] == null)) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // Log des données de requête en mode debug
        if (options.data != null) {
          debugPrint('📤 Data: ${options.data}');
        }

        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('✅ ${response.statusCode} ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (error, handler) async {
        debugPrint(
            '❌ ${error.response?.statusCode} ${error.requestOptions.path}');
        debugPrint('❌ Error: ${error.message}');

        // Gestion spécifique des erreurs d'authentification avec auto-retry sécurisé
        if (error.response?.statusCode == 401) {
          final req = error.requestOptions;
          final alreadyRetried = req.extra['retried'] == true;
          final hadAuthHeader = req.headers['Authorization'] != null;

          // 1) Si pas d'en-tête Authorization (ex: hot reload), essayer d'en ajouter un et retenter
          if (!alreadyRetried && !hadAuthHeader) {
            final token = _getToken();
            if (token != null) {
              try {
                req.headers['Authorization'] = 'Bearer $token';
                final resp = await _retryRequest(req);
                return handler.resolve(resp);
              } catch (_) {
                // fallback vers gestion standard
              }
            }
          }

          // 2) Si on avait un token mais expiré, tenter refreshToken une fois puis retenter
          if (!alreadyRetried && hadAuthHeader) {
            try {
              final auth = getx.Get.find<AuthService>();
              if (!_isRefreshing) {
                _isRefreshing = true;
                final ok = await auth.refreshToken();
                _isRefreshing = false;
                if (ok) {
                  final newToken = _getToken();
                  if (newToken != null) {
                    req.headers['Authorization'] = 'Bearer $newToken';
                    try {
                      final resp = await _retryRequest(req);
                      return handler.resolve(resp);
                    } catch (_) {}
                  }
                }
              }
            } catch (_) {
              // AuthService pas dispo, continuer
            } finally {
              _isRefreshing = false;
            }
          }

          // 3) Sinon, déconnecter l'utilisateur (comportement existant)
          _handleUnauthorized();
        }

        handler.next(error);
      },
    ));

    // Intercepteur de logs détaillés (en mode debug uniquement)
    if (getx.Get.isLogEnable) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
        error: true,
        logPrint: (object) => debugPrint('🌐 [Dio] $object'),
      ));
    }
  }

  /// Récupère le token depuis la mémoire, le service, ou le stockage local
  String? _getToken() {
    if (_authToken != null && _authToken!.isNotEmpty) return _authToken;
    try {
      final auth = getx.Get.isRegistered<AuthService>()
          ? getx.Get.find<AuthService>()
          : null;
      final fromService = auth?.token;
      if (fromService != null && fromService.isNotEmpty) {
        _authToken = fromService; // garder en mémoire pour vitesse
        return fromService;
      }
    } catch (_) {
      // Ignorer si le service n'est pas encore enregistré
    }

    try {
      final box = GetStorage();
      final fromStorage = box.read<String>(StorageKeys.authToken);
      if (fromStorage != null && fromStorage.isNotEmpty) {
        _authToken = fromStorage; // rehydratation post hot-reload
        return fromStorage;
      }
    } catch (_) {}

    return null;
  }

  /// Retente une requête une seule fois en marquant l'option "retried"
  Future<Response<dynamic>> _retryRequest(RequestOptions req) async {
    final options = Options(
      method: req.method,
      headers: {
        ...req.headers,
      },
      responseType: req.responseType,
      contentType: req.contentType,
      followRedirects: req.followRedirects,
      validateStatus: req.validateStatus,
      receiveDataWhenStatusError: req.receiveDataWhenStatusError,
      extra: {
        ...req.extra,
        'retried': true,
      },
    );

    return _dio.request(
      req.path,
      data: req.data,
      queryParameters: req.queryParameters,
      options: options,
      cancelToken: req.cancelToken,
      onReceiveProgress: req.onReceiveProgress,
      onSendProgress: req.onSendProgress,
    );
  }

  // ==========================================================================
  // 🔑 GESTION DE L'AUTHENTIFICATION
  // ==========================================================================

  /// Définit le token d'authentification
  void setAuthToken(String token) {
    _authToken = token;
    debugPrint('🔑 Token d\'authentification configuré');
  }

  /// Efface le token d'authentification
  void clearAuthToken() {
    _authToken = null;
    debugPrint('🔑 Token d\'authentification effacé');
  }

  /// Gère les erreurs 401 (non autorisé)
  void _handleUnauthorized() {
    debugPrint('🚨 Erreur 401: Token expiré ou invalide');

    // Notifie AuthService pour déconnecter l'utilisateur
    try {
      final authService = getx.Get.find<AuthService>();
      // Vérifier si l'utilisateur est encore connecté avant de déclencher logout
      if (authService.isAuthenticated) {
        authService.logout();
      } else {
        debugPrint('⚠️ Utilisateur déjà déconnecté, pas de logout nécessaire');
      }
    } catch (e) {
      debugPrint('⚠️ Impossible de notifier AuthService: $e');
    }
  }

  // ==========================================================================
  // 🌐 MÉTHODES HTTP
  // ==========================================================================

  /// Requête GET
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Requête POST
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Requête PUT
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Requête PATCH
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Requête DELETE
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==========================================================================
  // 📁 UPLOAD DE FICHIERS
  // ==========================================================================

  /// Upload d'un fichier
  Future<Response> uploadFile(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?data,
      });

      return await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==========================================================================
  // 📥 TÉLÉCHARGEMENT DE FICHIERS
  // ==========================================================================

  /// Télécharge un fichier
  Future<Response> downloadFile(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==========================================================================
  // ❌ GESTION DES ERREURS
  // ==========================================================================

  /// Gère et transforme les erreurs Dio
  ApiException _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return ApiException(
            message: 'Délai de connexion dépassé',
            type: ApiExceptionType.timeout,
            statusCode: null,
          );

        case DioExceptionType.sendTimeout:
          return ApiException(
            message: 'Délai d\'envoi dépassé',
            type: ApiExceptionType.timeout,
            statusCode: null,
          );

        case DioExceptionType.receiveTimeout:
          return ApiException(
            message: 'Délai de réception dépassé',
            type: ApiExceptionType.timeout,
            statusCode: null,
          );

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = _getErrorMessage(error.response?.data);

          return ApiException(
            message: message,
            type: _getExceptionType(statusCode),
            statusCode: statusCode,
            data: error.response?.data,
          );

        case DioExceptionType.cancel:
          return ApiException(
            message: 'Requête annulée',
            type: ApiExceptionType.cancelled,
            statusCode: null,
          );

        case DioExceptionType.connectionError:
          return ApiException(
            message: 'Erreur de connexion au serveur',
            type: ApiExceptionType.network,
            statusCode: null,
          );

        default:
          return ApiException(
            message: 'Erreur inconnue: ${error.message}',
            type: ApiExceptionType.unknown,
            statusCode: null,
          );
      }
    }

    return ApiException(
      message: 'Erreur inattendue: $error',
      type: ApiExceptionType.unknown,
      statusCode: null,
    );
  }

  /// Extrait le message d'erreur de la réponse
  String _getErrorMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData['message'] ??
          responseData['error'] ??
          'Erreur du serveur';
    }
    return 'Erreur du serveur';
  }

  /// Détermine le type d'exception selon le code de statut
  ApiExceptionType _getExceptionType(int? statusCode) {
    if (statusCode == null) return ApiExceptionType.unknown;

    if (statusCode >= 400 && statusCode < 500) {
      switch (statusCode) {
        case 401:
          return ApiExceptionType.unauthorized;
        case 403:
          return ApiExceptionType.forbidden;
        case 404:
          return ApiExceptionType.notFound;
        case 422:
          return ApiExceptionType.validation;
        default:
          return ApiExceptionType.badRequest;
      }
    } else if (statusCode >= 500) {
      return ApiExceptionType.serverError;
    }

    return ApiExceptionType.unknown;
  }
}

/// 🚨 Exception API personnalisée
class ApiException implements Exception {
  final String message;
  final ApiExceptionType type;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    required this.type,
    this.statusCode,
    this.data,
  });

  @override
  String toString() {
    return 'ApiException: $message (${statusCode ?? 'N/A'})';
  }

  /// Vérifie si c'est une erreur de validation
  bool get isValidationError => type == ApiExceptionType.validation;

  /// Vérifie si c'est une erreur d'authentification
  bool get isAuthError => type == ApiExceptionType.unauthorized;

  /// Vérifie si c'est une erreur réseau
  bool get isNetworkError => type == ApiExceptionType.network;

  /// Obtient les erreurs de validation si disponibles
  Map<String, List<String>>? get validationErrors {
    if (isValidationError && data is Map<String, dynamic>) {
      final errors = data['errors'] as Map<String, dynamic>?;
      if (errors != null) {
        return errors.map((key, value) => MapEntry(
              key,
              (value as List).map((e) => e.toString()).toList(),
            ));
      }
    }
    return null;
  }
}

/// 🏷️ Types d'exceptions API
enum ApiExceptionType {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  badRequest,
  validation,
  serverError,
  cancelled,
  unknown,
}
