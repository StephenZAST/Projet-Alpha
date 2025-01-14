import 'package:flutter/material.dart';
import 'package:prima/providers/auth_provider.dart';
import 'package:prima/services/address_service.dart';
import 'package:prima/models/address.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

class AddressProvider extends ChangeNotifier {
  final AuthProvider _authProvider;
  final Dio _dio;
  final AddressService _addressService;
  Address? _selectedAddress;
  List<Address> _addresses = [];

  AddressProvider(this._authProvider)
      : _dio = Dio(BaseOptions(
          baseUrl: _authProvider
              .baseUrl, // Enlever le /api ici car il est déjà dans baseUrl
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        )),
        _addressService = AddressService(null) {
    // Modifié ici
    _setupInterceptors();
    _addressService.setDio(_dio); // Ajouté cette ligne
    loadAddresses(); // Charger automatiquement les adresses au démarrage
  }

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _authProvider.token;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

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
      print('Loading addresses...');
      _addresses = await _addressService.getAddresses();

      // Si une adresse par défaut existe, la sélectionner
      Address? defaultAddress;

      if (_addresses.isNotEmpty) {
        defaultAddress = _addresses.firstWhere(
          (addr) => addr.isDefault,
          orElse: () => _addresses.first,
        );
      }

      if (defaultAddress != null) {
        _selectedAddress = defaultAddress;
      }

      notifyListeners();
    } catch (e) {
      print('Error loading addresses: $e');
      _addresses = [];
      notifyListeners();
    }
  }

  void setAddresses(BuildContext context, List<Address> addresses) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?['id'];

    _addresses = addresses.where((addr) => addr.userId == userId).toList();

    if (_addresses.isNotEmpty) {
      _selectedAddress = _addresses.firstWhere(
        (addr) => addr.isDefault,
        orElse: () => _addresses.first,
      );
    }
    notifyListeners();
  }
}

final addressProviderProvider = Provider<AddressProvider>(
  (ref) {
    final authProvider = ref.read(authProviderProvider);
    return AddressProvider(authProvider);
  },
  create: (BuildContext context) {},
);
