import 'package:flutter/material.dart';
import 'package:admin/models/order.dart';
import 'package:admin/models/article.dart';
import 'package:admin/models/service.dart';
import 'package:admin/widgets/shared/glass_button.dart';
import 'package:get/get.dart';
import '../../../services/article_price_service.dart';

class OrderItemAdvancedDialog extends StatefulWidget {
  final OrderItem? item;
  final List<Article> availableArticles;
  final List<Service> availableServices;
  const OrderItemAdvancedDialog({
    Key? key,
    this.item,
    required this.availableArticles,
    required this.availableServices,
  }) : super(key: key);

  @override
  State<OrderItemAdvancedDialog> createState() =>
      _OrderItemAdvancedDialogState();
}

class _OrderItemAdvancedDialogState extends State<OrderItemAdvancedDialog> {
  Service? selectedService;
  Article? selectedArticle;
  Map<String, dynamic>? articleServicePrice;
  bool isPremium = false;
  bool isByWeight = false;
  late TextEditingController quantityController;
  late TextEditingController weightController;
  double calculatedUnitPrice = 0;

  @override
  void initState() {
    super.initState();
    selectedService = widget.item != null && widget.availableServices.isNotEmpty
        ? widget.availableServices
            .firstWhereOrNull((s) => s.id == widget.item!.serviceId)
        : null;
    selectedArticle = widget.item != null && widget.availableArticles.isNotEmpty
        ? widget.availableArticles
            .firstWhereOrNull((a) => a.id == widget.item!.articleId)
        : null;
    isPremium = widget.item?.isPremium ?? false;
    isByWeight = false;
    quantityController = TextEditingController(
        text: widget.item != null ? widget.item!.quantity.toString() : '1');
    weightController = TextEditingController(text: '');
    if (selectedService != null && selectedArticle != null) {
      _fetchArticleServicePrice();
    }
  }

  Future<void> _fetchArticleServicePrice() async {
    if (selectedArticle == null || selectedService == null) return;
    final price = await ArticlePriceService.getArticleServicePrice(
      articleId: selectedArticle!.id,
      serviceTypeId: selectedService!.id,
    );
    setState(() {
      articleServicePrice = price;
      _updateUnitPrice();
    });
  }

  void _updateUnitPrice() {
    if (articleServicePrice == null) {
      calculatedUnitPrice = 0;
      return;
    }
    if (isByWeight) {
      calculatedUnitPrice =
          (articleServicePrice!['pricePerKg'] ?? 0).toDouble();
    } else {
      calculatedUnitPrice = isPremium
          ? (articleServicePrice!['premiumPrice'] ?? 0).toDouble()
          : (articleServicePrice!['basePrice'] ?? 0).toDouble();
    }
  }

  @override
  void dispose() {
    quantityController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filtrer les articles compatibles avec le service sélectionné
    final compatibleArticles = selectedService == null
        ? widget.availableArticles
        : widget.availableArticles
            .where((a) =>
                a.services?.any((s) => s.id == selectedService!.id) ?? false)
            .toList();
    return Dialog(
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item == null
                  ? 'Ajouter un article/service'
                  : 'Modifier l\'article/service',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Service>(
              value: selectedService,
              items: widget.availableServices.map((service) {
                return DropdownMenuItem<Service>(
                  value: service,
                  child: Text(service.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedService = value;
                  selectedArticle = null;
                  articleServicePrice = null;
                });
              },
              decoration: InputDecoration(labelText: 'Service'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Article>(
              value: selectedArticle,
              items: compatibleArticles.map((article) {
                return DropdownMenuItem<Article>(
                  value: article,
                  child: Text(article.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedArticle = value;
                  articleServicePrice = null;
                });
                _fetchArticleServicePrice();
              },
              decoration: InputDecoration(labelText: 'Article'),
            ),
            const SizedBox(height: 12),
            if (articleServicePrice != null)
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
            if (articleServicePrice != null)
              Row(
                children: [
                  Switch(
                    value: isByWeight,
                    onChanged: (val) {
                      setState(() {
                        isByWeight = val;
                        _updateUnitPrice();
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Text('Commande au poids'),
                ],
              ),
            if (isByWeight)
              TextField(
                controller: weightController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Poids (kg)'),
              )
            else
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Quantité'),
              ),
            const SizedBox(height: 12),
            TextField(
              controller:
                  TextEditingController(text: calculatedUnitPrice.toString()),
              readOnly: true,
              decoration: InputDecoration(
                labelText:
                    isByWeight ? 'Prix au kilo (FCFA)' : 'Prix unitaire (FCFA)',
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
                    if (selectedService == null || selectedArticle == null) {
                      Get.rawSnackbar(
                        messageText: Text(
                            'Veuillez sélectionner un service et un article.'),
                        backgroundColor: Colors.red,
                        borderRadius: 12,
                        margin:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        snackPosition: SnackPosition.TOP,
                        duration: Duration(seconds: 2),
                      );
                      return;
                    }
                    if (articleServicePrice == null) {
                      Get.rawSnackbar(
                        messageText: Text(
                            'Aucun prix défini pour ce couple article/service.'),
                        backgroundColor: Colors.red,
                        borderRadius: 12,
                        margin:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        snackPosition: SnackPosition.TOP,
                        duration: Duration(seconds: 2),
                      );
                      return;
                    }
                    int? quantity;
                    double? weight;
                    if (isByWeight) {
                      weight = double.tryParse(weightController.text);
                      if (weight == null || weight <= 0) {
                        Get.rawSnackbar(
                          messageText:
                              Text('Le poids doit être un nombre positif.'),
                          backgroundColor: Colors.red,
                          borderRadius: 12,
                          margin: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          snackPosition: SnackPosition.TOP,
                          duration: Duration(seconds: 2),
                        );
                        return;
                      }
                    } else {
                      quantity = int.tryParse(quantityController.text);
                      if (quantity == null || quantity < 1) {
                        Get.rawSnackbar(
                          messageText:
                              Text('La quantité doit être un nombre positif.'),
                          backgroundColor: Colors.red,
                          borderRadius: 12,
                          margin: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          snackPosition: SnackPosition.TOP,
                          duration: Duration(seconds: 2),
                        );
                        return;
                      }
                    }
                    final newItem = OrderItem(
                      id: widget.item?.id ?? '',
                      orderId: widget.item?.orderId ?? '',
                      articleId: selectedArticle!.id,
                      serviceId: selectedService!.id,
                      article: selectedArticle,
                      quantity: quantity ?? 1,
                      unitPrice: calculatedUnitPrice,
                      isPremium: isPremium,
                      createdAt: widget.item?.createdAt ?? DateTime.now(),
                      updatedAt: DateTime.now(),
                      weight: isByWeight
                          ? double.tryParse(weightController.text)
                          : null,
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
