import 'dart:developer';

import '../../models/service.dart';

// Actions de chargement
class LoadServicesAction {}

class LoadServicesSuccessAction {
  final List<ServiceModel>? services;
  LoadServicesSuccessAction(this.services);
}

class LoadServicesFailureAction {
  final String error;
  LoadServicesFailureAction(this.error);
}

// Action de sélection
class SelectServiceAction {
  final ServiceModel? service;
  SelectServiceAction(this.service);
}

// Action de réinitialisation
class ClearSelectedServiceAction {}
