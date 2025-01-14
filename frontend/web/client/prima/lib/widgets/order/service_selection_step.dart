import 'package:flutter/material.dart';
import 'package:prima/models/service.dart';
import 'package:prima/providers/service_provider.dart';
import 'package:provider/provider.dart';

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
    // ... implémentation du card de service ...
  }
}
