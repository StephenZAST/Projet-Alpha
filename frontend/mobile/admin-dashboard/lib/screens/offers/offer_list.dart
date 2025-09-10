import 'package:admin/screens/delivery/components/glass_list_item.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../widgets/shared/glass_container.dart';

class OfferList extends StatelessWidget {
  final List<Map<String, dynamic>> offers;
  final void Function(Map<String, dynamic>) onEdit;
  final void Function(Map<String, dynamic>) onDelete;
  final void Function(Map<String, dynamic>) onToggleStatus;

  const OfferList({
    Key? key,
    required this.offers,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (offers.isEmpty) {
      return Center(
        child: GlassContainer(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_offer_outlined,
                  size: 48, color: AppColors.gray400),
              SizedBox(height: AppSpacing.md),
              Text(
                "Aucune offre disponible.",
                style: AppTextStyles.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final offer = offers[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _buildOfferItem(context, offer, isDark),
        );
      },
    );
  }

  Widget _buildOfferItem(
      BuildContext context, Map<String, dynamic> offer, bool isDark) {
    final bool isActive = offer['isActive'] ?? offer['is_active'] ?? false;
    final String discountType = offer['discountType'] ?? 'PERCENTAGE';

    IconData getOfferIcon() {
      switch (discountType) {
        case 'PERCENTAGE':
          return Icons.percent_outlined;
        case 'FIXED_AMOUNT':
          return Icons.attach_money_outlined;
        case 'POINTS_EXCHANGE':
          return Icons.star_outline;
        default:
          return Icons.local_offer_outlined;
      }
    }

    return GlassListItem(
      onTap: () => onEdit(offer),
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.15),
        child: Icon(
          getOfferIcon(),
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(offer['name'] ?? 'Offre sans nom',
          style: AppTextStyles.bodyLarge),
      subtitle: Text(
        offer['description'] ?? 'Aucune description',
        style: AppTextStyles.bodySmallSecondary,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailingWidgets: [
        _buildStatusBadge(isActive, isDark),
        SizedBox(width: AppSpacing.md),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              onEdit(offer);
            } else if (value == 'toggle') {
              onToggleStatus(offer);
            } else if (value == 'delete') {
              onDelete(offer);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit_outlined),
                title: Text('Modifier'),
              ),
            ),
            PopupMenuItem<String>(
              value: 'toggle',
              child: ListTile(
                leading: Icon(isActive
                    ? Icons.toggle_off_outlined
                    : Icons.toggle_on_outlined),
                title: Text(isActive ? 'Désactiver' : 'Activer'),
              ),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline, color: AppColors.error),
                title:
                    Text('Supprimer', style: TextStyle(color: AppColors.error)),
              ),
            ),
          ],
          icon: Icon(Icons.more_vert,
              color: isDark ? AppColors.gray300 : AppColors.gray600),
          color: isDark ? AppColors.cardBgDark : AppColors.cardBgLight,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusMD,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(bool isActive, bool isDark) {
    final color = isActive ? AppColors.success : AppColors.warning;
    final text = isActive ? 'Actif' : 'Inactif';
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: AppRadius.radiusSM,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(color: color),
        textAlign: TextAlign.center,
      ),
    );
  }
}
