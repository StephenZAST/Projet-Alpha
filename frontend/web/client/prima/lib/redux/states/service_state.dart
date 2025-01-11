class ServiceState {
  final List<Service> services;
  final Service? selectedService;
  final bool isLoading;
  final String? error;

  ServiceState({
    this.services = const [],
    this.selectedService,
    this.isLoading = false,
    this.error,
  });

  ServiceState copyWith({
    List<Service>? services,
    Service? selectedService,
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
