import 'dart:developer';

import '../../models/service.dart';

// Actions de chargement
class LoadServicesAction {}

class LoadServicesSuccessAction {
  final List<Service>? services; // Changé de ServiceModel à Service
  LoadServicesSuccessAction(this.services);
}

class LoadServicesFailureAction {
  final String error;
  LoadServicesFailureAction(this.error);
}

// Action de sélection
class SelectServiceAction {
  final Service? service; // Changé de ServiceModel à Service
  SelectServiceAction(this.service);
}

// Action de réinitialisation
class ClearSelectedServiceAction {}
