import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin/constants.dart';
import 'package:admin/controllers/client_managers_controller.dart';
import 'package:admin/widgets/shared/glass_button.dart';
import 'package:admin/widgets/shared/glass_container.dart';
import 'package:admin/models/client_manager.dart';
import 'components/agent_dashboard_dialog.dart';
import 'components/assign_client_dialog.dart';
import 'components/agent_clients_list.dart';

class ClientManagersScreen extends StatefulWidget {
  const ClientManagersScreen({Key? key}) : super(key: key);

  @override
  State<ClientManagersScreen> createState() => _ClientManagersScreenState();
}

class _ClientManagersScreenState extends State<ClientManagersScreen> {
  late ClientManagersController controller;

  @override
  void initState() {
    super.initState();
    print('[ClientManagersScreen] initState: Initialisation');

    // S'assurer que le contrôleur existe et est unique
    if (Get.isRegistered<ClientManagersController>()) {
      controller = Get.find<ClientManagersController>();
    } else {
      controller = Get.put(ClientManagersController(), permanent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    print('[ClientManagersScreen] build: Début de la construction');

    return Scaffold(
      backgroundColor: isDark ? AppColors.gray900 : AppColors.gray50,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec hauteur flexible
              Flexible(
                flex: 0,
                child: _buildHeader(context, isDark),
              ),
              SizedBox(height: AppSpacing.md),

              // Contenu principal scrollable
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Statistiques
                      _buildStatsGrid(isDark),
                      SizedBox(height: AppSpacing.lg),

                      // Filtres et recherche
                      _buildFilters(isDark),
                      SizedBox(height: AppSpacing.md),

                      // Table des agents avec hauteur contrainte
                      Container(
                        height: MediaQuery.of(context).size.height * 0.45,
                        child: GetX<ClientManagersController>(
                          builder: (controller) {
                            print('[ClientManagersScreen] GetX builder: Agents table');
                            print('[ClientManagersScreen] Agents count: ${controller.agents.length}');

                            if (controller.isLoading.value) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(height: AppSpacing.md),
                                    Text(
                                      'Chargement des agents...',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: isDark
                                            ? AppColors.textLight
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            if (controller.hasError.value) {
                              return _buildErrorState(context, isDark);
                            }

                            if (controller.agents.isEmpty) {
                              return _buildEmptyState(context, isDark);
                            }

                            return _buildAgentsTable(isDark);
                          },
                        ),
                      ),

                      // Pagination
                      SizedBox(height: AppSpacing.md),
                      _buildPagination(context, isDark),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // WIDGETS DE CONSTRUCTION
  // ============================================

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestion des Agents & Clients',
              style: AppTextStyles.h1.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Obx(() => Text(
              '${controller.totalAgents.value} agents gérés, ${controller.totalClientsAssigned.value} clients assignés',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.textSecondary,
              ),
            )),
          ],
        ),
        Row(
          children: [
            GlassButton(
              label: 'Exporter',
              icon: Icons.download_outlined,
              variant: GlassButtonVariant.info,
              onPressed: () => _showExportDialog(),
            ),
            SizedBox(width: AppSpacing.sm),
            GlassButton(
              label: 'Actualiser',
              icon: Icons.refresh_outlined,
              variant: GlassButtonVariant.secondary,
              size: GlassButtonSize.small,
              onPressed: () {
                print('[ClientManagersScreen] Bouton Actualiser cliqué');
                controller.fetchAgents();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid(bool isDark) {
    return Obx(() => GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      children: [
        _buildStatCard(
          title: 'Agents Actifs',
          value: '${controller.totalAgents.value}',
          icon: Icons.people_outline,
          color: AppColors.primary,
          isDark: isDark,
        ),
        _buildStatCard(
          title: 'Clients Assignés',
          value: '${controller.totalClientsAssigned.value}',
          icon: Icons.person_add_outlined,
          color: AppColors.success,
          isDark: isDark,
        ),
        _buildStatCard(
          title: 'Commandes Totales',
          value: '${controller.totalOrdersGenerated.value}',
          icon: Icons.shopping_cart_outlined,
          color: AppColors.accent,
          isDark: isDark,
        ),
        _buildStatCard(
          title: 'Revenus Générés',
          value: '${(controller.totalRevenueGenerated.value / 1000).toStringAsFixed(0)}k FCFA',
          icon: Icons.trending_up_outlined,
          color: AppColors.warning,
          isDark: isDark,
        ),
      ],
    ));
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return GlassContainer(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: AppRadius.radiusMD,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    return GlassContainer(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => controller.searchAgents(value),
              decoration: InputDecoration(
                hintText: 'Rechercher un agent...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.radiusMD,
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColors.gray700.withOpacity(0.3)
                        : AppColors.gray200.withOpacity(0.5),
                  ),
                ),
                filled: true,
                fillColor: isDark
                    ? AppColors.gray800.withOpacity(0.3)
                    : Colors.white.withOpacity(0.5),
              ),
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          GlassButton(
            label: 'Réinitialiser',
            icon: Icons.clear_all,
            variant: GlassButtonVariant.secondary,
            onPressed: () => controller.resetFilters(),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentsTable(bool isDark) {
    return Obx(() {
      final paginatedAgents = controller.paginatedAgents;

      if (paginatedAgents.isEmpty) {
        return Center(
          child: Text(
            'Aucun agent trouvé',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
            ),
          ),
        );
      }

      return GlassContainer(
        padding: EdgeInsets.zero,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(
                label: Text(
                  'Rang',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Nom',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Email',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Clients',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Commandes',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Revenus',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Actions',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
            rows: paginatedAgents.asMap().entries.map((entry) {
              final index = entry.key;
              final agent = entry.value;
              final isEven = index % 2 == 0;

              return DataRow(
                color: MaterialStateProperty.all(
                  isEven
                      ? (isDark ? AppColors.gray900 : AppColors.gray50)
                      : Colors.transparent,
                ),
                cells: [
                  DataCell(
                    Text(
                      '#${agent.rank}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.textLight : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      agent.name,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.textLight : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      agent.email,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      '${agent.totalClients}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.textLight : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      '${agent.totalOrders}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.textLight : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      '${(agent.totalRevenue / 1000).toStringAsFixed(0)}k FCFA',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GlassButton(
                          label: '',
                          icon: Icons.person_add_outlined,
                          variant: GlassButtonVariant.success,
                          size: GlassButtonSize.small,
                          onPressed: () => _showAssignClientDialog(agent),
                        ),
                        SizedBox(width: AppSpacing.xs),
                        GlassButton(
                          label: '',
                          icon: Icons.people_outline,
                          variant: GlassButtonVariant.info,
                          size: GlassButtonSize.small,
                          onPressed: () => _showAgentClientsList(agent),
                        ),
                        SizedBox(width: AppSpacing.xs),
                        GlassButton(
                          label: '',
                          icon: Icons.visibility_outlined,
                          variant: GlassButtonVariant.primary,
                          size: GlassButtonSize.small,
                          onPressed: () => _showAgentDashboard(agent.id),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  Widget _buildPagination(BuildContext context, bool isDark) {
    return Obx(() {
      if (controller.totalPages.value <= 1) return const SizedBox.shrink();

      return Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.gray800.withOpacity(0.5)
              : Colors.white.withOpacity(0.8),
          borderRadius: AppRadius.radiusMD,
          border: Border.all(
            color: isDark
                ? AppColors.gray700.withOpacity(0.3)
                : AppColors.gray200.withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Page ${controller.currentPage.value} sur ${controller.totalPages.value}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                GlassButton(
                  label: '',
                  icon: Icons.chevron_left,
                  variant: GlassButtonVariant.secondary,
                  size: GlassButtonSize.small,
                  onPressed: controller.currentPage.value > 1
                      ? controller.previousPage
                      : null,
                ),
                SizedBox(width: AppSpacing.sm),
                GlassButton(
                  label: '',
                  icon: Icons.chevron_right,
                  variant: GlassButtonVariant.secondary,
                  size: GlassButtonSize.small,
                  onPressed:
                      controller.currentPage.value < controller.totalPages.value
                          ? controller.nextPage
                          : null,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildErrorState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: AppRadius.radiusXL,
            ),
            child: Icon(
              Icons.error_outline,
              size: 60,
              color: AppColors.error.withOpacity(0.7),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Erreur de chargement',
            style: AppTextStyles.h3.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            controller.errorMessage.value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          GlassButton(
            label: 'Réessayer',
            icon: Icons.refresh_outlined,
            variant: GlassButtonVariant.primary,
            onPressed: () => controller.fetchAgents(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppRadius.radiusXL,
            ),
            child: Icon(
              Icons.people_outline,
              size: 60,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Aucun agent trouvé',
            style: AppTextStyles.h3.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            controller.searchQuery.value.isNotEmpty
                ? 'Aucun agent ne correspond à votre recherche'
                : 'Aucun agent n\'est encore enregistré dans le système',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          if (controller.searchQuery.value.isNotEmpty)
            GlassButton(
              label: 'Effacer la recherche',
              icon: Icons.clear_all,
              variant: GlassButtonVariant.secondary,
              onPressed: () {
                controller.searchQuery.value = '';
                controller.fetchAgents();
              },
            ),
        ],
      ),
    );
  }

  // ============================================
  // DIALOGS
  // ============================================

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: GlassContainer(
            width: 400,
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.download_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'Exporter les agents',
                  style: AppTextStyles.h4.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Fonctionnalité d\'export en cours de développement',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
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
        );
      },
    );
  }

  void _showAssignClientDialog(AgentStats agent) {
    print('[ClientManagersScreen] Affichage du dialog d\'assignation pour: ${agent.name}');
    showDialog(
      context: context,
      builder: (context) => AssignClientDialog(
        agent: agent,
        onSuccess: () {
          print('[ClientManagersScreen] Client assigné avec succès');
          controller.fetchAgents();
        },
      ),
    );
  }

  void _showAgentClientsList(AgentStats agent) {
    print('[ClientManagersScreen] Affichage de la liste des clients pour: ${agent.name}');
    showDialog(
      context: context,
      builder: (context) => AgentClientsListDialog(
        agent: agent,
        onRefresh: () {
          print('[ClientManagersScreen] Rafraîchissement de la liste des clients');
          controller.fetchAgents();
        },
      ),
    );
  }

  void _showAgentDashboard(String agentId) {
    print('[ClientManagersScreen] Affichage du dashboard pour l\'agent: $agentId');
    
    // Afficher le dialog avec le dashboard
    Get.dialog(
      Obx(() {
        final dashboard = controller.selectedAgentDashboard.value;
        final isLoading = controller.isDashboardLoading.value;
        
        if (dashboard == null && !isLoading) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            content: GlassContainer(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'Erreur lors du chargement du dashboard',
                style: AppTextStyles.bodyMedium,
              ),
            ),
          );
        }
        
        return AgentDashboardDialog(
          dashboard: dashboard ?? AgentDashboard(
            agent: Agent(id: '', name: '', email: ''),
            stats: AgentStats(
              id: '',
              name: '',
              email: '',
              totalClients: 0,
              totalOrders: 0,
              totalRevenue: 0,
              avgOrderValue: 0,
              inactiveClientsCount: 0,
              rank: 0,
              lastUpdated: DateTime.now(),
            ),
            inactiveClients: [],
            topClients: [],
          ),
          isLoading: isLoading,
        );
      }),
      barrierDismissible: true,
    );
    
    // Charger le dashboard APRÈS l'affichage du dialog
    // Utiliser Future.microtask pour s'assurer que le dialog est construit
    Future.microtask(() {
      controller.fetchAgentDashboard(agentId);
    });
  }
}
