import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../../../shared/providers/user_profile_provider.dart';
import '../../../core/services/user_profile_service.dart';

/// ✏️ Dialog d'Édition de Profil - Alpha Client App
///
/// Dialog premium pour modifier les informations du profil utilisateur
/// avec validation en temps réel et design glassmorphism.
class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({Key? key}) : super(key: key);

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  DateTime? _selectedDateOfBirth;
  String? _selectedGender;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final provider = Provider.of<UserProfileProvider>(context, listen: false);
    final user = provider.currentUser;

    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _phoneController.text = user.phone ?? '';
      _emailController.text = user.email;
      _selectedDateOfBirth = user.profile?.dateOfBirth;
      _selectedGender = user.profile?.gender;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: _buildForm(),
                ),
              ),
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
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.edit,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Modifier le profil',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Mettez à jour vos informations personnelles',
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
          // Prénom et Nom
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _firstNameController,
                  label: 'Prénom',
                  hint: 'Votre prénom',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le prénom est requis';
                    }
                    if (value.trim().length < 2) {
                      return 'Prénom trop court';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _lastNameController,
                  label: 'Nom',
                  hint: 'Votre nom',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le nom est requis';
                    }
                    if (value.trim().length < 2) {
                      return 'Nom trop court';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Email
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'votre@email.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'L\'email est requis';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Email invalide';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Téléphone
          _buildTextField(
            controller: _phoneController,
            label: 'Téléphone',
            hint: '06 12 34 56 78',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le téléphone est requis';
              }
              if (value.trim().length != 10) {
                return 'Numéro invalide (10 chiffres)';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Date de naissance
          _buildDateField(),

          const SizedBox(height: 16),

          // Genre
          _buildGenderField(),
        ],
      ),
    );
  }

  /// 📝 Champ de texte personnalisé
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
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
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary(context),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary(context),
            ),
            prefixIcon: Icon(
              icon,
              color: AppColors.textSecondary(context),
              size: 20,
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

  /// 📅 Champ de date
  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date de naissance',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDateOfBirth,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.surfaceVariant(context),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.textSecondary(context),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedDateOfBirth != null
                      ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                      : 'Sélectionner une date',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _selectedDateOfBirth != null
                        ? AppColors.textPrimary(context)
                        : AppColors.textTertiary(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 👤 Champ de genre
  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genre',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption('Homme', 'male'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderOption('Femme', 'female'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderOption('Autre', 'other'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String label, String value) {
    final isSelected = _selectedGender == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surface(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.surfaceVariant(context),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondary(context),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
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
            text: 'Sauvegarder',
            onPressed: _isLoading ? null : _handleSave,
            isLoading: _isLoading,
            icon: Icons.save,
          ),
        ),
      ],
    );
  }

  /// 📅 Sélectionner la date de naissance
  Future<void> _selectDateOfBirth() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ??
          DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedDateOfBirth = date;
      });
    }
  }

  /// 💾 Gestionnaire de sauvegarde
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = UpdateUserProfileRequest(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        dateOfBirth: _selectedDateOfBirth,
        gender: _selectedGender,
      );

      final provider = Provider.of<UserProfileProvider>(context, listen: false);
      final success = await provider.updateUserProfile(request);

      if (success && mounted) {
        Navigator.of(context).pop();
        _showSuccessSnackBar('Profil mis à jour avec succès');
      } else if (provider.error != null && mounted) {
        _showErrorSnackBar(provider.error!);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erreur lors de la sauvegarde');
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
