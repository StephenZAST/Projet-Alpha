import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/users_controller.dart';
import 'components/user_stats_grid.dart';
import 'components/user_advanced_search_bar.dart';
import 'components/view_toggle.dart';
import 'components/active_filter_indicator.dart';
import 'components/adaptive_user_view.dart';
import '../../widgets/shared/glass_button.dart';
import 'components/user_create_dialog.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();

    return Scaffold(
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header uniformisé
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Utilisateurs',
                        style: AppTextStyles.h1.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Row(
                        children: [
                          // Bouton Nouvel utilisateur (glassy)
                          GlassButton(
                            label: 'Nouvel utilisateur',
                            icon: Icons.person_add_alt_1,
                            variant: GlassButtonVariant.primary,
                            onPressed: () {
                              Get.dialog(UserCreateDialog(),
                                  barrierDismissible: false);
                            },
                          ),
                          const SizedBox(width: 8),
                          // Bouton refresh (glassy)
                          GlassButton(
                            icon: Icons.refresh,
                            label: '',
                            variant: GlassButtonVariant.secondary,
                            size: GlassButtonSize.small,
                            onPressed: controller
                                .fetchUsers, // À adapter selon ton controller
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  // Barre de recherche et toggle view
                  Row(
                    children: [
                      Expanded(child: UserAdvancedSearchBar()),
                      SizedBox(width: 16),
                      ViewToggle(),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Indicateur de filtre actif
            ActiveFilterIndicator(),
            SizedBox(height: 16),

            // Stats cards
            UserStatsGrid(),
            SizedBox(height: 16),

            // Liste/Grille adaptative des utilisateurs
            Expanded(
              child: AdaptiveUserView(),
            ),
          ],
        ),
      ),
    );
  }
}
