import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../../../shared/providers/user_profile_provider.dart';

/// 🔒 Dialog de Changement de Mot de Passe - Alpha Client App
///
/// Dialog premium pour changer le mot de passe utilisateur
/// avec validation de sécurité et design glassmorphism.
class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({Key? key}) : super(key: key);

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildForm(),
              const SizedBox(height: 24),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  /// 📋 En-tête du dialog
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.lock_outline,
            color: AppColors.warning,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Changer le mot de passe',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Sécurisez votre compte avec un nouveau mot de passe',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.close,
            color: AppColors.textSecondary(context),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  /// 📝 Formulaire
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Mot de passe actuel
          _buildPasswordField(
            controller: _currentPasswordController,
            label: 'Mot de passe actuel',
            hint: 'Votre mot de passe actuel',
            obscureText: _obscureCurrentPassword,
            onToggleVisibility: () {
              setState(() {
                _obscureCurrentPassword = !_obscureCurrentPassword;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le mot de passe actuel est requis';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Nouveau mot de passe
          _buildPasswordField(
            controller: _newPasswordController,
            label: 'Nouveau mot de passe',
            hint: 'Votre nouveau mot de passe',
            obscureText: _obscureNewPassword,
            onToggleVisibility: () {
              setState(() {
                _obscureNewPassword = !_obscureNewPassword;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le nouveau mot de passe est requis';
              }
              if (value.length < 8) {
                return 'Le mot de passe doit contenir au moins 8 caractères';
              }
              if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                return 'Le mot de passe doit contenir au moins une majuscule, une minuscule et un chiffre';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Confirmer le nouveau mot de passe
          _buildPasswordField(
            controller: _confirmPasswordController,
            label: 'Confirmer le nouveau mot de passe',
            hint: 'Répétez votre nouveau mot de passe',
            obscureText: _obscureConfirmPassword,
            onToggleVisibility: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'La confirmation est requise';
              }
              if (value != _newPasswordController.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Conseils de sécurité
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.info.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.security_outlined,
                      color: AppColors.info,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Conseils de sécurité',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...['Au moins 8 caractères', 'Une majuscule et une minuscule', 'Au moins un chiffre', 'Évitez les mots courants']
                    .map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: AppColors.info,
                            size: 12,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            tip,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary(context),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔒 Champ de mot de passe personnalisé
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
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
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary(context),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary(context),
            ),
            prefixIcon: Icon(
              Icons.lock_outline,
              color: AppColors.textSecondary(context),
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textSecondary(context),
                size: 20,
              ),
              onPressed: onToggleVisibility,
            ),
            filled: true,
            fillColor: AppColors.surface(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.surfaceVariant(context),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.surfaceVariant(context),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  /// 🎯 Actions du dialog
  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: Text(
              'Annuler',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: PremiumButton(
            text: 'Changer',
            onPressed: _isLoading ? null : _handleChangePassword,
            isLoading: _isLoading,
            icon: Icons.security,
            backgroundColor: AppColors.warning,
          ),
        ),
      ],
    );
  }

  /// 🔒 Gestionnaire de changement de mot de passe
  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<UserProfileProvider>(context, listen: false);
      final success = await provider.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (success && mounted) {
        Navigator.of(context).pop();
        _showSuccessSnackBar('Mot de passe modifié avec succès');
      } else if (provider.error != null && mounted) {
        _showErrorSnackBar(provider.error!);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erreur lors du changement de mot de passe');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// ✅ Afficher SnackBar de succès
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// ❌ Afficher SnackBar d'erreur
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}