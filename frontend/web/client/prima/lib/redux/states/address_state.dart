import 'package:prima/models/address.dart';

class AddressState {
  final List<Address> addresses;
  final Address? selectedAddress;
  final bool isLoading;
  final String? error;

  AddressState({
    this.addresses = const [],
    this.selectedAddress,
    this.isLoading = false,
    this.error,
  });

  AddressState copyWith({
    List<Address>? addresses,
    Address? selectedAddress,
    bool? isLoading,
    String? error,
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
