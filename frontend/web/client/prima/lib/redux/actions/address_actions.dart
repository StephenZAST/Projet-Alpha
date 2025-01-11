import 'package:prima/models/address.dart';

// Actions de chargement
class LoadAddressesAction {}

class LoadAddressesSuccessAction {
  final List<Address> addresses;
  LoadAddressesSuccessAction(this.addresses);
}

class LoadAddressesFailureAction {
  final String error;
  LoadAddressesFailureAction(this.error);
}

// Actions de sélection
class SelectAddressAction {
  final Address address;
  SelectAddressAction(this.address);
}

// Actions de création
class AddAddressAction {
  final String name;
  final String street;
  final String city;
  final String postalCode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  AddAddressAction({
    required this.name,
    required this.street,
    required this.city,
    required this.postalCode,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });
}

class AddAddressSuccessAction {
  final Address address;
  AddAddressSuccessAction(this.address);
}

class AddAddressFailureAction {
  final String error;
  AddAddressFailureAction(this.error);
}

// Actions de mise à jour
class UpdateAddressAction {
  final String id;
  final String name;
  final String street;
  final String city;
  final String postalCode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  UpdateAddressAction({
    required this.id,
    required this.name,
    required this.street,
    required this.city,
    required this.postalCode,
    this.latitude,
    this.longitude,
    required this.isDefault,
  });
}

class UpdateAddressSuccessAction {
  final Address address;
  UpdateAddressSuccessAction(this.address);
}

class UpdateAddressFailureAction {
  final String error;
  UpdateAddressFailureAction(this.error);
}

// Actions de suppression
class DeleteAddressAction {
  final String id;
  DeleteAddressAction(this.id);
}

class DeleteAddressSuccessAction {
  final String id;
  DeleteAddressSuccessAction(this.id);
}

class DeleteAddressFailureAction {
  final String error;
  DeleteAddressFailureAction(this.error);
}
