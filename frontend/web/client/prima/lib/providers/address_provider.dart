import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class Address {
  final String id;
  final String street;
  final String city;
  final String postalCode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final String name;

  Address({
    required this.id,
    required this.street,
    required this.city,
    required this.postalCode,
    this.latitude,
    this.longitude,
    required this.isDefault,
    required this.name,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      street: json['street'],
      city: json['city'],
      postalCode: json['postalCode'],
      latitude: json['gpsLatitude'],
      longitude: json['gpsLongitude'],
      isDefault: json['isDefault'],
      name: json['name'],
    );
  }
}

class AddressProvider extends ChangeNotifier {
  final Dio _dio = Dio();
  final String baseUrl = 'http://localhost:3001/api';
  final List<Address> _addresses = [];
  Address? _selectedAddress;
  bool _isLoading = false;

  List<Address> get addresses => _addresses;
  Address? get selectedAddress => _selectedAddress;
  bool get isLoading => _isLoading;

  Future<void> fetchAddresses() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _dio.get('$baseUrl/address/all');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        _addresses.clear();
        _addresses.addAll(
          data.map((json) => Address.fromJson(json)).toList(),
        );
      }
    } catch (e) {
      print('Error fetching addresses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAddress(String name, String street, String city,
      String postalCode, double? latitude, double? longitude) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _dio.post('$baseUrl/address/create', data: {
        'name': name,
        'street': street,
        'city': city,
        'postalCode': postalCode,
        'gpsLatitude': latitude,
        'gpsLongitude': longitude,
        'isDefault': _addresses.isEmpty,
      });

      if (response.statusCode == 200) {
        final newAddress = Address.fromJson(response.data['data']);
        _addresses.add(newAddress);
      }
    } catch (e) {
      print('Error adding address: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      await _dio.delete('$baseUrl/address/delete/$id');
      _addresses.removeWhere((address) => address.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting address: $e');
      rethrow;
    }
  }

  void selectAddress(Address address) {
    _selectedAddress = address;
    notifyListeners();
  }
}
