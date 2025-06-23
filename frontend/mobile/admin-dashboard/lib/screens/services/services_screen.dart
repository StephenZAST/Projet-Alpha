import 'package:admin/screens/services/components/service_card.dart';
import 'package:admin/screens/services/components/service_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/service_controller.dart';
import '../../widgets/shared/glass_button.dart';

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
              // Header moderne avec titre, bouton glassy et refresh
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Services',
                    style: AppTextStyles.h1.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Row(
                    children: [
                      GlassButton(
                        label: 'Nouveau service',
                        icon: Icons.add,
                        variant: GlassButtonVariant.primary,
                        onPressed: () => Get.dialog(ServiceFormScreen()),
                      ),
                      const SizedBox(width: 8),
                      GlassButton(
                        icon: Icons.refresh,
                        label: '',
                        variant: GlassButtonVariant.secondary,
                        size: GlassButtonSize.small,
                        onPressed: controller.fetchServices,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Barre de recherche modernisée
              Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.7),
                    borderRadius: AppRadius.radiusSM,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: controller.searchServices,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un service...',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

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
