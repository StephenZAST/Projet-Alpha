import 'package:prima/redux/states/app_state.dart';
import 'package:redux/redux.dart';
import 'package:dio/dio.dart';
import '../store.dart';
import '../actions/profile_actions.dart';
import '../../providers/profile_data_provider.dart';

class ProfileMiddleware {
  final Dio dio;
  final ProfileDataProvider profileDataProvider;

  ProfileMiddleware(this.dio, this.profileDataProvider);

  List<Middleware<AppState>> createMiddleware() {
    return [
      TypedMiddleware<AppState, LoadProfileAction>(_handleLoadProfile),
      TypedMiddleware<AppState, UpdateProfileAction>(_handleUpdateProfile),
    ];
  }

  void _handleLoadProfile(
    Store<AppState> store,
    LoadProfileAction action,
    NextDispatcher next,
  ) async {
    next(action);

    try {
      final response = await dio.get('/api/profile');

      if (response.statusCode == 200) {
        final profileData = response.data['data'];
        await profileDataProvider.updateProfile(profileData);
        store.dispatch(LoadProfileSuccessAction(profileData));
      } else {
        store.dispatch(LoadProfileFailureAction(
          response.data['error'] ?? 'Failed to load profile',
        ));
      }
    } catch (e) {
      store.dispatch(LoadProfileFailureAction(e.toString()));
    }
  }

  void _handleUpdateProfile(
    Store<AppState> store,
    UpdateProfileAction action,
    NextDispatcher next,
  ) async {
    next(action);

    try {
      final response = await dio.put(
        '/api/profile',
        data: action.profile,
      );

      if (response.statusCode == 200) {
        final updatedProfile = response.data['data'];
        await profileDataProvider.updateProfile(updatedProfile);
        store.dispatch(UpdateProfileSuccessAction(updatedProfile));
      } else {
        store.dispatch(UpdateProfileFailureAction(
          response.data['error'] ?? 'Failed to update profile',
        ));
      }
    } catch (e) {
      store.dispatch(UpdateProfileFailureAction(e.toString()));
    }
  }
}
