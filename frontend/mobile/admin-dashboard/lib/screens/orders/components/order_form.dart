import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';
import '../../../models/order.dart';
import '../../../models/enums.dart' hide AppButtonVariant;
import '../../../widgets/shared/app_button.dart';
import '../../../widgets/shared/app_dropdown.dart';
import '../../../widgets/shared/app_text_field.dart';

class OrderForm extends StatefulWidget {
  final Order? orderToEdit; // null pour une nouvelle commande

  const OrderForm({Key? key, this.orderToEdit}) : super(key: key);

  @override
  _OrderFormState createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  final controller = Get.find<OrdersController>();
  final formKey = GlobalKey<FormState>();

  // Contrôleurs de formulaire
  late TextEditingController clientSearchController;
  late TextEditingController addressController;
  List<Map<String, dynamic>> selectedItems = [];
  PaymentMethod selectedPaymentMethod = PaymentMethod.CASH;

  @override
  void initState() {
    super.initState();
    clientSearchController = TextEditingController();
    addressController = TextEditingController();

    // Si on édite une commande existante
    if (widget.orderToEdit != null) {
      clientSearchController.text = widget.orderToEdit!.customerName ?? '';
      addressController.text = widget.orderToEdit!.address?.name ?? '';
      selectedPaymentMethod = widget.orderToEdit!.paymentMethod;
      // Charger les articles existants
      if (widget.orderToEdit!.items != null) {
        selectedItems = widget.orderToEdit!.items!
            .map((item) => {
                  'articleId': item.articleId,
                  'quantity': item.quantity,
                  'isPremium': false, // À adapter selon votre logique
                })
            .toList();
      }
    }

    // Charger les données nécessaires
    controller.loadClients();
    controller.loadArticles();
    controller.loadServices();
  }

  @override
  void dispose() {
    clientSearchController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 800,
      padding: EdgeInsets.all(defaultPadding),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.orderToEdit == null
                  ? 'Nouvelle Commande'
                  : 'Modifier la Commande',
              style: AppTextStyles.h2,
            ),
            SizedBox(height: defaultPadding),

            // Recherche client
            _buildClientSearch(),
            SizedBox(height: defaultPadding),

            // Adresse de livraison
            _buildAddressSection(),
            SizedBox(height: defaultPadding),

            // Articles
            _buildArticlesSection(),
            SizedBox(height: defaultPadding),

            // Mode de paiement
            _buildPaymentSection(),
            SizedBox(height: defaultPadding * 2),

            // Total et boutons
            _buildTotalSection(),
            SizedBox(height: defaultPadding),

            // Actions
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildClientSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Client', style: AppTextStyles.bodyBold),
        SizedBox(height: AppSpacing.sm),
        Obx(() => AppDropdown<String>(
              hint: 'Sélectionner un client',
              value: controller.selectedClientId.value,
              items: controller.clients
                  .map((client) => DropdownMenuItem(
                        value: client.id,
                        child: Text('${client.firstName} ${client.lastName}'),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.selectClient(value);
                  // Charger les adresses du client
                  controller.loadClientAddresses(value);
                }
              },
            )),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Adresse de livraison', style: AppTextStyles.bodyBold),
        SizedBox(height: AppSpacing.sm),
        Obx(() => AppDropdown<String>(
              hint: 'Sélectionner une adresse',
              value: controller.selectedAddressId.value,
              items: controller.clientAddresses
                  .map((address) => DropdownMenuItem(
                        value: address.id,
                        child: Text(address.name),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.selectAddress(value);
                }
              },
            )),
      ],
    );
  }

  Widget _buildArticlesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Articles', style: AppTextStyles.bodyBold),
            AppButton(
              label: 'Ajouter un article',
              icon: Icons.add,
              onPressed: _showArticleSelector,
              variant: AppButtonVariant.secondary,
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        // Liste des articles sélectionnés
        Obx(() => ListView.builder(
              shrinkWrap: true,
              itemCount: controller.selectedItems.length,
              itemBuilder: (context, index) {
                final item = controller.selectedItems[index];
                final article = controller.articles
                    .firstWhere((a) => a.id == item['articleId']);

                return Card(
                  child: ListTile(
                    title: Text(article.name),
                    subtitle: Text('Quantité: ${item['quantity']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Switch Premium/Base
                        Switch(
                          value: item['isPremium'] ?? false,
                          onChanged: (value) {
                            controller.updateItemPrice(index, value);
                          },
                        ),
                        Text(
                          item['isPremium'] ? 'Premium' : 'Base',
                          style: AppTextStyles.bodySmall,
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline),
                          onPressed: () => controller.removeItem(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mode de paiement', style: AppTextStyles.bodyBold),
        SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Radio<PaymentMethod>(
              value: PaymentMethod.CASH,
              groupValue: selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value!;
                });
              },
            ),
            Text('Espèces'),
            SizedBox(width: defaultPadding),
            Radio<PaymentMethod>(
              value: PaymentMethod.ORANGE_MONEY,
              groupValue: selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value!;
                });
              },
            ),
            Text('Orange Money'),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalSection() {
    return Obx(() => Container(
          padding: EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: AppColors.bgColor,
            borderRadius: AppRadius.radiusMD,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total:', style: AppTextStyles.h3),
              Text(
                '${controller.orderTotal.value.toStringAsFixed(2)} €',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AppButton(
          label: 'Annuler',
          onPressed: () => Get.back(),
          variant: AppButtonVariant.secondary,
        ),
        SizedBox(width: defaultPadding),
        AppButton(
          label: widget.orderToEdit == null ? 'Créer' : 'Mettre à jour',
          onPressed: _submitForm,
          variant: AppButtonVariant.primary,
        ),
      ],
    );
  }

  void _showArticleSelector() {
    Get.dialog(
      Dialog(
        child: Container(
          width: 600,
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Ajouter un article', style: AppTextStyles.h3),
              SizedBox(height: defaultPadding),
              // Liste des articles disponibles
              Obx(() => ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.articles.length,
                    itemBuilder: (context, index) {
                      final article = controller.articles[index];
                      return ListTile(
                        title: Text(article.name),
                        subtitle: Text(
                            'Prix: ${article.basePrice}€ (Base) / ${article.premiumPrice}€ (Premium)'),
                        trailing: AppButton(
                          label: 'Ajouter',
                          onPressed: () {
                            controller.addItem(article.id);
                            Get.back();
                          },
                          variant: AppButtonVariant.secondary,
                        ),
                      );
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (formKey.currentState!.validate()) {
      final orderData = {
        'clientId': controller.selectedClientId.value,
        'addressId': controller.selectedAddressId.value,
        'items': controller.selectedItems,
        'paymentMethod': selectedPaymentMethod,
      };

      if (widget.orderToEdit != null) {
        controller.updateOrder(widget.orderToEdit!.id, orderData);
      } else {
        controller.createOrder(orderData);
      }

      Get.back();
    }
  }
}
