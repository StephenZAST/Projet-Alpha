import 'package:redux/redux.dart';
import 'package:dio/dio.dart';
import '../store.dart';
import '../actions/address_actions.dart';
import '../../services/address_service.dart';

class AddressMiddleware {
  final Dio dio;
  final AddressService addressService;

  AddressMiddleware(this.dio) : addressService = AddressService(dio);

  List<Middleware<AppState>> createMiddleware() {
    return [
      TypedMiddleware<AppState, LoadAddressesAction>(_handleLoadAddresses),
      TypedMiddleware<AppState, AddAddressAction>(_handleAddAddress),
      TypedMiddleware<AppState, UpdateAddressAction>(_handleUpdateAddress),
      TypedMiddleware<AppState, DeleteAddressAction>(_handleDeleteAddress),
    ];
  }

  void _handleLoadAddresses(
    Store<AppState> store,
    LoadAddressesAction action,
    NextDispatcher next,
  ) async {
    next(action);

    try {
      final addresses = await addressService.getAddresses();
      store.dispatch(LoadAddressesSuccessAction(addresses));
    } catch (e) {
      store.dispatch(LoadAddressesFailureAction(e.toString()));
    }
  }

  void _handleAddAddress(
    Store<AppState> store,
    AddAddressAction action,
    NextDispatcher next,
  ) async {
    next(action);

    try {
      final address = await addressService.createAddress(
        name: action.name,
        street: action.street,
        city: action.city,
        postalCode: action.postalCode,
        latitude: action.latitude,
        longitude: action.longitude,
        isDefault: action.isDefault,
      );
      store.dispatch(AddAddressSuccessAction(address));
    } catch (e) {
      store.dispatch(AddAddressFailureAction(e.toString()));
    }
  }

  void _handleUpdateAddress(
    Store<AppState> store,
    UpdateAddressAction action,
    NextDispatcher next,
  ) async {
    next(action);

    try {
      final address = await addressService.updateAddress(
        id: action.id,
        name: action.name,
        street: action.street,
        city: action.city,
        postalCode: action.postalCode,
        latitude: action.latitude,
        longitude: action.longitude,
        isDefault: action.isDefault,
      );
      store.dispatch(UpdateAddressSuccessAction(address));
    } catch (e) {
      store.dispatch(UpdateAddressFailureAction(e.toString()));
    }
  }

  void _handleDeleteAddress(
    Store<AppState> store,
    DeleteAddressAction action,
    NextDispatcher next,
  ) async {
    next(action);

    try {
      await addressService.deleteAddress(action.id);
      store.dispatch(DeleteAddressSuccessAction(action.id));
    } catch (e) {
      store.dispatch(DeleteAddressFailureAction(e.toString()));
    }
  }
}
