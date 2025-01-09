import 'package:flutter/material.dart';
import 'package:prima/services/address_service.dart';
import 'package:prima/models/address.dart';

class AddressProvider with ChangeNotifier {
  final AddressService _addressService;
  Address? _selectedAddress;
  List<Address> _addresses = [];

  AddressProvider(this._addressService);

  Address? get selectedAddress => _selectedAddress;
  List<Address> get addresses => _addresses;

  Future<void> addAddress({
    required String name,
    required String street,
    required String city,
    required String postalCode,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    try {
      final newAddress = await _addressService.createAddress(
        name: name,
        street: street,
        city: city,
        postalCode: postalCode,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
      );
      _addresses.add(newAddress);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to add address: $e');
    }
  }

  Future<void> updateAddress({
    required String id,
    required String name,
    required String street,
    required String city,
    required String postalCode,
    double? latitude,
    double? longitude,
    required bool isDefault,
  }) async {
    try {
      final updatedAddress = await _addressService.updateAddress(
        id: id,
        name: name,
        street: street,
        city: city,
        postalCode: postalCode,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
      );

      final index = _addresses.indexWhere((a) => a.id == id);
      if (index != -1) {
        _addresses[index] = updatedAddress;
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to update address: $e');
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      await _addressService.deleteAddress(id);
      _addresses.removeWhere((a) => a.id == id);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete address: $e');
    }
  }

  void selectAddress(Address address) {
    _selectedAddress = address;
    notifyListeners();
  }

  Future<void> loadAddresses() async {
    try {
      _addresses = await _addressService.getAddresses();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load addresses: $e');
    }
  }
}
