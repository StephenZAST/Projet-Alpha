import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../widgets/shared/glass_button.dart';
import 'components/offer_form_dialog.dart';

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
    if (offers.isEmpty) {
      return Center(
        child: Text(
          "Aucune offre disponible.",
          style: AppTextStyles.bodyMedium,
        ),
      );
    }
    return ListView.separated(
      itemCount: offers.length,
      separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final offer = offers[index];
        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            title: Text(
              offer['name'] ?? '',
              style: AppTextStyles.bodyBold.copyWith(color: Colors.white),
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(offer['description'] ?? '',
                        style: AppTextStyles.bodyMedium),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        GlassButton(
                          icon: Icons.edit,
                          label: '',
                          variant: GlassButtonVariant.info,
                          size: GlassButtonSize.small,
                          onPressed: () => Get.dialog(
                            OfferFormDialog(
                              initialData: offer,
                              onSubmit: (data) {
                                // Appelle la méthode d'update via callback parent
                                if (onEdit != null) onEdit({...offer, ...data});
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        GlassButton(
                          icon: Icons.delete,
                          label: '',
                          variant: GlassButtonVariant.error,
                          size: GlassButtonSize.small,
                          onPressed: () => onDelete(offer),
                        ),
                        SizedBox(width: 8),
                        GlassButton(
                          icon: offer['isActive'] == true
                              ? Icons.toggle_on
                              : Icons.toggle_off,
                          label: '',
                          variant: offer['isActive'] == true
                              ? GlassButtonVariant.success
                              : GlassButtonVariant.warning,
                          size: GlassButtonSize.small,
                          onPressed: () => onToggleStatus(offer),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
