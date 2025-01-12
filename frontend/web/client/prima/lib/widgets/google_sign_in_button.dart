import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../redux/store.dart';
import '../redux/actions/auth_actions.dart';
import '../theme/colors.dart';

class GoogleSignInButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel.fromStore(store),
      builder: (context, vm) {
        return ElevatedButton(
          onPressed: vm.isLoading ? null : () => vm.signInWithGoogle(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: vm.isLoading
              ? const CircularProgressIndicator()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/google_logo.png', height: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'Continue with Google',
                      style: TextStyle(color: AppColors.gray800),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _ViewModel {
  final bool isLoading;
  final Function signInWithGoogle;

  _ViewModel({required this.isLoading, required this.signInWithGoogle});

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      isLoading: store.state.authState.isLoading,
      signInWithGoogle: () => store.dispatch(GoogleSignInAction()),
    );
  }
}
