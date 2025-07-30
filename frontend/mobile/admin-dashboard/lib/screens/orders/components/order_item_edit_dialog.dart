import 'package:flutter/material.dart';
import 'package:admin/models/order.dart';
import 'package:admin/models/article.dart';
import 'package:admin/models/service.dart';
import 'package:admin/widgets/shared/glass_button.dart';
import 'package:get/get.dart';

class OrderItemEditDialog extends StatefulWidget {
  final OrderItem? item;
  final List<Article> availableArticles;
  final List<Service> availableServices;
  const OrderItemEditDialog({
    Key? key,
    this.item,
    required this.availableArticles,
    required this.availableServices,
  }) : super(key: key);

  @override
  State<OrderItemEditDialog> createState() => _OrderItemEditDialogState();
}

class _OrderItemEditDialogState extends State<OrderItemEditDialog> {
  Article? selectedArticle;
  String? selectedServiceId;
  late TextEditingController quantityController;
  late TextEditingController unitPriceController;
  bool isPremium = false;

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
    isPremium = widget.item?.isPremium ?? false;
    unitPriceController = TextEditingController(text: '0');
    _updateUnitPrice();
  }

  void _updateUnitPrice() {
    double price = 0;
    if (selectedArticle != null) {
      if (isPremium && selectedArticle!.premiumPrice != null) {
        price = selectedArticle!.premiumPrice!;
      } else {
        price = selectedArticle!.basePrice;
      }
    }
    unitPriceController.text = price.toString();
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
                  selectedServiceId = '';
                  _updateUnitPrice();
                });
              },
              decoration: InputDecoration(labelText: 'Article / Service'),
            ),
            const SizedBox(height: 12),
            if (selectedArticle != null &&
                selectedArticle!.premiumPrice != null)
              Row(
                children: [
                  Switch(
                    value: isPremium,
                    onChanged: (val) {
                      setState(() {
                        isPremium = val;
                        _updateUnitPrice();
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Text('Prix premium'),
                ],
              ),
            if (selectedArticle != null &&
                selectedArticle!.premiumPrice != null)
              const SizedBox(height: 12),
            // Sélection dynamique du service (tous les services disponibles)
            if (widget.availableServices.isNotEmpty)
              DropdownButtonFormField<String>(
                value: selectedServiceId != '' ? selectedServiceId : null,
                items: widget.availableServices.map((service) {
                  return DropdownMenuItem<String>(
                    value: service.id,
                    child: Text(service.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedServiceId = value;
                    _updateUnitPrice();
                  });
                },
                decoration: InputDecoration(labelText: 'Service'),
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
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Prix unitaire (FCFA)',
                suffixIcon: Icon(Icons.lock_outline, size: 18),
              ),
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
                      isPremium: isPremium,
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
