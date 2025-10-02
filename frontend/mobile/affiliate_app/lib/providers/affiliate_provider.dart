import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/affiliate_profile.dart';
import '../services/affiliate_service.dart';
import '../services/api_service.dart';

/// 💼 Provider Affilié - Alpha Affiliate App
///
/// Provider principal pour la gestion de l'état affilié avec toutes les
/// fonctionnalités : profil, commissions, retraits, filleuls, niveaux

class AffiliateProvider extends ChangeNotifier {
  final AffiliateService _affiliateService = AffiliateService();

  // État du profil
  AffiliateProfile? _profile;
  bool _isLoadingProfile = false;
  String? _profileError;

  // État des commissions
  List<CommissionTransaction> _commissions = [];
  bool _isLoadingCommissions = false;
  String? _commissionsError;
  PaginationInfo? _commissionsPagination;
  int _currentCommissionsPage = 1;

  // État des filleuls
  List<AffiliateReferral> _referrals = [];
  bool _isLoadingReferrals = false;
  String? _referralsError;

  // État des niveaux
  List<AffiliateLevel> _levels = [];
  AffiliateLevel? _currentLevel;
  bool _isLoadingLevels = false;
  String? _levelsError;

  // État des retraits
  bool _isRequestingWithdrawal = false;
  String? _withdrawalError;

  // État de génération de code
  bool _isGeneratingCode = false;
  String? _generatedCode;
  String? _codeError;

  // Getters
  AffiliateProfile? get profile => _profile;
  bool get isLoadingProfile => _isLoadingProfile;
  String? get profileError => _profileError;

  List<CommissionTransaction> get commissions => _commissions;
  bool get isLoadingCommissions => _isLoadingCommissions;
  String? get commissionsError => _commissionsError;
  PaginationInfo? get commissionsPagination => _commissionsPagination;
  bool get hasMoreCommissions => _commissionsPagination?.hasNextPage ?? false;

  List<AffiliateReferral> get referrals => _referrals;
  bool get isLoadingReferrals => _isLoadingReferrals;
  String? get referralsError => _referralsError;

  List<AffiliateLevel> get levels => _levels;
  AffiliateLevel? get currentLevel => _currentLevel;
  bool get isLoadingLevels => _isLoadingLevels;
  String? get levelsError => _levelsError;

  bool get isRequestingWithdrawal => _isRequestingWithdrawal;
  String? get withdrawalError => _withdrawalError;

  bool get isGeneratingCode => _isGeneratingCode;
  String? get generatedCode => _generatedCode;
  String? get codeError => _codeError;

  // Getters calculés
  bool get isAuthenticated => _profile != null;
  bool get canWithdraw => _profile?.canWithdraw ?? false;
  double get availableBalance => _profile?.commissionBalance ?? 0.0;
  int get totalReferrals => _profile?.totalReferrals ?? 0;
  double get totalEarnings => _profile?.totalEarned ?? 0.0;
  String get affiliateCode => _profile?.affiliateCode ?? '';
  String get currentLevelName => _profile?.levelName ?? 'Bronze';

  /// 🚀 Initialiser le provider
  Future<void> initialize() async {
    await loadProfile();
    if (_profile != null) {
      await Future.wait([
        loadCommissions(),
        loadReferrals(),
        loadLevels(),
      ]);
    }
  }

  /// 👤 Charger le profil affilié
  Future<void> loadProfile() async {
    _isLoadingProfile = true;
    _profileError = null;
    notifyListeners();

    final response = await _affiliateService.getProfile();
    
    response.onSuccess((profile) {
      _profile = profile;
      _profileError = null;
    });

    response.onError((error) {
      _profileError = error.message;
      _profile = null;
    });

    _isLoadingProfile = false;
    notifyListeners();
  }

  /// 👤 Mettre à jour le profil
  Future<bool> updateProfile({
    String? phone,
    Map<String, dynamic>? notificationPreferences,
  }) async {
    if (_profile == null) return false;

    _isLoadingProfile = true;
    _profileError = null;
    notifyListeners();

    final response = await _affiliateService.updateProfile(
      phone: phone,
      notificationPreferences: notificationPreferences,
    );

    bool success = false;
    response.onSuccess((profile) {
      _profile = profile;
      _profileError = null;
      success = true;
    });

    response.onError((error) {
      _profileError = error.message;
    });

    _isLoadingProfile = false;
    notifyListeners();
    return success;
  }

  /// 💰 Charger les commissions
  Future<void> loadCommissions({bool refresh = false}) async {
    if (refresh) {
      _currentCommissionsPage = 1;
      _commissions.clear();
    }

    _isLoadingCommissions = true;
    _commissionsError = null;
    notifyListeners();

    final response = await _affiliateService.getCommissions(
      page: _currentCommissionsPage,
      limit: 20,
    );

    response.onSuccess((paginatedCommissions) {
      if (refresh) {
        _commissions = paginatedCommissions.data;
      } else {
        _commissions.addAll(paginatedCommissions.data);
      }
      _commissionsPagination = paginatedCommissions.pagination;
      _commissionsError = null;
    });

    response.onError((error) {
      _commissionsError = error.message;
    });

    _isLoadingCommissions = false;
    notifyListeners();
  }

  /// 💰 Charger plus de commissions
  Future<void> loadMoreCommissions() async {
    if (!hasMoreCommissions || _isLoadingCommissions) return;

    _currentCommissionsPage++;
    await loadCommissions();
  }

  /// 💸 Demander un retrait
  Future<bool> requestWithdrawal(double amount) async {
    if (!canWithdraw || amount < AffiliateConfig.minWithdrawalAmount) {
      return false;
    }

    _isRequestingWithdrawal = true;
    _withdrawalError = null;
    notifyListeners();

    final response = await _affiliateService.requestWithdrawal(amount: amount);

    bool success = false;
    response.onSuccess((transaction) {
      // Mettre à jour le solde local
      if (_profile != null) {
        _profile = _profile!.copyWith(
          commissionBalance: _profile!.commissionBalance - amount,
        );
      }
      
      // Ajouter la transaction à la liste
      _commissions.insert(0, transaction);
      
      _withdrawalError = null;
      success = true;
    });

    response.onError((error) {
      _withdrawalError = error.message;
    });

    _isRequestingWithdrawal = false;
    notifyListeners();
    return success;
  }

  /// 👥 Charger les filleuls
  Future<void> loadReferrals() async {
    _isLoadingReferrals = true;
    _referralsError = null;
    notifyListeners();

    final response = await _affiliateService.getReferrals();

    response.onSuccess((referrals) {
      _referrals = referrals;
      _referralsError = null;
    });

    response.onError((error) {
      _referralsError = error.message;
    });

    _isLoadingReferrals = false;
    notifyListeners();
  }

  /// 🎯 Charger les niveaux
  Future<void> loadLevels() async {
    _isLoadingLevels = true;
    _levelsError = null;
    notifyListeners();

    final levelsResponse = await _affiliateService.getLevels();
    final currentLevelResponse = await _affiliateService.getCurrentLevel();

    levelsResponse.onSuccess((response) {
      _levels = response.levels;
    });

    levelsResponse.onError((error) {
      _levelsError = error.message;
    });

    currentLevelResponse.onSuccess((level) {
      _currentLevel = level;
    });

    _isLoadingLevels = false;
    notifyListeners();
  }

  /// 🔗 Générer un nouveau code affilié
  Future<bool> generateNewCode() async {
    _isGeneratingCode = true;
    _codeError = null;
    _generatedCode = null;
    notifyListeners();

    final response = await _affiliateService.generateAffiliateCode();

    bool success = false;
    response.onSuccess((code) {
      _generatedCode = code;
      
      // Mettre à jour le profil avec le nouveau code
      if (_profile != null) {
        _profile = _profile!.copyWith(affiliateCode: code);
      }
      
      _codeError = null;
      success = true;
    });

    response.onError((error) {
      _codeError = error.message;
    });

    _isGeneratingCode = false;
    notifyListeners();
    return success;
  }

  /// 🔄 Actualiser toutes les données
  Future<void> refreshAll() async {
    await Future.wait([
      loadProfile(),
      loadCommissions(refresh: true),
      loadReferrals(),
      loadLevels(),
    ]);
  }

  /// 🧹 Nettoyer les erreurs
  void clearErrors() {
    _profileError = null;
    _commissionsError = null;
    _referralsError = null;
    _levelsError = null;
    _withdrawalError = null;
    _codeError = null;
    notifyListeners();
  }

  /// 🚪 Déconnexion
  void logout() {
    _profile = null;
    _commissions.clear();
    _referrals.clear();
    _levels.clear();
    _currentLevel = null;
    _generatedCode = null;
    
    clearErrors();
    
    // Nettoyer le token d'authentification
    ApiService().clearAuthToken();
    
    notifyListeners();
  }

  /// 📊 Statistiques calculées
  Map<String, dynamic> get dashboardStats {
    return {
      'totalEarnings': totalEarnings,
      'availableBalance': availableBalance,
      'monthlyEarnings': _profile?.monthlyEarnings ?? 0.0,
      'totalReferrals': totalReferrals,
      'currentLevel': currentLevelName,
      'commissionRate': _profile?.commissionRate ?? 0.0,
      'recentTransactions': _commissions.take(5).toList(),
    };
  }

  /// 🎯 Progression vers le niveau suivant
  Map<String, dynamic>? get nextLevelProgress {
    if (_currentLevel == null || _levels.isEmpty) return null;

    final currentIndex = _levels.indexWhere((l) => l.id == _currentLevel!.id);
    if (currentIndex == -1 || currentIndex >= _levels.length - 1) return null;

    final nextLevel = _levels[currentIndex + 1];
    final currentEarnings = totalEarnings;
    final requiredEarnings = nextLevel.minEarnings;
    final progress = currentEarnings / requiredEarnings;

    return {
      'nextLevel': nextLevel,
      'currentEarnings': currentEarnings,
      'requiredEarnings': requiredEarnings,
      'remainingEarnings': requiredEarnings - currentEarnings,
      'progress': progress.clamp(0.0, 1.0),
      'isMaxLevel': false,
    };
  }

  /// 📈 Filtrer les commissions par type
  List<CommissionTransaction> getCommissionsByType({bool withdrawalsOnly = false}) {
    return _commissions.where((transaction) {
      return withdrawalsOnly ? transaction.isWithdrawal : transaction.isCommission;
    }).toList();
  }

  /// 📅 Filtrer les commissions par période
  List<CommissionTransaction> getCommissionsByPeriod(DateTime startDate, DateTime endDate) {
    return _commissions.where((transaction) {
      return transaction.createdAt.isAfter(startDate) && 
             transaction.createdAt.isBefore(endDate);
    }).toList();
  }
}