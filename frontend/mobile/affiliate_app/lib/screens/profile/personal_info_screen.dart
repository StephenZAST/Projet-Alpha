import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/notification_system.dart';

/// 👤 Écran Informations Personnelles - Alpha Affiliate App
///
/// Permet de modifier les informations personnelles de l'utilisateur

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({Key? key}) : super(key: key);

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadUserInfo() {
    final authProvider = context.read<AuthProvider>();
    _firstNameController.text = authProvider.firstName ?? '';
    _lastNameController.text = authProvider.lastName ?? '';
    _emailController.text = authProvider.email ?? '';
    _phoneController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildPersonalInfoSection(),
              const SizedBox(height: 24),
              _buildContactSection(),
              const SizedBox(height: 32),
              if (_isEditing) _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// 📱 AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Informations Personnelles',
        style: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.textPrimary(context),
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_ios,
          color: AppColors.textPrimary(context),
        ),
      ),
      actions: [
        if (!_isEditing)
          IconButton(
            onPressed: () => setState(() => _isEditing = true),
            icon: Icon(
              Icons.edit,
              color: AppColors.primary,
            ),
          ),
      ],
    );
  }

  /// 🎯 En-tête
  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return GlassContainer(
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  authProvider.initials,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${authProvider.firstName ?? ''} ${authProvider.lastName ?? ''}',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Affilié Alpha Laundry',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 👤 Section informations personnelles
  Widget _buildPersonalInfoSection() {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations Personnelles',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Prénom',
            controller: _firstNameController,
            icon: Icons.person_outline,
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le prénom est requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Nom',
            controller: _lastNameController,
            icon: Icons.person_outline,
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le nom est requis';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  /// 📞 Section contact
  Widget _buildContactSection() {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations de Contact',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Email',
            controller: _emailController,
            icon: Icons.email_outlined,
            enabled: _isEditing, // Rendre modifiable seulement en mode édition
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (!_isEditing) return null;
              if (value == null || value.isEmpty) return 'L\'email est requis';
              final emailRegex = RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}");
              if (!emailRegex.hasMatch(value)) return 'Email invalide';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Téléphone',
            controller: _phoneController,
            icon: Icons.phone_outlined,
            enabled: _isEditing,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(value)) {
                  return 'Numéro de téléphone invalide';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  /// 📝 Champ de texte personnalisé
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    // Couleur selon la nature de l'icône pour effet glassy
    Color _getFieldIconColor(IconData icon) {
      switch (icon) {
        case Icons.person:
          return AppColors.primary; // Bleu pour nom
        case Icons.email:
          return AppColors.secondary; // Violet pour email
        case Icons.phone:
          return AppColors.success; // Vert pour téléphone
        default:
          return AppColors.primary;
      }
    }

    final iconColor = _getFieldIconColor(icon);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        // Couleur et style glassy selon le thème
        Builder(builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          // Softer glassy fill depending on state
          final fillColor = enabled
              ? (isDark
                  ? AppColors.cardBgDark.withOpacity(0.035)
                  : AppColors.cardBgLight.withOpacity(0.045))
              : (isDark
                  ? AppColors.cardBgDark.withOpacity(0.02)
                  : AppColors.gray100.withOpacity(0.06));

          // Use design token for border, with very low opacity to soften the outline
          final baseBorder = AppColors.border(context);
          final borderColor = enabled
              ? baseBorder.withOpacity(isDark ? 0.10 : 0.09)
              : baseBorder.withOpacity(isDark ? 0.04 : 0.06);

          return TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            validator: validator,
            style: AppTextStyles.bodyMedium.copyWith(
              color: enabled
                  ? AppColors.textPrimary(context)
                  : AppColors.textSecondary(context),
            ),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: GlassContainer(
                  width: 28,
                  height: 28,
                  padding: EdgeInsets.zero,
                  alignment: Alignment.center,
                  color: iconColor.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(6),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 16,
                  ),
                ),
              ),
              filled: true,
              fillColor: fillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: borderColor,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: borderColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.primary.withOpacity(0.85),
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.02)
                      : AppColors.gray200.withOpacity(0.12),
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.error,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          );
        }),
      ],
    );
  }

  /// 🎯 Boutons d'action
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: PremiumButton(
            text: 'Annuler',
            isOutlined: true,
            onPressed: _isLoading
                ? null
                : () {
                    _loadUserInfo(); // Recharger les données originales
                    setState(() => _isEditing = false);
                  },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: PremiumButton(
            text: 'Sauvegarder',
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _saveChanges,
          ),
        ),
      ],
    );
  }

  /// 💾 Sauvegarder les modifications
  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();

      // Mettre à jour les informations utilisateur
      authProvider.updateUserInfo(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
      );

      // TODO: Appeler l'API pour sauvegarder les modifications
      await Future.delayed(const Duration(seconds: 1)); // Simulation

      NotificationManager().showSuccess(
        context,
        title: 'Modifications Sauvegardées',
        message: 'Vos informations ont été mises à jour avec succès',
      );

      setState(() => _isEditing = false);
    } catch (e) {
      NotificationManager().showError(
        context,
        title: 'Erreur de Sauvegarde',
        message: 'Impossible de sauvegarder les modifications',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
