import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/theme_switch.dart';
import '../../widgets/shared/glass_container.dart';
import '../../widgets/shared/glass_button.dart';

class AdminLoginScreen extends StatefulWidget {
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authController = Get.find<AuthController>();
  final _obscurePassword = true.obs;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.gray900,
                    AppColors.gray800.withOpacity(0.8),
                    AppColors.primary.withOpacity(0.1),
                  ]
                : [
                    AppColors.gray50,
                    AppColors.white,
                    AppColors.primary.withOpacity(0.05),
                  ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background elements
            _buildBackgroundElements(isDark),
            
            // Theme switch in top-right corner
            Positioned(
              top: AppSpacing.xl,
              right: AppSpacing.xl,
              child: ThemeSwitch(showLabel: true),
            ),
            
            // Main content
            Center(
              child: SingleChildScrollView(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          constraints: BoxConstraints(maxWidth: 450),
                          margin: EdgeInsets.all(AppSpacing.lg),
                          child: _buildLoginCard(context, isDark),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundElements(bool isDark) {
    return Stack(
      children: [
        // Floating circles
        Positioned(
          top: 100,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
        ),
        Positioned(
          bottom: 150,
          right: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withOpacity(0.08),
            ),
          ),
        ),
        Positioned(
          top: 300,
          right: 100,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success.withOpacity(0.06),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(BuildContext context, bool isDark) {
    return GlassContainer(
      padding: EdgeInsets.all(AppSpacing.xxl),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, isDark),
            SizedBox(height: AppSpacing.xxl),
            _buildEmailField(context, isDark),
            SizedBox(height: AppSpacing.lg),
            _buildPasswordField(context, isDark),
            SizedBox(height: AppSpacing.xxl),
            _buildLoginButton(context, isDark),
            SizedBox(height: AppSpacing.lg),
            _buildFooter(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primaryLight,
              ],
            ),
            borderRadius: AppRadius.radiusLG,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.admin_panel_settings,
            size: 40,
            color: Colors.white,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        Text(
          'Administration',
          style: AppTextStyles.h1.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          'Connectez-vous à votre espace admin',
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.gray300 : AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailField(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.gray800.withOpacity(0.5)
            : AppColors.white.withOpacity(0.7),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark
              ? AppColors.gray700.withOpacity(0.3)
              : AppColors.gray200.withOpacity(0.5),
        ),
      ),
      child: TextFormField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isDark ? AppColors.textLight : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: 'Adresse email',
          hintText: 'admin@example.com',
          prefixIcon: Container(
            margin: EdgeInsets.all(AppSpacing.sm),
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppRadius.radiusSM,
            ),
            child: Icon(
              Icons.email_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(AppSpacing.lg),
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.gray400 : AppColors.textMuted,
          ),
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.gray500 : AppColors.gray400,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'L\'email est requis';
          }
          if (!GetUtils.isEmail(value)) {
            return 'Entrez un email valide';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.gray800.withOpacity(0.5)
            : AppColors.white.withOpacity(0.7),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark
              ? AppColors.gray700.withOpacity(0.3)
              : AppColors.gray200.withOpacity(0.5),
        ),
      ),
      child: Obx(() => TextFormField(
        controller: passwordController,
        obscureText: _obscurePassword.value,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isDark ? AppColors.textLight : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: 'Mot de passe',
          hintText: '••••••••',
          prefixIcon: Container(
            margin: EdgeInsets.all(AppSpacing.sm),
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppRadius.radiusSM,
            ),
            child: Icon(
              Icons.lock_outline,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword.value ? Icons.visibility : Icons.visibility_off,
              color: AppColors.primary,
            ),
            onPressed: () => _obscurePassword.value = !_obscurePassword.value,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(AppSpacing.lg),
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.gray400 : AppColors.textMuted,
          ),
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.gray500 : AppColors.gray400,
          ),
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
      )),
    );
  }

  Widget _buildLoginButton(BuildContext context, bool isDark) {
    return Obx(() => GlassButton(
      label: 'Se connecter',
      icon: Icons.login,
      variant: GlassButtonVariant.primary,
      fullWidth: true,
      isLoading: authController.isLoading.value,
      onPressed: authController.isLoading.value ? null : _handleLogin,
    ));
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                'Alpha Laundry Admin',
                style: AppTextStyles.caption.copyWith(
                  color: isDark ? AppColors.gray400 : AppColors.textMuted,
                ),
              ),
            ),
            Expanded(child: Divider()),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          'Version 1.0.0',
          style: AppTextStyles.caption.copyWith(
            color: isDark ? AppColors.gray500 : AppColors.gray400,
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      await authController.login(
        emailController.text.trim(),
        passwordController.text,
      );
    } catch (e) {
      Get.rawSnackbar(
        messageText: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 22),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Erreur de connexion. Vérifiez vos identifiants.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error.withOpacity(0.9),
        borderRadius: 16,
        margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
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
}
