import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../../../models/address.dart';
import '../../../constants.dart';

class UserDetailsDialog extends StatelessWidget {
  final User user;
  final List<Address> addresses;

  const UserDetailsDialog(
      {Key? key, required this.user, required this.addresses})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 650,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: isDark ? AppColors.gray900 : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                    child:
                        Icon(Icons.person, size: 36, color: AppColors.primary),
                  ),
                  SizedBox(width: 18),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${user.firstName} ${user.lastName}',
                          style: AppTextStyles.h2),
                      SizedBox(height: 6),
                      _buildRoleBadge(user.role),
                    ],
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              SizedBox(height: 18),
              _buildInfoSection(context, isDark),
              SizedBox(height: 18),
              _buildOffersSection(),
              SizedBox(height: 18),
              _buildAddressesSection(context, isDark),
              SizedBox(height: 24),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(UserRole role) {
    final color = _getRoleColor(role);
    final icon = _getRoleIcon(role);
    final label = _getRoleLabel(role);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          SizedBox(width: 4),
          Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildOffersSection() {
    // Placeholder pour les offres et abonnements
    // À remplacer par les vraies données du controller si disponibles
    return Card(
      color: AppColors.gray50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Offres & Abonnement', style: AppTextStyles.h4),
            SizedBox(height: 8),
            Text('Aucune offre ou abonnement actif.',
                style: AppTextStyles.bodySmallSecondary),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.SUPER_ADMIN:
        return Colors.deepPurple;
      case UserRole.ADMIN:
        return Colors.blue;
      case UserRole.AFFILIATE:
        return Colors.orange;
      case UserRole.CLIENT:
        return Colors.green;
      case UserRole.DELIVERY:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.SUPER_ADMIN:
        return Icons.security;
      case UserRole.ADMIN:
        return Icons.admin_panel_settings;
      case UserRole.AFFILIATE:
        return Icons.handshake;
      case UserRole.CLIENT:
        return Icons.person;
      case UserRole.DELIVERY:
        return Icons.delivery_dining;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildInfoSection(BuildContext context, bool isDark) {
    return Card(
      color: isDark ? AppColors.gray900 : AppColors.gray50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: AppColors.primary),
                SizedBox(width: 8),
                Text('${user.firstName} ${user.lastName}',
                    style: AppTextStyles.h3),
              ],
            ),
            SizedBox(height: 8),
            _buildInfoRow('ID', user.id),
            _buildInfoRow('Email', user.email),
            _buildInfoRow('Téléphone', user.phone ?? '-'),
            _buildInfoRow('Rôle', _getRoleLabel(user.role)),
            _buildInfoRow('Statut', user.isActive ? 'Actif' : 'Inactif'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
              width: 100,
              child: Text(label, style: AppTextStyles.bodySmallSecondary)),
          Text(value, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildAddressesSection(BuildContext context, bool isDark) {
    return Card(
      color: isDark ? AppColors.gray900 : AppColors.gray50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Adresses', style: AppTextStyles.h4),
            SizedBox(height: 8),
            addresses.isEmpty
                ? Text('Aucune adresse enregistrée.',
                    style: AppTextStyles.bodySmallSecondary)
                : Column(
                    children: addresses
                        .map((address) => _buildAddressItem(address))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressItem(Address address) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.location_on, color: AppColors.accent, size: 18),
          SizedBox(width: 8),
          Expanded(child: Text(address.fullAddress)),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Fermer'),
        ),
        SizedBox(width: 8),
        ElevatedButton.icon(
          icon: Icon(Icons.edit),
          label: Text('Éditer'),
          onPressed: () {
            // TODO: ouvrir le dialog d’édition utilisateur
          },
        ),
        SizedBox(width: 8),
        ElevatedButton.icon(
          icon: Icon(Icons.delete),
          label: Text('Supprimer'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () {
            // TODO: action de suppression utilisateur
          },
        ),
      ],
    );
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.SUPER_ADMIN:
        return 'Super Admin';
      case UserRole.ADMIN:
        return 'Admin';
      case UserRole.AFFILIATE:
        return 'Affilié';
      case UserRole.CLIENT:
        return 'Client';
      case UserRole.DELIVERY:
        return 'Livreur';
      default:
        return 'Inconnu';
    }
  }
}
