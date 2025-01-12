import 'dart:developer';
import '../../models/service.dart';

class ServiceState {
  final List<ServiceModel>? services; // Rendre nullable
  final ServiceModel? selectedService;
  final bool isLoading;
  final String? error;

  ServiceState({
    this.services = const [], // Valeur par défaut
    this.selectedService,
    this.isLoading = false,
    this.error,
  });

  ServiceState copyWith({
    List<ServiceModel>? services, // Déjà nullable
    ServiceModel? selectedService,
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
