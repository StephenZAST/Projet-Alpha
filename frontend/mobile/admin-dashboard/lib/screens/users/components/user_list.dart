import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../models/user.dart';

class UserList extends StatelessWidget {
  final List<User> users;
  final Function(String) onUserSelect;

  const UserList({
    Key? key,
    required this.users,
    required this.onUserSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            isDark ? AppColors.gray800 : AppColors.gray100,
          ),
          dataRowColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return isDark ? AppColors.gray700 : AppColors.gray200;
              }
              return isDark ? AppColors.gray900 : AppColors.white;
            },
          ),
          columns: [
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
                'Rôle',
                style: AppTextStyles.bodyBold.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Points',
                style: AppTextStyles.bodyBold.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Status',
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
          rows: users.map((user) {
            final isAffiliate = user.role == 'AFFILIATE';
            final textColor =
                isDark ? AppColors.textLight : AppColors.textPrimary;
            final mutedColor = isDark ? AppColors.gray400 : AppColors.textMuted;

            return DataRow(
              cells: [
                DataCell(
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: AppTextStyles.bodyMedium.copyWith(color: textColor),
                  ),
                ),
                DataCell(
                  Text(
                    user.email,
                    style: AppTextStyles.bodyMedium.copyWith(color: textColor),
                  ),
                ),
                DataCell(
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _getRoleColor(user.role, isDark),
                      borderRadius: AppRadius.radiusSM,
                    ),
                    child: Text(
                      _getRoleLabel(user.role),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    user.loyaltyPoints?.toString() ?? '0',
                    style: AppTextStyles.bodyMedium.copyWith(color: mutedColor),
                  ),
                ),
                DataCell(
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color:
                          user.isActive ? AppColors.success : AppColors.error,
                      borderRadius: AppRadius.radiusSM,
                    ),
                    child: Text(
                      user.isActive ? 'Actif' : 'Inactif',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_outlined),
                        color: AppColors.primary,
                        tooltip: 'Modifier',
                        onPressed: () => onUserSelect(user.id),
                      ),
                      if (isAffiliate)
                        IconButton(
                          icon: Icon(Icons.monetization_on_outlined),
                          color: AppColors.accent,
                          tooltip: 'Commissions',
                          onPressed: () {
                            // TODO: Afficher les commissions
                          },
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
  }

  Color _getRoleColor(UserRole role, bool isDark) {
    return role.color;
  }

  String _getRoleLabel(UserRole role) {
    return role.label;
  }
}
