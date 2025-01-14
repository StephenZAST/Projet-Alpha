import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:prima/redux/states/app_state.dart';
import 'package:redux/redux.dart';
import '../redux/actions/address_actions.dart';
import '../models/address.dart';

class AddressCard extends StatelessWidget {
  final Address address;

  const AddressCard(
      {Key? key,
      required this.address,
      required Null Function() onTap,
      required Null Function() onEdit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel.fromStore(store, address),
      builder: (context, vm) {
        return Card(
          // ...existing card styling...
          child: ListTile(
            selected: vm.isSelected,
            onTap: () => vm.selectAddress(address),
            // ...existing tile content...
            trailing: PopupMenuButton(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    vm.editAddress(address);
                    break;
                  case 'delete':
                    vm.deleteAddress(address.id);
                    break;
                }
              },
              itemBuilder: (context) => [
                // ...existing menu items...
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ViewModel {
  final bool isSelected;
  final Function(Address) selectAddress;
  final Function(Address) editAddress;
  final Function(String) deleteAddress;

  _ViewModel({
    required this.isSelected,
    required this.selectAddress,
    required this.editAddress,
    required this.deleteAddress,
  });

  static _ViewModel fromStore(Store<AppState> store, Address address) {
    return _ViewModel(
      isSelected: store.state.addressState.selectedAddress?.id == address.id,
      selectAddress: (address) => store.dispatch(SelectAddressAction(address)),
      editAddress: (address) => store.dispatch(UpdateAddressAction(
        id: address.id,
        name: address.name,
        street: address.street ?? '',
        city: address.city,
        postalCode: address.postalCode ?? '',
        isDefault: address.isDefault,
      )),
      deleteAddress: (id) => store.dispatch(DeleteAddressAction(id)),
    );
  }
}
