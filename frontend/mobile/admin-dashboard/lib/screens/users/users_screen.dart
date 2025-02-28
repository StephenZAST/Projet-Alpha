import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/users_controller.dart';
import 'components/user_stats_grid.dart';
import 'components/user_search_bar.dart';
import 'components/view_toggle.dart';
import 'components/active_filter_indicator.dart';
import 'components/adaptive_user_view.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.all(defaultPadding),
      child: Column(
        children: [
          // En-tête avec les filtres
          Row(
            children: [
              Expanded(child: UserSearchBar()),
              SizedBox(width: 16),
              ViewToggle(),
            ],
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
    );
  }
}
