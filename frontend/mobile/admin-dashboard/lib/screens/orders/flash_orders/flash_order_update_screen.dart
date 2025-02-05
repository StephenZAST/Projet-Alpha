import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';
import 'components/article_selection.dart';
import 'components/service_selection.dart';
import 'components/date_selection.dart';

class FlashOrderUpdateScreen extends StatelessWidget {
  final controller = Get.find<OrdersController>();

  bool validateForm() {
    if (controller.selectedService.value == null) {
      Get.snackbar(
        'Erreur',
        'Veuillez sélectionner un service',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
      );
      return false;
    }

    if (controller.selectedArticles.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez ajouter au moins un article',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
      );
      return false;
    }

    if (controller.collectionDate.value == null) {
      Get.snackbar(
        'Erreur',
        'Veuillez définir une date de collecte',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (controller.hasUnsavedChanges) {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Modifications non enregistrées'),
              content: Text('Voulez-vous quitter sans enregistrer ?'),
              actions: [
                TextButton(
                  child: Text('Annuler'),
                  onPressed: () => Navigator.pop(context, false),
                ),
                ElevatedButton(
                  child: Text('Quitter'),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            ),
          );
          return result ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Compléter la commande flash'),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service selection
                ServiceSelection(),
                SizedBox(height: AppSpacing.lg),

                // Articles selection
                ArticleSelection(),
                SizedBox(height: AppSpacing.lg),

                // Date selection
                DateSelection(),
                SizedBox(height: AppSpacing.xl),

                // Total and validation
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        Text(
                          'Total: ${controller.orderTotal.value.toStringAsFixed(2)} FCFA',
                          style: AppTextStyles.h3,
                        ),
                        SizedBox(height: AppSpacing.md),
                        ElevatedButton(
                          onPressed: controller.selectedService.value != null &&
                                  controller.selectedArticles.isNotEmpty
                              ? () => controller.updateFlashOrder()
                              : null,
                          child: Text('Valider la commande'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
