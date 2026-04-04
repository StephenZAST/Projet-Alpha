import 'package:dio/dio.dart';
import '../constants.dart';

/// 🏥 Service de vérification de la santé du backend
/// 
/// Utilisé pour:
/// - Vérifier la disponibilité du backend avant les requêtes critiques
/// - Gérer le démarrage à froid de Render (plan gratuit)
/// - Implémenter un retry avec backoff exponentiel

class BackendHealthCheck {
  static final BackendHealthCheck _instance = BackendHealthCheck._internal();
  factory BackendHealthCheck() => _instance;
  BackendHealthCheck._internal();

  late Dio _dio;
  bool _isHealthy = false;
  DateTime? _lastHealthCheck;

  /// Initialiser le service
  Future<void> initialize() async {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.getBaseUrl(),
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      sendTimeout: const Duration(seconds: 5),
    ));
  }

  /// Vérifier la santé du backend avec retry intelligent
  /// Utilise backoff exponentiel pour gérer le démarrage à froid
  Future<bool> checkHealth({int maxRetries = 5}) async {
    print('🏥 [HealthCheck] Vérification de la santé du backend...');
    
    // Cache: si on a vérifié il y a moins de 30 secondes, utiliser le cache
    if (_lastHealthCheck != null && 
        DateTime.now().difference(_lastHealthCheck!).inSeconds < 30) {
      print('🏥 [HealthCheck] Utilisation du cache: $_isHealthy');
      return _isHealthy;
    }

    for (int i = 0; i < maxRetries; i++) {
      try {
        print('🏥 [HealthCheck] Tentative ${i + 1}/$maxRetries...');
        
        final response = await _dio.get('/health').timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw DioException(
            requestOptions: RequestOptions(path: '/health'),
            type: DioExceptionType.receiveTimeout,
          ),
        );

        if (response.statusCode == 200) {
          _isHealthy = true;
          _lastHealthCheck = DateTime.now();
          print('✅ [HealthCheck] Backend est SAIN et disponible');
          return true;
        }
      } on DioException catch (e) {
        print('⚠️  [HealthCheck] Tentative ${i + 1} échouée: ${e.type}');
        
        // Backoff exponentiel: 1s, 2s, 4s, 8s, 16s
        if (i < maxRetries - 1) {
          final delaySeconds = 1 << i; // 2^i
          print('⏳ [HealthCheck] Attente de ${delaySeconds}s avant nouvelle tentative...');
          await Future.delayed(Duration(seconds: delaySeconds));
        }
      } catch (e) {
        print('❌ [HealthCheck] Erreur inattendue: $e');
        
        if (i < maxRetries - 1) {
          final delaySeconds = 1 << i;
          await Future.delayed(Duration(seconds: delaySeconds));
        }
      }
    }

    _isHealthy = false;
    _lastHealthCheck = DateTime.now();
    print('❌ [HealthCheck] Backend est NON disponible après $maxRetries tentatives');
    return false;
  }

  /// Attendre que le backend soit disponible (bloquant)
  Future<bool> waitForBackend({int maxWaitSeconds = 60}) async {
    print('⏳ [HealthCheck] Attente du backend (max ${maxWaitSeconds}s)...');
    
    final startTime = DateTime.now();
    while (DateTime.now().difference(startTime).inSeconds < maxWaitSeconds) {
      final isHealthy = await checkHealth(maxRetries: 3);
      if (isHealthy) {
        return true;
      }
      await Future.delayed(const Duration(seconds: 2));
    }

    print('❌ [HealthCheck] Timeout: backend n\'est pas devenu disponible');
    return false;
  }

  /// Getter pour l'état actuel
  bool get isHealthy => _isHealthy;

  /// Réinitialiser le cache
  void resetCache() {
    _lastHealthCheck = null;
    _isHealthy = false;
  }
}

/// 🚀 Service de pré-chauffage du backend
/// Appelé au démarrage de l'application pour préparer le backend
class BackendWarmupService {
  static final BackendWarmupService _instance = 
      BackendWarmupService._internal();
  factory BackendWarmupService() => _instance;
  BackendWarmupService._internal();

  /// Pré-chauffer le backend lors du démarrage
  /// Utile pour Render plan gratuit avec démarrage à froid
  Future<void> warmupBackend() async {
    print('🔥 [Warmup] Démarrage du pré-chauffage du backend...');
    
    try {
      final healthCheck = BackendHealthCheck();
      final isHealthy = await healthCheck.checkHealth(maxRetries: 3);
      
      if (isHealthy) {
        print('🔥 [Warmup] Backend pré-chauffé avec succès');
        return;
      }

      print('🔥 [Warmup] Backend pas disponible, attente...');
      await healthCheck.waitForBackend(maxWaitSeconds: 45);
      print('🔥 [Warmup] Pré-chauffage terminé');
    } catch (e) {
      print('🔥 [Warmup] Erreur lors du pré-chauffage: $e');
      // Le pré-chauffage n'est pas critique, continuer
    }
  }
}
