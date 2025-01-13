import 'package:flutter/material.dart';
import 'package:prima/redux/states/app_state.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/home-components/app_bar.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../../redux/store.dart';
import '../../redux/actions/profile_actions.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Charger le profil au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StoreProvider.of<AppState>(context).dispatch(LoadProfileAction());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      body: SafeArea(
        child: Column(
          children: [
            AppBarComponent(
              title: 'Profile',
              onMenuPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            Expanded(
              child: StoreConnector<AppState, _ViewModel>(
                converter: (Store<AppState> store) =>
                    _ViewModel.fromStore(store),
                builder: (context, vm) {
                  if (vm.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (vm.error != null) {
                    return Center(child: Text('Error: ${vm.error}'));
                  }

                  if (vm.profile == null) {
                    return const Center(child: Text('No profile data'));
                  }

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildProfileItem('Name',
                          '${vm.profile!['first_name']} ${vm.profile!['last_name']}'),
                      _buildProfileItem('Email', vm.profile!['email']),
                      _buildProfileItem('Phone', vm.profile!['phone']),
                      _buildProfileItem('Address', vm.profile!['address']),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => vm.updateProfile({
                          ...vm.profile!,
                          'last_updated': DateTime.now().toIso8601String(),
                        }),
                        child: const Text('Update Profile'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String? value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.gray600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value ?? 'Not set',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.gray800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewModel {
  final Map<String, dynamic>? profile;
  final bool isLoading;
  final String? error;
  final Function(Map<String, dynamic>) updateProfile;

  _ViewModel({
    required this.profile,
    required this.isLoading,
    required this.error,
    required this.updateProfile,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      profile: store.state.profileState.profile,
      isLoading: store.state.profileState.isLoading,
      error: store.state.profileState.error,
      updateProfile: (profile) => store.dispatch(UpdateProfileAction(profile)),
    );
  }
}
