import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../controllers/delivery_controller.dart';
import '../../../widgets/shared/glass_button.dart';

class DelivererCreateDialog extends StatefulWidget {
  const DelivererCreateDialog({Key? key}) : super(key: key);

  @override
  State<DelivererCreateDialog> createState() => _DelivererCreateDialogState();
}

class _DelivererCreateDialogState extends State<DelivererCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _zoneController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _licenseNumberController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  final List<String> _vehicleTypes = [
    'Moto',
    'Scooter',
    'Vélo',
    'Voiture',
    'Camionnette',
  ];

  final List<String> _zones = [
    'Centre-ville',
    'Zone Nord',
    'Zone Sud',
    'Zone Est',
    'Zone Ouest',
    'Banlieue',
  ];

  String? _selectedVehicleType;
  String? _selectedZone;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _zoneController.dispose();
    _vehicleTypeController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 600,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        decoration: BoxDecoration(
          borderRadius: AppRadius.radiusLG,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: AppRadius.radiusLG,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: isDark 
                    ? AppColors.gray900.withOpacity(0.95)
                    : Colors.white.withOpacity(0.95),
                borderRadius: AppRadius.radiusLG,
                border: Border.all(
                  color: isDark 
                      ? AppColors.gray700.withOpacity(0.5)
                      : AppColors.gray200.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, isDark),
                    Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPersonalInfoSection(context, isDark),
                            SizedBox(height: AppSpacing.lg),
                            _buildContactSection(context, isDark),
                            SizedBox(height: AppSpacing.lg),
                            _buildWorkInfoSection(context, isDark),
                            SizedBox(height: AppSpacing.xl),
                            _buildActions(context),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withOpacity(0.1),
            AppColors.success.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          topRight: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withOpacity(0.2),
                  AppColors.success.withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: AppColors.success.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.person_add_outlined,
              size: 30,
              color: AppColors.success,
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nouveau Livreur',
                  style: AppTextStyles.h2.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Ajoutez un nouveau membre à votre équipe de livraison',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
            style: IconButton.styleFrom(
              backgroundColor: isDark 
                  ? AppColors.gray800.withOpacity(0.5)
                  : AppColors.gray100.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.radiusSM,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(BuildContext context, bool isDark) {
    return _buildSection(
      'Informations personnelles',
      Icons.person_outline,
      AppColors.primary,
      isDark,
      [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _firstNameController,
                label: 'Prénom',
                hint: 'Entrez le prénom',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le prénom est requis';
                  }
                  return null;
                },
                isDark: isDark,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildTextField(
                controller: _lastNameController,
                label: 'Nom',
                hint: 'Entrez le nom',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le nom est requis';
                  }
                  return null;
                },
                isDark: isDark,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        _buildTextField(
          controller: _passwordController,
          label: 'Mot de passe',
          hint: 'Entrez un mot de passe sécurisé',
          icon: Icons.lock_outline,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
              color: isDark ? AppColors.gray400 : AppColors.gray600,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Le mot de passe est requis';
            }
            if (value.length < 6) {
              return 'Le mot de passe doit contenir au moins 6 caractères';
            }
            return null;
          },
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context, bool isDark) {
    return _buildSection(
      'Contact',
      Icons.contact_phone_outlined,
      AppColors.info,
      isDark,
      [
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'exemple@email.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'L\'email est requis';
            }
            if (!GetUtils.isEmail(value)) {
              return 'Veuillez entrer un email valide';
            }
            return null;
          },
          isDark: isDark,
        ),
        SizedBox(height: AppSpacing.md),
        _buildTextField(
          controller: _phoneController,
          label: 'Téléphone',
          hint: '+237 6XX XXX XXX',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Le téléphone est requis';
            }
            return null;
          },
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildWorkInfoSection(BuildContext context, bool isDark) {
    return _buildSection(
      'Informations de travail',
      Icons.work_outline,
      AppColors.accent,
      isDark,
      [
        _buildDropdownField(
          label: 'Zone de livraison',
          hint: 'Sélectionnez une zone',
          icon: Icons.location_on_outlined,
          value: _selectedZone,
          items: _zones,
          onChanged: (value) {
            setState(() {
              _selectedZone = value;
            });
          },
          isDark: isDark,
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                label: 'Type de véhicule',
                hint: 'Sélectionnez un véhicule',
                icon: Icons.directions_car_outlined,
                value: _selectedVehicleType,
                items: _vehicleTypes,
                onChanged: (value) {
                  setState(() {
                    _selectedVehicleType = value;
                  });
                },
                isDark: isDark,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildTextField(
                controller: _licenseNumberController,
                label: 'Numéro de permis',
                hint: 'Optionnel',
                icon: Icons.credit_card_outlined,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, Color color, bool isDark, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.gray800.withOpacity(0.5)
            : AppColors.gray50.withOpacity(0.8),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark 
              ? AppColors.gray700.withOpacity(0.3)
              : AppColors.gray200.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: AppRadius.radiusSM,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTextStyles.h4.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: AppTextStyles.bodyMedium.copyWith(
        color: isDark ? AppColors.textLight : AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark 
            ? AppColors.gray900.withOpacity(0.3)
            : Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusSM,
          borderSide: BorderSide(
            color: isDark 
                ? AppColors.gray600.withOpacity(0.3)
                : AppColors.gray300.withOpacity(0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusSM,
          borderSide: BorderSide(
            color: isDark 
                ? AppColors.gray600.withOpacity(0.3)
                : AppColors.gray300.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusSM,
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusSM,
          borderSide: BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: isDark ? AppColors.gray300 : AppColors.textSecondary,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: isDark ? AppColors.gray400 : AppColors.gray500,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      style: AppTextStyles.bodyMedium.copyWith(
        color: isDark ? AppColors.textLight : AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: isDark 
            ? AppColors.gray900.withOpacity(0.3)
            : Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusSM,
          borderSide: BorderSide(
            color: isDark 
                ? AppColors.gray600.withOpacity(0.3)
                : AppColors.gray300.withOpacity(0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusSM,
          borderSide: BorderSide(
            color: isDark 
                ? AppColors.gray600.withOpacity(0.3)
                : AppColors.gray300.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusSM,
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: isDark ? AppColors.gray300 : AppColors.textSecondary,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: isDark ? AppColors.gray400 : AppColors.gray500,
        ),
      ),
      dropdownColor: isDark ? AppColors.gray800 : Colors.white,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GlassButton(
          label: 'Annuler',
          icon: Icons.close,
          variant: GlassButtonVariant.secondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        SizedBox(width: AppSpacing.md),
        GlassButton(
          label: _isLoading ? 'Création...' : 'Créer le livreur',
          icon: _isLoading ? null : Icons.person_add_outlined,
          variant: GlassButtonVariant.success,
          onPressed: _isLoading ? null : _createDeliverer,
        ),
      ],
    );
  }

  Future<void> _createDeliverer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final controller = Get.find<DeliveryController>();
      
      await controller.createDeliverer(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        zone: _selectedZone,
        vehicleType: _selectedVehicleType,
        licenseNumber: _licenseNumberController.text.trim().isNotEmpty 
            ? _licenseNumberController.text.trim() 
            : null,
      );

      Navigator.of(context).pop();
    } catch (e) {
      // L'erreur est déjà gérée dans le contrôleur
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}