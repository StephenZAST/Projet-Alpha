import 'package:admin/services/api_service.dart';
import 'package:admin/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:admin/widgets/shared/glass_button.dart';
import '../../../../../models/user.dart';
import '../../../../../controllers/users_controller.dart';
import '../../../../../models/address.dart';
import '../../../../../services/address_service.dart';
import '../../../users/components/address_edit_dialog.dart';

class ClientDetailsDialog extends StatefulWidget {
  final User client;
  const ClientDetailsDialog({Key? key, required this.client}) : super(key: key);

  @override
  State<ClientDetailsDialog> createState() => _ClientDetailsDialogState();
}

class _ClientDetailsDialogState extends State<ClientDetailsDialog> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  bool isSaving = false;
  List<Address> _addresses = [];
  bool isLoadingAddresses = false;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.client.firstName);
    lastNameController = TextEditingController(text: widget.client.lastName);
    emailController = TextEditingController(text: widget.client.email);
    phoneController = TextEditingController(text: widget.client.phone ?? '');
    _loadAddresses();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    setState(() => isLoadingAddresses = true);
    try {
      _addresses = await UserService.getUserAddresses(widget.client.id);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les adresses');
    }
    setState(() => isLoadingAddresses = false);
  }

  Future<void> _resetUserPassword() async {
    try {
      final data = await UserService.adminResetUserPassword(widget.client.id);
      final user = data['user'];
      final tempPassword = data['tempPassword'];
      await Get.dialog(_PasswordResetResultDialog(
        user: user,
        tempPassword: tempPassword,
      ));
    } catch (e) {
      Get.snackbar('Erreur', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Détails du client',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              _buildEditForm(),
              const SizedBox(height: 16),
              _buildAddressesSection(),
              const SizedBox(height: 16),
              _buildActionsSection(),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Fermer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: firstNameController,
          decoration: InputDecoration(labelText: 'Prénom'),
        ),
        TextField(
          controller: lastNameController,
          decoration: InputDecoration(labelText: 'Nom'),
        ),
        TextField(
          controller: emailController,
          decoration: InputDecoration(labelText: 'Email'),
        ),
        TextField(
          controller: phoneController,
          decoration: InputDecoration(labelText: 'Téléphone'),
        ),
        const SizedBox(height: 12),
        GlassButton(
          label: 'Enregistrer les modifications',
          variant: GlassButtonVariant.primary,
          isLoading: isSaving,
          onPressed: isSaving ? null : _saveClientInfo,
        ),
      ],
    );
  }

  Future<void> _saveClientInfo() async {
    setState(() => isSaving = true);
    // TODO: Appeler le service pour mettre à jour le client
    await Future.delayed(Duration(seconds: 1)); // Placeholder
    setState(() => isSaving = false);
    Get.snackbar('Succès', 'Informations client mises à jour');
  }

  Widget _buildAddressesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Adresses', style: Theme.of(context).textTheme.titleMedium),
            GlassButton(
              label: 'Ajouter',
              icon: Icons.add_location_alt,
              variant: GlassButtonVariant.info,
              size: GlassButtonSize.small,
              onPressed: () async {
                await Get.dialog(AddressEditDialog(
                  userId: widget.client.id,
                  onAddressSaved: (address) => _loadAddresses(),
                ));
              },
            ),
          ],
        ),
        isLoadingAddresses
            ? Center(child: CircularProgressIndicator())
            : _addresses.isEmpty
                ? Text('Aucune adresse enregistrée')
                : Column(
                    children: _addresses
                        .map((address) => ListTile(
                              title: Text(address.fullAddress),
                              subtitle: Text(address.name ?? ''),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () async {
                                      await Get.dialog(AddressEditDialog(
                                        userId: widget.client.id,
                                        initialAddress: address,
                                        onAddressSaved: (a) => _loadAddresses(),
                                      ));
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () async {
                                      await AddressService.deleteAddress(
                                          address.id);
                                      _loadAddresses();
                                    },
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
      ],
    );
  }

  Widget _buildActionsSection() {
    return Row(
      children: [
        GlassButton(
          label: 'Réinitialiser le mot de passe',
          icon: Icons.lock_reset,
          variant: GlassButtonVariant.warning,
          onPressed: _resetUserPassword,
        ),
        // ...autres actions rapides à venir...
      ],
    );
  }
}

class _PasswordResetResultDialog extends StatelessWidget {
  final dynamic user;
  final String tempPassword;

  const _PasswordResetResultDialog(
      {Key? key, required this.user, required this.tempPassword})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mot de passe réinitialisé',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text('Client : ${user['firstName']} ${user['lastName']}'),
            Text('Email : ${user['email']}'),
            Text('Téléphone : ${user['phone'] ?? '-'}'),
            const SizedBox(height: 16),
            Text('Nouveau mot de passe :',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SelectableText(tempPassword,
                style: TextStyle(fontSize: 18, color: Colors.blue)),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: GlassButton(
                label: 'Copier',
                icon: Icons.copy,
                variant: GlassButtonVariant.info,
                onPressed: () {
                  final info =
                      '''Client : ${user['firstName']} ${user['lastName']}
Email : ${user['email']}
Téléphone : ${user['phone'] ?? '-'}
Nouveau mot de passe : $tempPassword''';
                  Clipboard.setData(ClipboardData(text: info));
                  Get.snackbar('Copié',
                      'Infos client et mot de passe copiés dans le presse-papier');
                },
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: GlassButton(
                label: 'Fermer',
                variant: GlassButtonVariant.secondary,
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
