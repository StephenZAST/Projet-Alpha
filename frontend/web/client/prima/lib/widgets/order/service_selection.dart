import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prima/providers/service_provider.dart';
import 'package:prima/models/service.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/widgets/connection_error_widget.dart';

class ServiceSelection extends StatelessWidget {
  final Service? selectedService;
  final Function(Service) onServiceSelected;

  const ServiceSelection({
    Key? key,
    this.selectedService,
    required this.onServiceSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceProvider>(
      builder: (context, serviceProvider, _) {
        if (serviceProvider.error != null) {
          return ConnectionErrorWidget(
            onRetry: () => serviceProvider.loadServices(),
            customMessage: 'Impossible de charger les services',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: serviceProvider.services.length,
          itemBuilder: (context, index) {
            final service = serviceProvider.services[index];
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_laundry_service,
                    color: isSelected ? AppColors.primary : AppColors.gray500,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      service.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.gray800,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Text(
                    '${service.price}€',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.gray600,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              if (service.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  service.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.gray600,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
