import 'package:admin/screens/services/components/service_card.dart';
import 'package:admin/screens/services/components/service_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../widgets/shared/header.dart';
import '../../widgets/shared/app_button.dart';
import '../../controllers/service_controller.dart';

class ServicesScreen extends GetView<ServiceController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec recherche
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Services',
                    style: AppTextStyles.h1.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('Nouveau service'),
                    onPressed: () => Get.dialog(ServiceFormScreen()),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),

              // Champ de recherche
              TextField(
                onChanged: controller.searchServices,
                decoration: InputDecoration(
                  hintText: 'Rechercher un service...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: AppRadius.radiusSM),
                ),
              ),
              SizedBox(height: AppSpacing.lg),

              // Liste des services
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (controller.services.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cleaning_services_outlined,
                              size: 64, color: AppColors.textSecondary),
                          SizedBox(height: AppSpacing.md),
                          Text('Aucun service disponible',
                              style: AppTextStyles.bodyLarge),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _getCrossAxisCount(context),
                      crossAxisSpacing: defaultPadding,
                      mainAxisSpacing: defaultPadding,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: controller.services.length,
                    itemBuilder: (context, index) {
                      final service = controller.services[index];
                      return ServiceCard(service: service);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 900) return 3;
    if (width > 600) return 2;
    return 1;
  }
}
