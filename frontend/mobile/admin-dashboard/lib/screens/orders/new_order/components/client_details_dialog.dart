import 'package:admin/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:admin/widgets/shared/glass_button.dart';
import 'package:admin/widgets/shared/glass_container.dart';
import '../../../../../models/user.dart';
import '../../../../../models/address.dart';
import '../../../../../services/address_service.dart';
import '../../../users/components/address_edit_dialog.dart';
import '../../../../constants.dart';
import 'client_details_components.dart';
import 'dart:ui';

class ClientDetailsDialog extends StatefulWidget {
  final User client;
  const ClientDetailsDialog({Key? key, required this.client}) : super(key: key);

  @override
  State<ClientDetailsDialog> createState() => _ClientDetailsDialogState();
}

class _ClientDetailsDialogState extends State<ClientDetailsDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _tabController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
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
    _setupAnimations();
    firstNameController = TextEditingController(text: widget.client.firstName);
    lastNameController = TextEditingController(text: widget.client.lastName);
    emailController = TextEditingController(text: widget.client.email);
    phoneController = TextEditingController(text: widget.client.phone ?? '');
    _loadAddresses();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _tabController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
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
      _showGlassySnackbar(
          message: 'Impossible de charger les adresses',
          icon: Icons.error_outline,
          color: AppColors.error,
          duration: Duration(seconds: 3));
    }
    setState(() => isLoadingAddresses = false);
  }

  Future<void> _resetUserPassword() async {
    try {
      final data = await UserService.adminResetUserPassword(widget.client.id);
      final user = data['user'];
      final tempPassword = data['tempPassword'];
      await Get.dialog(ModernPasswordResetDialog(
        user: user,
        tempPassword: tempPassword,
      ));
    } catch (e) {
      _showGlassySnackbar(
          message: e.toString(),
          icon: Icons.error_outline,
          color: AppColors.error,
          duration: Duration(seconds: 3));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 600,
                height: MediaQuery.of(context).size.height * 0.8,
                child: GlassContainer(
                  variant: GlassContainerVariant.neutral,
                  padding: EdgeInsets.zero,
                  borderRadius: AppRadius.xl,
                  child: Column(
                    children: [
                      _buildDialogHeader(isDark),
                      Expanded(
                        child: _buildDialogContent(isDark),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogHeader(bool isDark) {
    final first = widget.client.firstName;
    final last = widget.client.lastName;
    final combined = ('$first $last').trim();
    final fullName = combined.isEmpty ? 'Client' : combined;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.accent.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: AppRadius.radiusXL.topLeft,
          topRight: AppRadius.radiusXL.topRight,
        ),
      ),
      child: Row(
        children: [
          // Avatar du client
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                fullName[0].toUpperCase(),
                style: AppTextStyles.h3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Détails Client',
                  style: AppTextStyles.h2.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  fullName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
          ModernCloseButton(
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogContent(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section informations personnelles
          _buildPersonalInfoSection(isDark),
          SizedBox(height: AppSpacing.xl),

          // Section adresses
          _buildAddressesSection(isDark),
          SizedBox(height: AppSpacing.xl),

          // Section actions
          _buildActionsSection(isDark),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: AppColors.primary,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Informations Personnelles',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),

          // Champs de saisie modernes
          ModernTextField(
            controller: firstNameController,
            label: 'Prénom',
            icon: Icons.person,
            isDark: isDark,
          ),
          SizedBox(height: AppSpacing.md),

          ModernTextField(
            controller: lastNameController,
            label: 'Nom de famille',
            icon: Icons.person_outline,
            isDark: isDark,
          ),
          SizedBox(height: AppSpacing.md),

          ModernTextField(
            controller: emailController,
            label: 'Adresse email',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            isDark: isDark,
          ),
          SizedBox(height: AppSpacing.md),

          ModernTextField(
            controller: phoneController,
            label: 'Numéro de téléphone',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            isDark: isDark,
          ),
          SizedBox(height: AppSpacing.lg),

          // Bouton de sauvegarde
          ModernSaveButton(
            isLoading: isSaving,
            onPressed: isSaving ? null : _saveClientInfo,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressesSection(bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppColors.info,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Adresses du Client',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ModernActionButton(
                icon: Icons.add_location_alt,
                label: 'Ajouter',
                onPressed: () => _addNewAddress(),
                variant: ClientActionVariant.info,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          if (isLoadingAddresses)
            _buildLoadingAddresses(isDark)
          else if (_addresses.isEmpty)
            _buildEmptyAddresses(isDark)
          else
            _buildAddressList(isDark),
        ],
      ),
    );
  }

  Widget _buildActionsSection(bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.warning,
      padding: EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.admin_panel_settings,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Actions Administrateur',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Actions sensibles nécessitant des privilèges administrateur',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          ModernActionButton(
            icon: Icons.lock_reset,
            label: 'Réinitialiser le mot de passe',
            onPressed: _resetUserPassword,
            variant: ClientActionVariant.warning,
          ),
        ],
      ),
    );
  }

  // Méthodes utilitaires
  Future<void> _saveClientInfo() async {
    setState(() => isSaving = true);
    // TODO: Appeler le service pour mettre à jour le client
    await Future.delayed(Duration(seconds: 1)); // Placeholder
    setState(() => isSaving = false);
    _showGlassySnackbar(
        message: 'Informations client mises à jour',
        icon: Icons.check_circle,
        color: AppColors.success);
  }

  void _addNewAddress() async {
    await Get.dialog(AddressEditDialog(
      userId: widget.client.id,
      onAddressSaved: (address) => _loadAddresses(),
    ));
  }

  Widget _buildLoadingAddresses(bool isDark) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.info),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Chargement des adresses...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAddresses(bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color:
            (isDark ? AppColors.gray700 : AppColors.gray100).withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Icon(
            Icons.location_off,
            size: 48,
            color: isDark ? AppColors.gray400 : AppColors.gray500,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Aucune adresse enregistrée',
            style: AppTextStyles.bodyLarge.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.gray700,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Ajoutez une adresse pour ce client',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList(bool isDark) {
    return Column(
      children: _addresses
          .map((address) => AddressCard(
                address: address,
                isDark: isDark,
                onEdit: () => _editAddress(address),
                onDelete: () => _deleteAddress(address),
              ))
          .toList(),
    );
  }

  void _editAddress(Address address) async {
    await Get.dialog(AddressEditDialog(
      userId: widget.client.id,
      initialAddress: address,
      onAddressSaved: (a) => _loadAddresses(),
    ));
  }

  void _deleteAddress(Address address) async {
    final confirm = await Get.dialog<bool>(
      ModernConfirmDialog(
        title: 'Supprimer l\'adresse',
        message: 'Voulez-vous vraiment supprimer cette adresse ?',
        confirmText: 'Supprimer',
        cancelText: 'Annuler',
        isDestructive: true,
      ),
    );

    if (confirm == true) {
      try {
        await AddressService.deleteAddress(address.id);
        _showGlassySnackbar(
          message: 'Adresse supprimée avec succès',
          icon: Icons.delete,
          color: AppColors.success,
        );
        _loadAddresses();
      } catch (e) {
        _showGlassySnackbar(
          message: 'Erreur lors de la suppression',
          icon: Icons.error,
          color: AppColors.error,
        );
      }
    }
  }

  void _showGlassySnackbar(
      {required String message,
      IconData icon = Icons.check_circle,
      Color? color,
      Duration? duration}) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
          ),
        ],
      ),
      backgroundColor: (color ?? AppColors.success).withOpacity(0.85),
      borderRadius: 16,
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      snackPosition: SnackPosition.TOP,
      duration: duration ?? Duration(seconds: 2),
      boxShadows: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
      isDismissible: true,
      overlayBlur: 2.5,
    );
  }
}

class _PasswordResetResultDialog extends StatelessWidget {
  final dynamic user;
  final String tempPassword;

  const _PasswordResetResultDialog(
      {Key? key, required this.user, required this.tempPassword})
      : super(key: key);

  void _showGlassySnackbar(
      {required String message,
      IconData icon = Icons.check_circle,
      Color? color,
      Duration? duration}) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
          ),
        ],
      ),
      backgroundColor: (color ?? AppColors.success).withOpacity(0.85),
      borderRadius: 16,
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      snackPosition: SnackPosition.TOP,
      duration: duration ?? Duration(seconds: 2),
      boxShadows: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
      isDismissible: true,
      overlayBlur: 2.5,
    );
  }

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
                  _showGlassySnackbar(
                      message:
                          'Infos client et mot de passe copiés dans le presse-papier',
                      icon: Icons.copy,
                      color: AppColors.info);
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
