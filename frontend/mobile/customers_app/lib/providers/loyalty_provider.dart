import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/models/loyalty.dart';

/// 🎁 Provider Fidélité - Alpha Client App
///
/// Provider pour la gestion du programme de fidélité avec points,
/// récompenses, historique des transactions et système de cache optimisé.

class LoyaltyProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // État des points
  LoyaltyPoints? _loyaltyPoints;
  bool _isLoadingPoints = false;
  String? _pointsError;

  // État des récompenses
  List<Reward> _rewards = [];
  bool _isLoadingRewards = false;
  String? _rewardsError;

  // État des transactions
  List<PointTransaction> _transactions = [];
  bool _isLoadingTransactions = false;
  String? _transactionsError;
  int _currentTransactionsPage = 1;
  bool _hasMoreTransactions = true;

  // État d'utilisation des points
  bool _isUsingPoints = false;
  String? _usePointsError;

  // 🔥 Cache Management
  DateTime? _lastFetch;
  bool _isInitialized = false;
  static const Duration _cacheDuration = Duration(minutes: 5); // 5 min (données dynamiques)

  // Getters
  LoyaltyPoints? get loyaltyPoints => _loyaltyPoints;
  bool get isLoadingPoints => _isLoadingPoints;
  String? get pointsError => _pointsError;

  List<Reward> get rewards => _rewards;
  bool get isLoadingRewards => _isLoadingRewards;
  String? get rewardsError => _rewardsError;

  List<PointTransaction> get transactions => _transactions;
  bool get isLoadingTransactions => _isLoadingTransactions;
  String? get transactionsError => _transactionsError;
  bool get hasMoreTransactions => _hasMoreTransactions;

  bool get isUsingPoints => _isUsingPoints;
  String? get usePointsError => _usePointsError;

  // Getters calculés
  int get currentPoints => _loyaltyPoints?.pointsBalance ?? 0;
  int get totalEarned => _loyaltyPoints?.totalEarned ?? 0;
  bool get hasPoints => currentPoints > 0;

  // 🔥 Cache Getters
  bool get isInitialized => _isInitialized;
  DateTime? get lastFetch => _lastFetch;
  
  bool get _shouldRefresh {
    if (_lastFetch == null) return true;
    final difference = DateTime.now().difference(_lastFetch!);
    return difference > _cacheDuration;
  }
  
  String get cacheStatus {
    if (_lastFetch == null) return 'Aucune donnée';
    final difference = DateTime.now().difference(_lastFetch!);
    final minutes = difference.inMinutes;
    if (minutes < 1) return 'À l\'instant';
    if (minutes == 1) return 'Il y a 1 minute';
    return 'Il y a $minutes minutes';
  }

  // Récompenses disponibles (que l'utilisateur peut s'offrir)
  List<Reward> get availableRewards => _rewards
      .where(
          (reward) => reward.isActive && reward.pointsRequired <= currentPoints)
      .toList();

  /// 🚀 Initialiser le provider avec système de cache
  Future<void> initialize({bool forceRefresh = false}) async {
    // 🔥 Vérifier le cache avant de charger
    if (_isInitialized && !forceRefresh && !_shouldRefresh && _loyaltyPoints != null) {
      debugPrint('✅ [LoyaltyProvider] Cache valide - Pas de rechargement');
      debugPrint('📊 [LoyaltyProvider] Dernière mise à jour: $cacheStatus');
      debugPrint('🎁 [LoyaltyProvider] $currentPoints points, ${_rewards.length} récompenses');
      return;
    }

    if (forceRefresh) {
      debugPrint('🔄 [LoyaltyProvider] Rechargement forcé');
    } else if (_shouldRefresh) {
      debugPrint('⏰ [LoyaltyProvider] Cache expiré - Rechargement');
    } else {
      debugPrint('🆕 [LoyaltyProvider] Première initialisation');
    }

    try {
      final startTime = DateTime.now();
      
      await Future.wait([
        loadLoyaltyPoints(),
        loadRewards(),
        loadTransactions(refresh: true),
      ]);
      
      // 🔥 Marquer comme initialisé
      _isInitialized = true;
      _lastFetch = DateTime.now();
      
      final duration = DateTime.now().difference(startTime);
      debugPrint('✅ [LoyaltyProvider] Chargement terminé en ${duration.inMilliseconds}ms');
      debugPrint('🎁 [LoyaltyProvider] $currentPoints points, ${_rewards.length} récompenses, ${_transactions.length} transactions');
      
    } catch (e) {
      debugPrint('❌ [LoyaltyProvider] Erreur: $e');
    }
  }

  /// 💰 Charger les points de fidélité
  Future<void> loadLoyaltyPoints() async {
    _isLoadingPoints = true;
    _pointsError = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/loyalty/points-balance');

      if (response['success'] == true && response['data'] != null) {
        _loyaltyPoints = LoyaltyPoints.fromJson(response['data']);
        _pointsError = null;
      } else {
        _pointsError = 'Erreur lors du chargement des points';
      }
    } catch (e) {
      _pointsError = 'Erreur de connexion: $e';
      print('Erreur loadLoyaltyPoints: $e');
    }

    _isLoadingPoints = false;
    notifyListeners();
  }

  /// 🎁 Charger les récompenses disponibles
  Future<void> loadRewards() async {
    _isLoadingRewards = true;
    _rewardsError = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/loyalty/admin/rewards');

      if (response['success'] == true && response['data'] != null) {
        final rewardsData = response['data']['data'] as List;
        _rewards = rewardsData
            .map((json) => Reward.fromJson(json))
            .where(
                (reward) => reward.isActive) // Filtrer les récompenses actives
            .toList();
        _rewardsError = null;
      } else {
        _rewardsError = 'Erreur lors du chargement des récompenses';
      }
    } catch (e) {
      _rewardsError = 'Erreur de connexion: $e';
      print('Erreur loadRewards: $e');
    }

    _isLoadingRewards = false;
    notifyListeners();
  }

  /// 📋 Charger l'historique des transactions
  Future<void> loadTransactions({bool refresh = false}) async {
    if (refresh) {
      _currentTransactionsPage = 1;
      _transactions.clear();
      _hasMoreTransactions = true;
    }

    if (!_hasMoreTransactions && !refresh) return;

    _isLoadingTransactions = true;
    _transactionsError = null;
    notifyListeners();

    try {
      final userId = _loyaltyPoints?.userId;
      if (userId == null) {
        _transactionsError = 'Utilisateur non identifié';
        _isLoadingTransactions = false;
        notifyListeners();
        return;
      }

      final response = await _apiService.get(
        '/loyalty/admin/users/$userId/history',
        queryParameters: {
          'page': _currentTransactionsPage,
          'limit': 20,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final transactionsData = response['data']['data'] as List;
        final newTransactions = transactionsData
            .map((json) => PointTransaction.fromJson(json))
            .toList();

        if (refresh) {
          _transactions = newTransactions;
        } else {
          _transactions.addAll(newTransactions);
        }

        // Vérifier s'il y a plus de pages
        final pagination = response['data']['pagination'];
        if (pagination != null) {
          final currentPage = pagination['page'] as int;
          final totalPages = pagination['totalPages'] as int;
          _hasMoreTransactions = currentPage < totalPages;
          if (_hasMoreTransactions) {
            _currentTransactionsPage++;
          }
        } else {
          _hasMoreTransactions = newTransactions.length >= 20;
          if (_hasMoreTransactions) {
            _currentTransactionsPage++;
          }
        }

        _transactionsError = null;
      } else {
        _transactionsError = 'Erreur lors du chargement de l\'historique';
      }
    } catch (e) {
      _transactionsError = 'Erreur de connexion: $e';
      print('Erreur loadTransactions: $e');
    }

    _isLoadingTransactions = false;
    notifyListeners();
  }

  /// 💸 Utiliser des points pour une réduction
  Future<bool> usePoints(int points, String orderId) async {
    if (points <= 0 || points > currentPoints) {
      _usePointsError = 'Nombre de points invalide';
      notifyListeners();
      return false;
    }

    _isUsingPoints = true;
    _usePointsError = null;
    notifyListeners();

    try {
      final response = await _apiService.post('/loyalty/spend-points', data: {
        'points': points,
        'source': 'ORDER',
        'referenceId': orderId,
      });

      if (response['success'] == true) {
        // Mettre à jour les points localement
        if (_loyaltyPoints != null) {
          _loyaltyPoints = _loyaltyPoints!.copyWith(
            pointsBalance: _loyaltyPoints!.pointsBalance - points,
          );
        }

        // Ajouter la transaction à l'historique
        final newTransaction = PointTransaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: _loyaltyPoints?.userId ?? '',
          points: -points,
          type: PointTransactionType.spent,
          source: PointSource.order,
          referenceId: orderId,
          description: 'Utilisation de points pour commande',
          createdAt: DateTime.now(),
        );
        _transactions.insert(0, newTransaction);

        _usePointsError = null;
        notifyListeners();
        return true;
      } else {
        _usePointsError =
            response['error'] ?? 'Erreur lors de l\'utilisation des points';
      }
    } catch (e) {
      _usePointsError = 'Erreur de connexion: $e';
      print('Erreur usePoints: $e');
    }

    _isUsingPoints = false;
    notifyListeners();
    return false;
  }

  /// 🎁 Réclamer une récompense
  Future<bool> claimReward(String rewardId) async {
    final reward = _rewards.firstWhere(
      (r) => r.id == rewardId,
      orElse: () => throw Exception('Récompense non trouvée'),
    );

    if (reward.pointsRequired > currentPoints) {
      _usePointsError = 'Points insuffisants';
      notifyListeners();
      return false;
    }

    _isUsingPoints = true;
    _usePointsError = null;
    notifyListeners();

    try {
      final response = await _apiService.post('/loyalty/spend-points', data: {
        'points': reward.pointsRequired,
        'source': 'REWARD',
        'referenceId': rewardId,
      });

      if (response['success'] == true) {
        // Mettre à jour les points localement
        if (_loyaltyPoints != null) {
          _loyaltyPoints = _loyaltyPoints!.copyWith(
            pointsBalance:
                _loyaltyPoints!.pointsBalance - reward.pointsRequired,
          );
        }

        // Ajouter la transaction à l'historique
        final newTransaction = PointTransaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: _loyaltyPoints?.userId ?? '',
          points: -reward.pointsRequired,
          type: PointTransactionType.spent,
          source: PointSource.reward,
          referenceId: rewardId,
          description: 'Réclamation: ${reward.name}',
          createdAt: DateTime.now(),
        );
        _transactions.insert(0, newTransaction);

        _usePointsError = null;
        notifyListeners();
        return true;
      } else {
        _usePointsError = response['error'] ?? 'Erreur lors de la réclamation';
      }
    } catch (e) {
      _usePointsError = 'Erreur de connexion: $e';
      print('Erreur claimReward: $e');
    }

    _isUsingPoints = false;
    notifyListeners();
    return false;
  }

  /// 📊 Calculer les points pour un montant de commande
  int calculatePointsForAmount(double amount) {
    // 1 point par FCFA dépensé (règle standard)
    return amount.floor();
  }

  /// 💰 Calculer la réduction pour un nombre de points
  double calculateDiscountForPoints(int points) {
    // Taux de conversion: 0.1 FCFA par point (configurable)
    const conversionRate = 0.1;
    return points * conversionRate;
  }

  /// 🔄 Actualiser toutes les données (force le rechargement)
  Future<void> refreshAll() async {
    debugPrint('🔄 [LoyaltyProvider] Rafraîchissement manuel');
    await initialize(forceRefresh: true);
  }
  
  /// 🗑️ Invalider le cache (pour forcer un rechargement au prochain accès)
  void invalidateCache() {
    debugPrint('🗑️ [LoyaltyProvider] Cache invalidé');
    _isInitialized = false;
    _lastFetch = null;
  }

  /// 🧹 Nettoyer les erreurs
  void clearErrors() {
    _pointsError = null;
    _rewardsError = null;
    _transactionsError = null;
    _usePointsError = null;
    notifyListeners();
  }

  /// 📈 Statistiques pour l'affichage
  Map<String, dynamic> get loyaltyStats {
    return {
      'currentPoints': currentPoints,
      'totalEarned': totalEarned,
      'availableRewards': availableRewards.length,
      'totalRewards': _rewards.length,
      'recentTransactions': _transactions.take(5).toList(),
      'canUsePoints': hasPoints,
    };
  }

  /// 🎯 Filtrer les transactions par type
  List<PointTransaction> getTransactionsByType(PointTransactionType? type) {
    if (type == null) return _transactions;
    return _transactions.where((t) => t.type == type).toList();
  }

  /// 📅 Filtrer les transactions par période
  List<PointTransaction> getTransactionsByPeriod(
      DateTime startDate, DateTime endDate) {
    return _transactions.where((transaction) {
      return transaction.createdAt.isAfter(startDate) &&
          transaction.createdAt.isBefore(endDate);
    }).toList();
  }

  /// 🏆 Obtenir les récompenses par catégorie
  Map<RewardType, List<Reward>> get rewardsByCategory {
    final Map<RewardType, List<Reward>> categorized = {};

    for (final reward in _rewards) {
      if (!categorized.containsKey(reward.type)) {
        categorized[reward.type] = [];
      }
      categorized[reward.type]!.add(reward);
    }

    return categorized;
  }
}
