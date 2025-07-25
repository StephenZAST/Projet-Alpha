import 'package:flutter/material.dart';
import 'package:admin/models/order.dart';
import 'package:admin/widgets/shared/glass_button.dart';
import '../../../constants.dart';

class OrderItemsEditDialog extends StatefulWidget {
  final List<OrderItem> items;
  const OrderItemsEditDialog({Key? key, required this.items}) : super(key: key);

  @override
  State<OrderItemsEditDialog> createState() => _OrderItemsEditDialogState();
}

class _OrderItemsEditDialogState extends State<OrderItemsEditDialog> {
  late List<OrderItem> editedItems;

  @override
  void initState() {
    super.initState();
    editedItems = List<OrderItem>.from(widget.items);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Modifier les articles/services',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (editedItems.isEmpty)
              Text('Aucun article/service',
                  style: AppTextStyles.bodySmallSecondary)
            else
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: editedItems.length,
                  separatorBuilder: (_, __) => Divider(),
                  itemBuilder: (context, index) {
                    final item = editedItems[index];
                    return Row(
                      children: [
                        Expanded(
                            child: Text(item.article?.name ?? '',
                                style: AppTextStyles.bodyMedium)),
                        SizedBox(width: 8),
                        Text('x${item.quantity}',
                            style: AppTextStyles.bodySmallSecondary),
                        SizedBox(width: 8),
                        Text('${item.unitPrice} FCFA',
                            style: AppTextStyles.bodySmallSecondary),
                        IconButton(
                          icon: Icon(Icons.edit, color: AppColors.info),
                          onPressed: () {
                            // TODO: ouvrir un sous-dialogue pour éditer l'article/service
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: AppColors.error),
                          onPressed: () {
                            setState(() {
                              editedItems.removeAt(index);
                            });
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            GlassButton(
              label: 'Ajouter un article/service',
              icon: Icons.add,
              variant: GlassButtonVariant.success,
              onPressed: () {
                // TODO: ouvrir un sous-dialogue pour ajouter un nouvel article/service
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GlassButton(
                  label: 'Annuler',
                  variant: GlassButtonVariant.secondary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 12),
                GlassButton(
                  label: 'Enregistrer',
                  variant: GlassButtonVariant.primary,
                  onPressed: () {
                    // TODO: enregistrer les modifications
                    Navigator.of(context).pop(editedItems);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
