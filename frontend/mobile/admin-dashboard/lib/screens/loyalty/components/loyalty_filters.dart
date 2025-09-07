import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/loyalty_controller.dart';
import '../../../widgets/shared/glass_container.dart';
import '../../../widgets/shared/glass_button.dart';

class LoyaltyFilters extends StatelessWidget {
  const LoyaltyFilters({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoyaltyController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                // Barre de recherche
                Expanded(
                  flex: 3,
                  child: TextField(
                    onChanged: controller.searchLoyaltyPoints,
                    decoration: InputDecoration(
                      hintText: 'Rechercher par nom, email...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.radiusSM,
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.gray600.withOpacity(0.3)
                              : AppColors.gray300.withOpacity(0.5),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.radiusSM,
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.gray600.withOpacity(0.3)
                              : AppColors.gray300.withOpacity(0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.radiusSM,
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor:
                          isDark ? AppColors.cardBgDark : AppColors.cardBgLight,
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.md),

                // Filtres rapides
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Expanded(
                        child: GlassButton(
                          label: 'Avec Points',
                          icon: Icons.stars_outlined,
                          variant: GlassButtonVariant.success,
                          size: GlassButtonSize.small,
                          onPressed: () =>
                              _filterByPointsBalance(controller, true),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: GlassButton(
                          label: 'Sans Points',
                          icon: Icons.star_border_outlined,
                          variant: GlassButtonVariant.secondary,
                          size: GlassButtonSize.small,
                          onPressed: () =>
                              _filterByPointsBalance(controller, false),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.md),

                // Actions
                Row(
                  children: [
                    GlassButton(
                      label: 'Effacer',
                      icon: Icons.clear_all,
                      variant: GlassButtonVariant.secondary,
                      size: GlassButtonSize.small,
                      onPressed: () => _clearFilters(controller),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    GlassButton(
                      label: 'Exporter',
                      icon: Icons.download_outlined,
                      variant: GlassButtonVariant.info,
                      size: GlassButtonSize.small,
                      onPressed: () => _exportData(controller),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),

            // Filtres avancés
            _buildAdvancedFilters(context, isDark, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedFilters(
    BuildContext context,
    bool isDark,
    LoyaltyController controller,
  ) {
    return ExpansionTile(
      title: Text(
        'Filtres Avancés',
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textLight : AppColors.textPrimary,
        ),
      ),
      leading: Icon(
        Icons.tune,
        color: AppColors.primary,
      ),
      children: [
        Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Row(
                children: [
                  // Filtre par plage de points
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Plage de Points',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textLight
                                : AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Min',
                                  border: OutlineInputBorder(
                                    borderRadius: AppRadius.radiusSM,
                                  ),
                                  isDense: true,
                                ),
                                onChanged: (value) {
                                  // TODO: Implémenter le filtre par plage min
                                },
                              ),
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Text(
                              'à',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isDark
                                    ? AppColors.gray300
                                    : AppColors.gray600,
                              ),
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Max',
                                  border: OutlineInputBorder(
                                    borderRadius: AppRadius.radiusSM,
                                  ),
                                  isDense: true,
                                ),
                                onChanged: (value) {
                                  // TODO: Implémenter le filtre par plage max
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSpacing.lg),

                  // Filtre par période
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Période d\'Inscription',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textLight
                                : AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.radiusSM,
                            ),
                            isDense: true,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: null,
                              child: Text('Toutes les périodes'),
                            ),
                            DropdownMenuItem(
                              value: 'today',
                              child: Text('Aujourd\'hui'),
                            ),
                            DropdownMenuItem(
                              value: 'week',
                              child: Text('Cette semaine'),
                            ),
                            DropdownMenuItem(
                              value: 'month',
                              child: Text('Ce mois'),
                            ),
                            DropdownMenuItem(
                              value: 'quarter',
                              child: Text('Ce trimestre'),
                            ),
                            DropdownMenuItem(
                              value: 'year',
                              child: Text('Cette année'),
                            ),
                          ],
                          onChanged: (value) {
                            // TODO: Implémenter le filtre par période
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),

              // Filtres par statut
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Statut des Points',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textLight
                                : AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          children: [
                            FilterChip(
                              label: Text('Peut échanger'),
                              selected: false, // TODO: Lier à l'état
                              onSelected: (selected) {
                                // TODO: Implémenter le filtre "peut échanger"
                              },
                              selectedColor: AppColors.success.withOpacity(0.2),
                              checkmarkColor: AppColors.success,
                            ),
                            FilterChip(
                              label: Text('Actifs récemment'),
                              selected: false, // TODO: Lier à l'état
                              onSelected: (selected) {
                                // TODO: Implémenter le filtre "actifs récemment"
                              },
                              selectedColor: AppColors.primary.withOpacity(0.2),
                              checkmarkColor: AppColors.primary,
                            ),
                            FilterChip(
                              label: Text('Nouveaux membres'),
                              selected: false, // TODO: Lier à l'état
                              onSelected: (selected) {
                                // TODO: Implémenter le filtre "nouveaux membres"
                              },
                              selectedColor: AppColors.info.withOpacity(0.2),
                              checkmarkColor: AppColors.info,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _filterByPointsBalance(LoyaltyController controller, bool hasPoints) {
    // TODO: Implémenter le filtre par solde de points
    // Pour l'instant, on utilise la recherche comme approximation
    if (hasPoints) {
      // Filtrer pour afficher seulement ceux avec des points > 0
      controller.searchQuery.value = '';
      // Logique de filtrage à implémenter dans le contrôleur
    } else {
      // Filtrer pour afficher seulement ceux avec 0 points
      controller.searchQuery.value = '';
      // Logique de filtrage à implémenter dans le contrôleur
    }
  }

  void _clearFilters(LoyaltyController controller) {
    controller.searchQuery.value = '';
    // TODO: Réinitialiser tous les autres filtres
    controller.fetchLoyaltyPoints(resetPage: true);
  }

  void _exportData(LoyaltyController controller) {
    // TODO: Implémenter l'export des données
    Get.snackbar(
      'Export',
      'Fonctionnalité d\'export en cours de développement',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.info.withOpacity(0.1),
      colorText: AppColors.info,
      duration: Duration(seconds: 3),
      margin: EdgeInsets.all(16),
      borderRadius: 8,
    );
  }
}
