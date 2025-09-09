import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../widgets/shared/glass_container.dart';

class GlassListItem extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final List<Widget>? trailingWidgets;
  final VoidCallback? onTap;
  final bool isHeader;

  const GlassListItem({
    Key? key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailingWidgets,
    this.onTap,
    this.isHeader = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleStyle = isHeader
        ? AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.gray300 : AppColors.gray700,
          )
        : AppTextStyles.bodyLarge;

    return GlassContainer(
      onTap: onTap,
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.md,
      ),
      child: Row(
        children: [
          leading,
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle.merge(
                  style: titleStyle,
                  child: title,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: AppSpacing.xs),
                  DefaultTextStyle.merge(
                    style: AppTextStyles.bodySmallSecondary,
                    child: subtitle!,
                  ),
                ]
              ],
            ),
          ),
          if (trailingWidgets != null) ...[
            SizedBox(width: AppSpacing.md),
            Row(children: trailingWidgets!),
          ]
        ],
      ),
    );
  }
}
