import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/theme_switch.dart';

class AdminLoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    return Scaffold(
      body: Stack(
        children: [
          // Theme switch in top-right corner
          Positioned(
            top: AppSpacing.lg,
            right: AppSpacing.lg,
            child: ThemeSwitch(showLabel: true),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(maxWidth: 400),
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusLG,
                    side: BorderSide(
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            height: 100,
                          ),
                          SizedBox(height: AppSpacing.lg),
                          Text(
                            'Connexion Admin',
                            style: AppTextStyles.h2.copyWith(
                              color: isDark
                                  ? AppColors.textLight
                                  : AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppSpacing.xl),
                          TextFormField(
                            controller: emailController,
                            style: AppTextStyles.bodyLarge,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Entrez votre email',
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: isDark
                                    ? AppColors.gray400
                                    : AppColors.gray500,
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
                          SizedBox(height: AppSpacing.lg),
                          TextFormField(
                            controller: passwordController,
                            style: AppTextStyles.bodyLarge,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Mot de passe',
                              hintText: 'Entrez votre mot de passe',
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: isDark
                                    ? AppColors.gray400
                                    : AppColors.gray500,
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
                          ),
                          SizedBox(height: AppSpacing.xl),
                          Obx(() => ElevatedButton(
                                onPressed: authController.isLoading.value
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          _handleLogin();
                                        }
                                      },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: AppSpacing.md),
                                  child: authController.isLoading.value
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: isDark
                                                ? AppColors.textLight
                                                : Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          'Se connecter',
                                          style: AppTextStyles.buttonLarge,
                                        ),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    try {
      await authController.login(
        emailController.text.trim(),
        passwordController.text,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de la connexion',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(AppSpacing.md),
        borderRadius: AppRadius.sm,
      );
    }
  }
}
