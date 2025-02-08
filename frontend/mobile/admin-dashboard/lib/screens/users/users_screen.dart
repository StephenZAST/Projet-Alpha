import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/users_controller.dart';
import 'components/user_stats_grid.dart';
import 'components/user_filters.dart';
import 'components/user_list.dart';
import 'components/users_pagination.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête et titre
          Text(
            'Gestion des utilisateurs',
            style: AppTextStyles.h2.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          // Stats des utilisateurs
          UserStatsGrid(),
          SizedBox(height: AppSpacing.lg),

          // Filtres de recherche
          UserFilters(),
          SizedBox(height: AppSpacing.lg),

          // Liste des utilisateurs
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: AppRadius.radiusMD,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  );
                }

                if (controller.hasError.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 48,
                        ),
                        SizedBox(height: AppSpacing.md),
                        Text(
                          controller.errorMessage.value,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSpacing.md),
                        ElevatedButton.icon(
                          onPressed: () => controller.fetchUsers(),
                          icon: Icon(Icons.refresh),
                          label: Text('Réessayer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.users.isEmpty) {
                  return Center(
                    child: Text(
                      'Aucun utilisateur trouvé',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: UserList(),
                    ),
                    UsersPagination(),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
