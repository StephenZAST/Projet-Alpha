import 'package:shared_preferences/shared_preferences.dart';
import '../models/address.dart';
import 'dart:convert';

class AddressDataProvider {
  final SharedPreferences prefs;
  static const String KEY_ADDRESSES = 'stored_addresses';

  AddressDataProvider(this.prefs);

  Future<void> saveAddresses(List<Address> addresses) async {
    final addressesJson = addresses.map((addr) => addr.toJson()).toList();
    await prefs.setString(KEY_ADDRESSES, json.encode(addressesJson));
  }

  Future<List<Address>> getStoredAddresses() async {
    final String? addressesJson = prefs.getString(KEY_ADDRESSES);
    if (addressesJson == null) return [];

    final List<dynamic> addressesList = json.decode(addressesJson);
    return addressesList.map((json) => Address.fromJson(json)).toList();
  }

  Future<void> clearAddresses() async {
    await prefs.remove(KEY_ADDRESSES);
  }
}
