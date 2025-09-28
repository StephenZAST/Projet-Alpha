import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants.dart';
import '../../controllers/auth_controller.dart';

/// 🔐 Écran de Connexion - Alpha Delivery App
/// 
/// Interface de connexion mobile-first optimisée pour les livreurs
/// avec design glassmorphism et validation en temps réel.
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.gray900 : AppColors.gray50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              
              // Logo et titre
              _buildHeader(isDark),
              
              const SizedBox(height: AppSpacing.xxl),
              
              // Formulaire de connexion
              _buildLoginForm(isDark),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Informations supplémentaires
              _buildFooter(isDark),
            ],
          ),
        ),
      ),
    );
  }

  /// En-tête avec logo et titre
  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        // Logo/Icône
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: AppRadius.radiusXL,
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.delivery_dining,
            size: 60,
            color: AppColors.primary,
          ),
        ),
        
        const SizedBox(height: AppSpacing.lg),
        
        // Titre
        Text(
          'Alpha Delivery',
          style: AppTextStyles.h1.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        // Sous-titre
        Text(
          'Connexion Équipe',
          style: AppTextStyles.bodyLarge.copyWith(
            color: isDark ? AppColors.gray300 : AppColors.textSecondary,
          ),
        ),
        
        const SizedBox(height: AppSpacing.xs),
        
        // Rôles acceptés
        Text(
          'Livreurs • Admins • Super Admins',
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark ? AppColors.gray400 : AppColors.gray600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  /// Formulaire de connexion avec glassmorphism
  Widget _buildLoginForm(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBgDark : AppColors.cardBgLight,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(
          color: isDark 
              ? AppColors.gray700.withOpacity(AppColors.glassBorderDarkOpacity)
              : AppColors.gray200.withOpacity(AppColors.glassBorderLightOpacity),
        ),
        boxShadow: AppShadows.glassmorphism,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Champ email
            _buildEmailField(),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Champ mot de passe
            _buildPasswordField(),
            
            const SizedBox(height: AppSpacing.md),
            
            // Se souvenir de moi
            _buildRememberMeCheckbox(isDark),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Bouton de connexion
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }

  /// Champ email
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Email',
        hintText: 'votre.email@exemple.com',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez saisir votre email';
        }
        if (!GetUtils.isEmail(value)) {
          return 'Email invalide';
        }
        return null;
      },
    );
  }

  /// Champ mot de passe
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Mot de passe',
        hintText: 'Votre mot de passe',
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez saisir votre mot de passe';
        }
        if (value.length < 6) {
          return 'Le mot de passe doit contenir au moins 6 caractères';
        }
        return null;
      },
      onFieldSubmitted: (_) => _handleLogin(),
    );
  }

  /// Checkbox "Se souvenir de moi"
  Widget _buildRememberMeCheckbox(bool isDark) {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (value) {
            setState(() {
              _rememberMe = value ?? false;
            });
          },
        ),
        Text(
          'Se souvenir de moi',
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.gray300 : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Bouton de connexion
  Widget _buildLoginButton() {
    return GetBuilder<AuthController>(
      builder: (controller) {
        return SizedBox(
          height: MobileDimensions.buttonHeight,
          child: ElevatedButton(
            onPressed: controller.isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.radiusMD,
              ),
              elevation: 0,
            ),
            child: controller.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Se connecter',
                    style: AppTextStyles.buttonMedium,
                  ),
          ),
        );
      },
    );
  }

  /// Pied de page avec informations
  Widget _buildFooter(bool isDark) {
    return Column(
      children: [
        // Lien mot de passe oublié
        TextButton(
          onPressed: _handleForgotPassword,
          child: Text(
            'Mot de passe oublié ?',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        
        const SizedBox(height: AppSpacing.lg),
        
        // Informations de contact
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark 
                ? AppColors.gray800.withOpacity(0.5)
                : AppColors.gray100.withOpacity(0.8),
            borderRadius: AppRadius.radiusMD,
          ),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                color: isDark ? AppColors.gray400 : AppColors.gray600,
                size: 20,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Problème de connexion ?\nContactez votre superviseur',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Gère la connexion
  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      final controller = Get.find<AuthController>();
      
      controller.login(
        _emailController.text.trim(),
        _passwordController.text,
        rememberMe: _rememberMe,
      );
    }
  }

  /// Gère le mot de passe oublié
  void _handleForgotPassword() {
    // TODO: Implémenter la récupération de mot de passe
    Get.snackbar(
      'Information',
      'Contactez votre superviseur pour réinitialiser votre mot de passe',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.info.withOpacity(0.9),
      colorText: Colors.white,
      icon: const Icon(Icons.info, color: Colors.white),
      margin: const EdgeInsets.all(AppSpacing.md),
      borderRadius: MobileDimensions.radiusMD,
    );
  }
}