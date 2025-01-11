import '../../widgets/order_bottom_sheet.dart';

// Actions de chargement
class LoadServicesAction {}

class LoadServicesSuccessAction {
  final List<Service> services;
  LoadServicesSuccessAction(this.services);
}

class LoadServicesFailureAction {
  final String error;
  LoadServicesFailureAction(this.error);
}

// Action de sélection
class SelectServiceAction {
  final Service service;
  SelectServiceAction(this.service);
}

// Action de réinitialisation
class ClearSelectedServiceAction {}
