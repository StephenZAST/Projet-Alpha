import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/providers/notification_provider.dart';
import 'package:provider/provider.dart';

class NotificationPreferencesPage extends StatelessWidget {
  const NotificationPreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Préférences de notification'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection(
                title: 'Canaux de notification',
                children: [
                  _buildSwitchTile(
                    title: 'Notifications push',
                    value: provider.preferences.push,
                    onChanged: (value) =>
                        provider.updatePreference('push', value),
                  ),
                  _buildSwitchTile(
                    title: 'Notifications par email',
                    value: provider.preferences.email,
                    onChanged: (value) =>
                        provider.updatePreference('email', value),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Types de notifications',
                children: [
                  _buildSwitchTile(
                    title: 'Statut des commandes',
                    value: provider.preferences.orderUpdates,
                    onChanged: (value) =>
                        provider.updatePreference('orderUpdates', value),
                  ),
                  _buildSwitchTile(
                    title: 'Points de fidélité',
                    value: provider.preferences.loyalty,
                    onChanged: (value) =>
                        provider.updatePreference('loyalty', value),
                  ),
                  _buildSwitchTile(
                    title: 'Offres spéciales',
                    value: provider.preferences.promotions,
                    onChanged: (value) =>
                        provider.updatePreference('promotions', value),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.gray800,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }
}
