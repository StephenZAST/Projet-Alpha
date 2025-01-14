import 'package:flutter/material.dart';
import 'package:prima/models/service.dart';
import 'package:prima/providers/service_provider.dart';
import 'package:provider/provider.dart';
import 'package:prima/theme/colors.dart';

class ServiceSelectionStep extends StatelessWidget {
  final Function(Service) onServiceSelected;
  final Service? selectedService;

  const ServiceSelectionStep({
    Key? key,
    required this.onServiceSelected,
    this.selectedService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: AppColors.error, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Erreur: ${provider.error}',
                  style: TextStyle(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadServices(),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (provider.services.isEmpty) {
          return Center(
            child: Text(
              'Aucun service disponible',
              style: TextStyle(color: AppColors.gray600, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.services.length,
          itemBuilder: (context, index) {
            final service = provider.services[index];
            return _buildServiceCard(context, service);
          },
        );
      },
    );
  }

  Widget _buildServiceCard(BuildContext context, Service service) {
    final isSelected = selectedService?.id == service.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => onServiceSelected(service),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.gray100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_laundry_service,
                      color: isSelected ? AppColors.primary : AppColors.gray500,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.gray800,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        if (service.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            service.description!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.gray600,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (service.price != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.gray50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${service.price}€',
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.gray800,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
