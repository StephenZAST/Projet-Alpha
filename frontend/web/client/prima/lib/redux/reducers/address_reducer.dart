import '../states/address_state.dart';
import '../actions/address_actions.dart';
import '../../models/address.dart';

AddressState addressReducer(AddressState state, dynamic action) {
  if (action is LoadAddressesAction) {
    return state.copyWith(
      isLoading: true,
      error: null,
    );
  }

  if (action is LoadAddressesSuccessAction) {
    return state.copyWith(
      isLoading: false,
      addresses: action.addresses,
      selectedAddress: action.addresses.isNotEmpty
          ? action.addresses.firstWhere(
              (addr) => addr.isDefault,
              orElse: () => action.addresses.first,
            )
          : null,
      error: null,
    );
  }

  if (action is LoadAddressesFailureAction) {
    return state.copyWith(
      isLoading: false,
      error: action.error,
    );
  }

  if (action is SelectAddressAction) {
    return state.copyWith(
      selectedAddress: action.address,
    );
  }

  if (action is AddAddressSuccessAction) {
    List<Address> newAddresses = List.from(state.addresses)
      ..add(action.address);
    return state.copyWith(
      addresses: newAddresses,
      selectedAddress:
          action.address.isDefault ? action.address : state.selectedAddress,
      isLoading: false,
    );
  }

  if (action is UpdateAddressSuccessAction) {
    List<Address> updatedAddresses = state.addresses.map((address) {
      return address.id == action.address.id ? action.address : address;
    }).toList();

    return state.copyWith(
      addresses: updatedAddresses,
      selectedAddress: state.selectedAddress?.id == action.address.id
          ? action.address
          : state.selectedAddress,
      isLoading: false,
    );
  }

  if (action is DeleteAddressSuccessAction) {
    List<Address> remainingAddresses =
        state.addresses.where((address) => address.id != action.id).toList();

    return state.copyWith(
      addresses: remainingAddresses,
      selectedAddress: state.selectedAddress?.id == action.id
          ? (remainingAddresses.isNotEmpty ? remainingAddresses.first : null)
          : state.selectedAddress,
      isLoading: false,
    );
  }

  return state;
}
