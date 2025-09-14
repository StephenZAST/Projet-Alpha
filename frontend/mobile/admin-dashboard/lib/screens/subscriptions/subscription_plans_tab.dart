import 'package:flutter/material.dart';
import 'dart:ui';
import '../../constants.dart';
import '../../widgets/shared/glass_button.dart';
import '../../widgets/shared/glass_container.dart';
import '../../models/subscription_plan.dart';
import '../../services/api_service.dart';
import 'package:get/get.dart';
import '../../models/user_subscription.dart';

class SubscriptionPlansTab extends StatefulWidget {
  const SubscriptionPlansTab({Key? key}) : super(key: key);

  @override
  State<SubscriptionPlansTab> createState() => _SubscriptionPlansTabState();
}

class _SubscriptionPlansTabState extends State<SubscriptionPlansTab> {
  List<SubscriptionPlan> plans = [];
  bool isLoading = true;
  final api = Get.find<ApiService>();

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() => isLoading = true);
    try {
      final response = await api.get('/admin/subscriptions/plans');
      final data =
          response.data is List ? response.data : response.data['data'];
      plans = (data as List)
          .map((json) => SubscriptionPlan.fromJson(json))
          .toList();
    } catch (e) {
      // Fallback avec des données de démonstration
      plans = [
        SubscriptionPlan(
          id: '1',
          name: 'Plan Basique',
          description: 'Parfait pour débuter',
          price: 5000,
          durationDays: 30,
          maxOrdersPerMonth: 5,
          maxWeightPerOrder: 10.0,
          isPremium: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        SubscriptionPlan(
          id: '2',
          name: 'Plan Premium',
          description: 'Le plus populaire',
          price: 15000,
          durationDays: 30,
          maxOrdersPerMonth: 20,
          maxWeightPerOrder: 25.0,
          isPremium: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        SubscriptionPlan(
          id: '3',
          name: 'Plan Entreprise',
          description: 'Pour les gros volumes',
          price: 50000,
          durationDays: 30,
          maxOrdersPerMonth: 100,
          maxWeightPerOrder: 50.0,
          isPremium: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: AppSpacing.md),
            Text(
              'Chargement des plans d\'abonnement...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header avec actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plans d\'abonnement',
                  style: AppTextStyles.h3.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${plans.length} plan${plans.length > 1 ? 's' : ''} disponible${plans.length > 1 ? 's' : ''}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                GlassButton(
                  label: 'Importer',
                  icon: Icons.upload_outlined,
                  variant: GlassButtonVariant.secondary,
                  onPressed: () => _showImportDialog(),
                ),
                SizedBox(width: AppSpacing.sm),
                GlassButton(
                  label: 'Nouveau plan',
                  icon: Icons.add_circle_outline,
                  variant: GlassButtonVariant.primary,
                  onPressed: () => _showPlanDialog(),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: AppSpacing.lg),

        // Grille des plans
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 3;
              if (constraints.maxWidth < 1200) crossAxisCount = 2;
              if (constraints.maxWidth < 800) crossAxisCount = 1;

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: AppSpacing.lg,
                  mainAxisSpacing: AppSpacing.lg,
                  childAspectRatio: 0.75,
                ),
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  return _buildPlanCard(plan, isDark);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan, bool isDark) {
    final Color planColor = plan.isPremium ? AppColors.primary : AppColors.info;

    return GlassContainer(
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Gradient background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    planColor.withOpacity(0.1),
                    planColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: AppRadius.radiusMD,
              ),
            ),
          ),

          // Premium badge
          if (plan.isPremium)
            Positioned(
              top: AppSpacing.md,
              right: AppSpacing.md,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.15),
                  borderRadius: AppRadius.radiusSM,
                  border: Border.all(
                    color: AppColors.warning.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 12, color: AppColors.warning),
                    SizedBox(width: 2),
                    Text(
                      'PREMIUM',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Content
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avec icône
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: planColor.withOpacity(0.15),
                        borderRadius: AppRadius.radiusSM,
                      ),
                      child: Icon(
                        Icons.subscriptions_outlined,
                        color: planColor,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: AppTextStyles.h4.copyWith(
                              color: isDark
                                  ? AppColors.textLight
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (plan.description != null &&
                              plan.description!.isNotEmpty)
                            Text(
                              plan.description!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.gray300
                                    : AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.md),

                // Prix
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${plan.price.toStringAsFixed(0)}',
                      style: AppTextStyles.h2.copyWith(
                        color: planColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      'FCFA',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: planColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                Text(
                  'par ${plan.durationDays} jours',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: AppSpacing.md),

                // Caractéristiques
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFeatureItem(
                        '${plan.maxOrdersPerMonth} commandes/mois',
                        Icons.shopping_cart_outlined,
                        AppColors.success,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      _buildFeatureItem(
                        '${plan.maxWeightPerOrder != null ? plan.maxWeightPerOrder!.toStringAsFixed(0) : '0'} kg max/commande',
                        Icons.scale_outlined,
                        AppColors.info,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      _buildFeatureItem(
                        plan.isPremium
                            ? 'Support prioritaire'
                            : 'Support standard',
                        Icons.support_agent_outlined,
                        plan.isPremium ? AppColors.warning : AppColors.gray500,
                      ),
                      if (plan.isPremium) ...[
                        SizedBox(height: AppSpacing.xs),
                        _buildFeatureItem(
                          'Remises exclusives',
                          Icons.discount_outlined,
                          AppColors.violet,
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: AppSpacing.md),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        label: 'Abonnés',
                        icon: Icons.people_outline,
                        variant: GlassButtonVariant.info,
                        size: GlassButtonSize.small,
                        onPressed: () => _showSubscribersDialog(plan),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    GlassButton(
                      label: '',
                      icon: Icons.more_vert,
                      variant: GlassButtonVariant.secondary,
                      size: GlassButtonSize.small,
                      onPressed: () => _showPlanActions(plan),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.gray300
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  void _showPlanDialog({SubscriptionPlan? plan}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: GlassContainer(
          width: 600,
          height: 500,
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    plan == null
                        ? Icons.add_circle_outline
                        : Icons.edit_outlined,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    plan == null
                        ? 'Nouveau plan d\'abonnement'
                        : 'Modifier le plan',
                    style: AppTextStyles.h3,
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.construction_outlined,
                        size: 64,
                        color: AppColors.primary.withOpacity(0.5),
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'Formulaire de plan',
                        style: AppTextStyles.h4,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        'Interface de création/modification en cours de développement',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GlassButton(
                    label: 'Annuler',
                    variant: GlassButtonVariant.secondary,
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: AppSpacing.md),
                  GlassButton(
                    label: plan == null ? 'Créer' : 'Sauvegarder',
                    variant: GlassButtonVariant.primary,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlanActions(SubscriptionPlan plan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        margin: EdgeInsets.all(AppSpacing.md),
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Actions pour ${plan.name}',
              style: AppTextStyles.h4,
            ),
            SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: Icon(Icons.edit, color: AppColors.primary),
              title: Text('Modifier'),
              onTap: () {
                Navigator.pop(context);
                _showPlanDialog(plan: plan);
              },
            ),
            ListTile(
              leading: Icon(Icons.copy, color: AppColors.info),
              title: Text('Dupliquer'),
              onTap: () {
                Navigator.pop(context);
                _duplicatePlan(plan);
              },
            ),
            ListTile(
              leading: Icon(Icons.analytics, color: AppColors.success),
              title: Text('Voir les statistiques'),
              onTap: () {
                Navigator.pop(context);
                _showPlanStats(plan);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: AppColors.error),
              title: Text('Supprimer'),
              onTap: () {
                Navigator.pop(context);
                _deletePlan(plan);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSubscribersDialog(SubscriptionPlan plan) {
    showDialog(
      context: context,
      builder: (context) => _SubscriptionUsersDialog(plan: plan),
    );
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: GlassContainer(
          width: 400,
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.upload_outlined, size: 48, color: AppColors.primary),
              SizedBox(height: AppSpacing.md),
              Text('Importer des plans', style: AppTextStyles.h4),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Fonctionnalité d\'import en cours de développement',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.lg),
              GlassButton(
                label: 'Fermer',
                variant: GlassButtonVariant.secondary,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _duplicatePlan(SubscriptionPlan plan) {
    final newPlan = SubscriptionPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${plan.name} (Copie)',
      description: plan.description,
      price: plan.price,
      durationDays: plan.durationDays,
      maxOrdersPerMonth: plan.maxOrdersPerMonth,
      maxWeightPerOrder: plan.maxWeightPerOrder,
      isPremium: plan.isPremium,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() {
      plans.add(newPlan);
    });
  }

  void _showPlanStats(SubscriptionPlan plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: GlassContainer(
          width: 600,
          height: 400,
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Text('Statistiques - ${plan.name}', style: AppTextStyles.h3),
              SizedBox(height: AppSpacing.lg),
              Expanded(
                child: Center(
                  child: Text(
                    'Statistiques détaillées en cours de développement',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ),
              GlassButton(
                label: 'Fermer',
                variant: GlassButtonVariant.secondary,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deletePlan(SubscriptionPlan plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: GlassContainer(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 48, color: AppColors.warning),
              SizedBox(height: AppSpacing.md),
              Text('Confirmer la suppression', style: AppTextStyles.h4),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Êtes-vous sûr de vouloir supprimer "${plan.name}" ?\n\nCette action supprimera également tous les abonnements associés.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: 'Annuler',
                      variant: GlassButtonVariant.secondary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GlassButton(
                      label: 'Supprimer',
                      variant: GlassButtonVariant.error,
                      onPressed: () {
                        setState(() {
                          plans.remove(plan);
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dialog pour afficher les abonnés d'un plan
class _SubscriptionUsersDialog extends StatefulWidget {
  final SubscriptionPlan plan;
  const _SubscriptionUsersDialog({Key? key, required this.plan})
      : super(key: key);

  @override
  State<_SubscriptionUsersDialog> createState() =>
      _SubscriptionUsersDialogState();
}

class _SubscriptionUsersDialogState extends State<_SubscriptionUsersDialog> {
  List<UserSubscription> users = [];
  List<UserSubscription> filteredUsers = [];
  bool isLoading = false;
  final api = Get.find<ApiService>();
  String statusFilter = 'ALL';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => isLoading = true);
    try {
      final response =
          await api.get('/admin/subscriptions/plans/${widget.plan.id}/users');
      final data =
          response.data is List ? response.data : response.data['data'];
      users = (data as List)
          .map((json) => UserSubscription.fromJson(json))
          .toList();
      _applyFilters();
    } catch (e) {
      // Données de démonstration
      users = [
        UserSubscription(
          id: '1',
          userId: 'user1@example.com',
          userName: 'Jean Dupont',
          planId: widget.plan.id,
          startDate: DateTime.now().subtract(Duration(days: 10)),
          endDate: DateTime.now().add(Duration(days: 20)),
          status: 'ACTIVE',
          remainingOrders: 15,
          remainingWeight: 25.5,
          expired: false,
          createdAt: DateTime.now().subtract(Duration(days: 10)),
          updatedAt: DateTime.now(),
        ),
        UserSubscription(
          id: '2',
          userId: 'user2@example.com',
          userName: 'Marie Martin',
          planId: widget.plan.id,
          startDate: DateTime.now().subtract(Duration(days: 5)),
          endDate: DateTime.now().add(Duration(days: 25)),
          status: 'ACTIVE',
          remainingOrders: 18,
          remainingWeight: 30.0,
          expired: false,
          createdAt: DateTime.now().subtract(Duration(days: 5)),
          updatedAt: DateTime.now(),
        ),
      ];
      _applyFilters();
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      filteredUsers = users.where((user) {
        final matchesStatus =
            statusFilter == 'ALL' || user.status == statusFilter;
        final matchesSearch = searchQuery.isEmpty ||
            (user.userName?.toLowerCase().contains(searchQuery.toLowerCase()) ??
                false) ||
            (user.userId.toLowerCase().contains(searchQuery.toLowerCase()));
        return matchesStatus && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      content: GlassContainer(
        width: 700,
        height: 600,
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Text(
              'Abonnés du plan "${widget.plan.name}"',
              style: AppTextStyles.h3,
            ),
            SizedBox(height: AppSpacing.lg),

            // Filtres
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Recherche par nom ou email',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.radiusMD,
                      ),
                    ),
                    onChanged: (value) {
                      searchQuery = value;
                      _applyFilters();
                    },
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                DropdownButton<String>(
                  value: statusFilter,
                  items: [
                    DropdownMenuItem(value: 'ALL', child: Text('Tous')),
                    DropdownMenuItem(value: 'ACTIVE', child: Text('Actif')),
                    DropdownMenuItem(value: 'CANCELLED', child: Text('Annulé')),
                    DropdownMenuItem(value: 'EXPIRED', child: Text('Expiré')),
                  ],
                  onChanged: (value) {
                    statusFilter = value ?? 'ALL';
                    _applyFilters();
                  },
                ),
              ],
            ),

            SizedBox(height: AppSpacing.lg),

            // Liste des abonnés
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : filteredUsers.isEmpty
                      ? Center(
                          child: Text('Aucun utilisateur abonné à ce plan'))
                      : ListView.builder(
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: AppSpacing.sm),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      AppColors.primary.withOpacity(0.15),
                                  child: Icon(Icons.person,
                                      color: AppColors.primary),
                                ),
                                title: Text(user.userName ?? user.userId),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Email: ${user.userId}'),
                                    Text('Statut: ${user.status}'),
                                    Text(
                                        'Commandes restantes: ${user.remainingOrders}'),
                                  ],
                                ),
                                trailing: GlassButton(
                                  label: 'Détails',
                                  variant: GlassButtonVariant.info,
                                  size: GlassButtonSize.small,
                                  onPressed: () => _showUserDetails(user),
                                ),
                              ),
                            );
                          },
                        ),
            ),

            SizedBox(height: AppSpacing.lg),
            GlassButton(
              label: 'Fermer',
              variant: GlassButtonVariant.secondary,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDetails(UserSubscription user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: GlassContainer(
          width: 400,
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Détails de l\'abonnement', style: AppTextStyles.h4),
              SizedBox(height: AppSpacing.lg),
              Text('Utilisateur: ${user.userName ?? user.userId}'),
              Text('Plan: ${widget.plan.name}'),
              Text(
                  'Début: ${user.startDate.toLocal().toString().split(' ')[0]}'),
              Text('Fin: ${user.endDate.toLocal().toString().split(' ')[0]}'),
              Text('Statut: ${user.status}'),
              Text('Commandes restantes: ${user.remainingOrders}'),
              if (user.remainingWeight != null)
                Text('Poids restant: ${user.remainingWeight} kg'),
              SizedBox(height: AppSpacing.lg),
              GlassButton(
                label: 'Fermer',
                variant: GlassButtonVariant.secondary,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
