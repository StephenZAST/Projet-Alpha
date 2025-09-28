import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/delivery_service.dart';
import '../models/user.dart';

/// 🏠 Contrôleur Dashboard - Alpha Delivery App
/// 
/// Gère l'état du dashboard principal avec statistiques,
/// commandes du jour et actions rapides pour les livreurs.
class DashboardController extends GetxController {
  
  // ==========================================================================
  // 📦 SERVICES
  // ==========================================================================
  
  late final DeliveryService _deliveryService;
  
  // ==========================================================================
  // 🎯 ÉTATS OBSERVABLES
  // ==========================================================================
  
  final _isLoading = false.obs;
  final _stats = Rxn<DeliveryStats>();
  final _todayOrders = <dynamic>[].obs;
  final _lastRefresh = Rxn<DateTime>();
  
  // ==========================================================================
  // 🎯 GETTERS
  // ==========================================================================
  
  bool get isLoading => _isLoading.value;
  DeliveryStats? get stats => _stats.value;
  List<dynamic> get todayOrders => _todayOrders;
  DateTime? get lastRefresh => _lastRefresh.value;
  
  // Statistiques individuelles
  int get todayDeliveries => stats?.deliveriesToday ?? 0;
  int get weekDeliveries => stats?.deliveriesThisWeek ?? 0;
  int get monthDeliveries => stats?.deliveriesThisMonth ?? 0;
  double get todayEarnings => stats?.dailyEarnings ?? 0.0;
  double get weekEarnings => stats?.weeklyEarnings ?? 0.0;
  double get monthEarnings => stats?.monthlyEarnings ?? 0.0;
  double get totalEarnings => stats?.totalEarnings ?? 0.0;
  double get averageRating => stats?.averageRating ?? 0.0;
  double get successRate => stats?.successRate ?? 0.0;
  
  // Getters observables
  RxBool get isLoadingRx => _isLoading;
  Rxn<DeliveryStats> get statsRx => _stats;
  
  // ==========================================================================
  // 🚀 INITIALISATION
  // ==========================================================================
  
  @override
  void onInit() {
    super.onInit();
    debugPrint('🏠 Initialisation DashboardController...');
    
    // Récupère le service de livraison
    _deliveryService = Get.find<DeliveryService>();
    
    // Charge les données initiales
    _loadInitialData();
    
    debugPrint('✅ DashboardController initialisé');
  }
  
  /// Charge les données initiales du dashboard
  Future<void> _loadInitialData() async {
    await Future.wait([
      loadStats(),
      loadTodayOrders(),
    ]);
  }
  
  // ==========================================================================
  // 📊 GESTION DES STATISTIQUES
  // ==========================================================================
  
  /// Charge les statistiques du livreur
  Future<void> loadStats() async {
    try {
      debugPrint('📊 Chargement des statistiques...');
      
      _isLoading.value = true;
      
      final stats = await _deliveryService.getDashboardStats();
      _stats.value = stats;
      
      debugPrint('✅ Statistiques chargées: ${stats.totalDeliveries} livraisons');
      
    } catch (e) {
      debugPrint('❌ Erreur chargement statistiques: $e');
      
      // Affiche un message d'erreur
      Get.snackbar(
        'Erreur',
        'Impossible de charger les statistiques',
        snackPosition: SnackPosition.TOP,
      );
      
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Charge les commandes du jour
  Future<void> loadTodayOrders() async {
    try {
      debugPrint('📅 Chargement des commandes du jour...');
      
      final orders = await _deliveryService.getTodayOrders();
      _todayOrders.value = orders;
      
      debugPrint('✅ Commandes du jour chargées: ${orders.length}');
      
    } catch (e) {
      debugPrint('❌ Erreur chargement commandes du jour: $e');
      
      // En cas d'erreur, on garde une liste vide
      _todayOrders.value = [];
    }
  }
  
  // ==========================================================================
  // 🔄 ACTUALISATION DES DONNÉES
  // ==========================================================================
  
  /// Actualise toutes les données du dashboard
  Future<void> refreshData() async {
    try {
      debugPrint('🔄 Actualisation du dashboard...');
      
      _lastRefresh.value = DateTime.now();
      
      await Future.wait([
        loadStats(),
        loadTodayOrders(),
      ]);
      
      debugPrint('✅ Dashboard actualisé');
      
      // Affiche un message de confirmation
      Get.snackbar(
        'Actualisé',
        'Données mises à jour',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      
    } catch (e) {
      debugPrint('❌ Erreur actualisation dashboard: $e');
      
      Get.snackbar(
        'Erreur',
        'Impossible d\'actualiser les données',
        snackPosition: SnackPosition.TOP,
      );
    }
  }
  
  /// Actualise uniquement les statistiques
  Future<void> refreshStats() async {
    await loadStats();
  }
  
  /// Actualise uniquement les commandes
  Future<void> refreshOrders() async {
    await loadTodayOrders();
  }
  
  // ==========================================================================
  // 📈 MÉTHODES UTILITAIRES POUR LES STATISTIQUES
  // ==========================================================================
  
  /// Obtient le pourcentage de réussite formaté
  String get formattedSuccessRate {
    return '${successRate.toStringAsFixed(1)}%';
  }
  
  /// Obtient la note moyenne formatée
  String get formattedAverageRating {
    return averageRating.toStringAsFixed(1);
  }
  
  /// Obtient les gains du jour formatés
  String get formattedTodayEarnings {
    return '${todayEarnings.toStringAsFixed(0)} FCFA';
  }
  
  /// Obtient les gains de la semaine formatés
  String get formattedWeekEarnings {
    return '${weekEarnings.toStringAsFixed(0)} FCFA';
  }
  
  /// Obtient les gains du mois formatés
  String get formattedMonthEarnings {
    return '${monthEarnings.toStringAsFixed(0)} FCFA';
  }
  
  /// Obtient les gains totaux formatés
  String get formattedTotalEarnings {
    return '${totalEarnings.toStringAsFixed(0)} FCFA';
  }
  
  /// Vérifie si les données sont récentes (moins de 5 minutes)
  bool get isDataRecent {
    if (_lastRefresh.value == null) return false;
    
    final now = DateTime.now();
    final difference = now.difference(_lastRefresh.value!);
    return difference.inMinutes < 5;
  }
  
  /// Obtient le temps écoulé depuis la dernière actualisation
  String get timeSinceLastRefresh {
    if (_lastRefresh.value == null) return 'Jamais';
    
    final now = DateTime.now();
    final difference = now.difference(_lastRefresh.value!);
    
    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else {
      return 'Il y a ${difference.inHours}h';
    }
  }
  
  // ==========================================================================
  // 🎯 ACTIONS RAPIDES
  // ==========================================================================
  
  /// Navigation vers les commandes
  void goToOrders() {
    Get.toNamed('/orders');
  }
  
  /// Navigation vers la carte
  void goToMap() {
    Get.toNamed('/map');
  }
  
  /// Navigation vers l'historique
  void goToHistory() {
    Get.toNamed('/orders', arguments: {'tab': 'history'});
  }
  
  /// Navigation vers le profil
  void goToProfile() {
    Get.toNamed('/profile');
  }
  
  /// Navigation vers les paramètres
  void goToSettings() {
    Get.toNamed('/settings');
  }
  
  // ==========================================================================
  // 📊 MÉTHODES DE COMPARAISON
  // ==========================================================================
  
  /// Compare les livraisons d'aujourd'hui avec hier
  String get todayVsYesterdayComparison {
    // TODO: Implémenter la comparaison avec les données d'hier
    return '+2 par rapport à hier';
  }
  
  /// Compare les gains de cette semaine avec la semaine dernière
  String get weekVsLastWeekComparison {
    // TODO: Implémenter la comparaison avec la semaine dernière
    return '+15% par rapport à la semaine dernière';
  }
  
  /// Obtient la tendance des livraisons
  String get deliveryTrend {
    if (todayDeliveries > weekDeliveries / 7) {
      return 'En hausse';
    } else if (todayDeliveries < weekDeliveries / 7) {
      return 'En baisse';
    } else {
      return 'Stable';
    }
  }
  
  // ==========================================================================
  // 🔧 MÉTHODES UTILITAIRES
  // ==========================================================================
  
  /// Vérifie si le livreur a des commandes en cours
  bool get hasActiveOrders {
    return todayOrders.isNotEmpty;
  }
  
  /// Obtient le nombre de commandes en cours
  int get activeOrdersCount {
    return todayOrders.length;
  }
  
  /// Vérifie si c'est un bon jour (plus de livraisons que la moyenne)
  bool get isGoodDay {
    final averageDaily = weekDeliveries / 7;
    return todayDeliveries > averageDaily;
  }
  
  /// Obtient un message de motivation
  String get motivationMessage {
    if (isGoodDay) {
      return 'Excellente journée ! Continuez comme ça ! 🚀';
    } else if (todayDeliveries > 0) {
      return 'Bon travail ! Encore quelques livraisons ? 💪';
    } else {
      return 'Prêt pour une nouvelle journée ? 🌟';
    }
  }
  
  /// Réinitialise les données
  void reset() {
    _isLoading.value = false;
    _stats.value = null;
    _todayOrders.clear();
    _lastRefresh.value = null;
  }
  
  @override
  void onClose() {
    reset();
    super.onClose();
  }
}