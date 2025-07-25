import 'package:flutter/material.dart';
import 'package:admin/models/order.dart';
import 'package:admin/models/article.dart';
import 'package:admin/widgets/shared/glass_button.dart';
import 'package:get/get.dart';
import '../../../constants.dart';

class OrderItemEditDialog extends StatefulWidget {
  final OrderItem? item;
  final List<Article> availableArticles;
  const OrderItemEditDialog(
      {Key? key, this.item, required this.availableArticles})
      : super(key: key);

  @override
  State<OrderItemEditDialog> createState() => _OrderItemEditDialogState();
}

class _OrderItemEditDialogState extends State<OrderItemEditDialog> {
  Article? selectedArticle;
  String? selectedServiceId;
  late TextEditingController quantityController;
  late TextEditingController unitPriceController;

  @override
  void initState() {
    super.initState();
    selectedArticle = widget.item?.article ??
        (widget.availableArticles.isNotEmpty
            ? widget.availableArticles.first
            : null);
    selectedServiceId = widget.item?.serviceId ?? '';
    quantityController =
        TextEditingController(text: widget.item?.quantity.toString() ?? '1');
    unitPriceController = TextEditingController(
        text: widget.item?.unitPrice.toString() ??
            (selectedArticle?.basePrice.toString() ?? '0'));
  }

  @override
  void dispose() {
    quantityController.dispose();
    unitPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                widget.item == null
                    ? 'Ajouter un article/service'
                    : 'Modifier l\'article/service',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            DropdownButtonFormField<Article>(
              value: selectedArticle,
              items: widget.availableArticles.map((article) {
                return DropdownMenuItem<Article>(
                  value: article,
                  child: Text(article.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedArticle = value;
                  unitPriceController.text = value?.basePrice.toString() ?? '0';
                  selectedServiceId = '';
                });
              },
              decoration: InputDecoration(labelText: 'Article / Service'),
            ),
            const SizedBox(height: 12),
            // Sélection du service lié à l'article (si applicable)
            if (selectedArticle != null &&
                selectedArticle!.services != null &&
                selectedArticle!.services!.isNotEmpty)
              DropdownButtonFormField<String>(
                value: selectedServiceId != '' ? selectedServiceId : null,
                items: selectedArticle!.services!.map((service) {
                  return DropdownMenuItem<String>(
                    value: service.id,
                    child: Text(service.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedServiceId = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Service lié'),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Quantité'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: unitPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Prix unitaire (FCFA)'),
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
                  label: widget.item == null ? 'Ajouter' : 'Enregistrer',
                  variant: GlassButtonVariant.primary,
                  onPressed: () {
                    // Validation des champs obligatoires
                    if (selectedArticle == null) {
                      Get.rawSnackbar(
                        messageText:
                            Text('Veuillez sélectionner un article/service.'),
                        backgroundColor: Colors.red,
                        borderRadius: 12,
                        margin:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        snackPosition: SnackPosition.TOP,
                        duration: Duration(seconds: 2),
                      );
                      return;
                    }
                    if (selectedArticle!.services != null &&
                        selectedArticle!.services!.isNotEmpty &&
                        (selectedServiceId == null ||
                            selectedServiceId == '')) {
                      Get.rawSnackbar(
                        messageText:
                            Text('Veuillez sélectionner le service lié.'),
                        backgroundColor: Colors.red,
                        borderRadius: 12,
                        margin:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        snackPosition: SnackPosition.TOP,
                        duration: Duration(seconds: 2),
                      );
                      return;
                    }
                    final quantity = int.tryParse(quantityController.text);
                    if (quantity == null || quantity < 1) {
                      Get.rawSnackbar(
                        messageText:
                            Text('La quantité doit être un nombre positif.'),
                        backgroundColor: Colors.red,
                        borderRadius: 12,
                        margin:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        snackPosition: SnackPosition.TOP,
                        duration: Duration(seconds: 2),
                      );
                      return;
                    }
                    final unitPrice = double.tryParse(unitPriceController.text);
                    if (unitPrice == null || unitPrice < 0) {
                      Get.rawSnackbar(
                        messageText: Text(
                            'Le prix unitaire doit être un nombre positif.'),
                        backgroundColor: Colors.red,
                        borderRadius: 12,
                        margin:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        snackPosition: SnackPosition.TOP,
                        duration: Duration(seconds: 2),
                      );
                      return;
                    }
                    // Création de l'OrderItem avec tous les champs requis
                    final newItem = OrderItem(
                      id: widget.item?.id ?? '',
                      orderId: widget.item?.orderId ?? '',
                      articleId: selectedArticle!.id,
                      serviceId: selectedServiceId ?? '',
                      article: selectedArticle,
                      quantity: quantity,
                      unitPrice: unitPrice,
                      createdAt: widget.item?.createdAt ?? DateTime.now(),
                      updatedAt: DateTime.now(),
                      // Ajoute d'autres champs si besoin
                    );
                    Navigator.of(context).pop(newItem);
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
