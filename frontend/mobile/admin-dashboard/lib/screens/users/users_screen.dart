import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/users_controller.dart';
import '../../widgets/shared/pagination_controls.dart';
import 'components/user_list.dart';
import 'components/user_filters.dart';
import 'components/user_details.dart';

class UsersScreen extends StatefulWidget {
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late final UsersController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(UsersController());
    controller.loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gestion des Utilisateurs',
                style: AppTextStyles.h2.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: defaultPadding),
              UserFilters(),
              SizedBox(height: defaultPadding),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: AppRadius.radiusMD,
                    border: Border.all(
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
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
                        child: Text(
                          controller.errorMessage.value,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      );
                    }

                    if (controller.users.isEmpty) {
                      return Center(
                        child: Text(
                          'Aucun utilisateur trouvé',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.textLight
                                : AppColors.textSecondary,
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        Expanded(
                          child: UserList(
                            users: controller.users,
                            onUserSelect: (userId) {
                              controller.loadUserDetails(userId);
                              Get.dialog(
                                Dialog(
                                  child: Container(
                                    width: 800,
                                    padding: EdgeInsets.all(defaultPadding),
                                    child: UserDetails(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        PaginationControls(
                          currentPage: controller.currentPage.value,
                          totalPages: controller.totalPages.value,
                          itemsPerPage: controller.itemsPerPage.value,
                          totalItems: controller.totalUsers.value,
                          onNextPage: controller.nextPage,
                          onPreviousPage: controller.previousPage,
                          onItemsPerPageChanged: controller.setItemsPerPage,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
