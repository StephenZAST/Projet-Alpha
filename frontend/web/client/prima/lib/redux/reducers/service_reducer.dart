import '../states/service_state.dart';
import '../actions/service_actions.dart';

ServiceState serviceReducer(ServiceState state, dynamic action) {
  if (action is LoadServicesAction) {
    return state.copyWith(
      isLoading: true,
      error: null,
    );
  }

  if (action is LoadServicesSuccessAction) {
    return state.copyWith(
      services: action.services,
      isLoading: false,
      error: null,
    );
  }

  if (action is LoadServicesFailureAction) {
    return state.copyWith(
      isLoading: false,
      error: action.error,
    );
  }

  if (action is SelectServiceAction) {
    return state.copyWith(
      selectedService: action.service,
    );
  }

  if (action is ClearSelectedServiceAction) {
    return state.copyWith(
      selectedService: null,
    );
  }

  return state;
}
