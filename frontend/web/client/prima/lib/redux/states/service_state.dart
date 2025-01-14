import '../../models/service.dart';

class ServiceState {
  final List<Service> services;
  final bool isLoading;
  final String? error;
  final Service? selectedService;

  ServiceState({
    this.services = const [],
    this.isLoading = false,
    this.error,
    this.selectedService,
  });

  ServiceState copyWith({
    List<Service>? services,
    bool? isLoading,
    String? error,
    Service? selectedService,
  }) {
    return ServiceState(
      services: services ?? this.services,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedService: selectedService ?? this.selectedService,
    );
  }
}
