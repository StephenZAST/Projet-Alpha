import 'dart:developer';
import '../../models/service.dart';

class ServiceState {
  final List<Service> services; // Changé de ServiceModel à Service
  final Service? selectedService; // Changé de ServiceModel à Service
  final bool isLoading;
  final String? error;

  ServiceState({
    this.services = const [], // Valeur par défaut
    this.selectedService,
    this.isLoading = false,
    this.error,
  });

  ServiceState copyWith({
    List<Service>? services, // Changé de ServiceModel à Service
    Service? selectedService, // Changé de ServiceModel à Service
    bool? isLoading,
    String? error,
  }) {
    return ServiceState(
      services: services ?? this.services,
      selectedService: selectedService ?? this.selectedService,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
