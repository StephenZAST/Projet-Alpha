import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../controllers/log_controller.dart';

class LogFilters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LogController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.radiusMD,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.radiusMD,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppColors.glassBlurSigma,
            sigmaY: AppColors.glassBlurSigma,
          ),
          child: Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardBgDark : AppColors.cardBgLight,
              borderRadius: AppRadius.radiusMD,
              border: Border.all(
                color: isDark
                    ? AppColors.gray700.withValues(alpha: 0.3)
                    : AppColors.gray200.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.filter_list_outlined,
                        color: AppColors.primary, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Filtres et recherche',
                      style: AppTextStyles.h4.copyWith(
                        color: isDark
                            ? AppColors.textLight
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    DateRangePicker(
                      onChanged: (range) {
                        controller.dateRange.value = range;
                        controller.fetchLogs();
                      },
                    ),
                    ActionFilter(
                      onChanged: (action) {
                        controller.selectedAction.value = action ?? '';
                        controller.fetchLogs();
                      },
                    ),
                    UserFilter(
                      onSubmitted: (userId) {
                        controller.selectedUserId.value = userId;
                        controller.fetchLogs();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UserFilter extends StatelessWidget {
  final ValueChanged<String> onSubmitted;

  const UserFilter({Key? key, required this.onSubmitted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: TextField(
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          labelText: 'Admin ID',
          prefixIcon: Icon(Icons.person_search_outlined,
              color: AppColors.primary.withValues(alpha: 0.7)),
          border: OutlineInputBorder(),
        ),
        onSubmitted: onSubmitted,
      ),
    );
  }
}

class DateRangePicker extends StatelessWidget {
  final Function(DateTimeRange?) onChanged;

  const DateRangePicker({Key? key, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: Icon(Icons.date_range_outlined, size: 18),
      onPressed: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        onChanged(picked);
      },
      label: Text('Période'),
    );
  }
}

class ActionFilter extends StatelessWidget {
  final Function(String?) onChanged;

  const ActionFilter({Key? key, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Action',
        prefixIcon: Icon(Icons.bolt_outlined,
            color: AppColors.accent.withValues(alpha: 0.8)),
        border: OutlineInputBorder(),
      ),
      items: [
        'ADMIN.PROFILE_UPDATED',
        'AUTH.PASSWORD_CHANGED',
        'AUTH.LOGIN_SUCCEEDED',
        'USER.UPDATED',
        'USER.CREATED',
        'USER.ROLE_CHANGED',
        'USER.DELETED',
        'ORDER.STATUS_CHANGED',
        'ORDER.PRICING_CHANGED',
        'ORDER.PAYMENT_MARKED_PAID',
        'DATA.EXPORTED',
        'CATALOG.ARTICLE_SERVICE_CREATED',
        'CATALOG.ARTICLE_SERVICE_UPDATED',
        'CATALOG.ARTICLE_SERVICE_DELETED',
        'CATALOG.SERVICE_CREATED',
        'CATALOG.SERVICE_UPDATED',
        'CATALOG.SERVICE_DELETED',
        'CATALOG.ARTICLE_CREATED',
        'CATALOG.ARTICLE_UPDATED',
        'CATALOG.ARTICLE_DELETED',
        'CATALOG.SERVICE_TYPE_CREATED',
        'CATALOG.SERVICE_TYPE_UPDATED',
        'CATALOG.SERVICE_TYPE_DELETED',
        'CATALOG.ARTICLE_CATEGORY_CREATED',
        'CATALOG.ARTICLE_CATEGORY_UPDATED',
        'CATALOG.ARTICLE_CATEGORY_DELETED',
      ]
          .map((action) => DropdownMenuItem(
                value: action,
                child: Text(action),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}
