import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/glass_container.dart';
import 'dashboard_screen.dart';

/// 🔐 Écran de Connexion - Alpha Affiliate App
///
/// Interface de connexion avec design glassmorphism

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
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            children: [
              const SizedBox(height: 60),
              _buildHeader(),
              const SizedBox(height: 48),
              _buildLoginForm(),
              const SizedBox(height: 24),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  /// 📱 En-tête avec logo et titre
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(
            Icons.people,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Alpha Affiliate',
          style: AppTextStyles.headlineLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Connectez-vous à votre espace affilié',
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 📝 Formulaire de connexion
  Widget _buildLoginForm() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return GlassContainer(
          color: Colors.white,
          opacity: 0.95,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connexion',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Email
                _buildEmailField(),
                const SizedBox(height: 16),
                
                // Mot de passe
                _buildPasswordField(),
                const SizedBox(height: 16),
                
                // Options
                _buildOptions(),
                const SizedBox(height: 24),
                
                // Erreur
                if (authProvider.error != null)
                  _buildErrorMessage(authProvider.error!),
                
                // Bouton de connexion
                _buildLoginButton(authProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary(context),
          ),
          decoration: InputDecoration(
            hintText: 'votre@email.com',
            prefixIcon: Icon(
              Icons.email_outlined,
              color: AppColors.textSecondary(context),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez saisir votre email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Email invalide';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mot de passe',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary(context),
          ),
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: Icon(
              Icons.lock_outlined,
              color: AppColors.textSecondary(context),
            ),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez saisir votre mot de passe';
            }
            if (value.length < 6) {
              return 'Mot de passe trop court (min. 6 caractères)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildOptions() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (value) {
            setState(() {
              _rememberMe = value ?? false;
            });
          },
          activeColor: AppColors.primary,
        ),
        Text(
          'Se souvenir de moi',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            // TODO: Implémenter mot de passe oublié
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fonctionnalité bientôt disponible'),
                backgroundColor: AppColors.info,
              ),
            );
          },
          child: Text(
            'Mot de passe oublié ?',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: AppRadius.borderRadiusSM,
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      child: PremiumButton(
        text: 'Se Connecter',
        icon: Icons.login,
        isLoading: authProvider.isLoading,
        onPressed: authProvider.isLoading ? null : _handleLogin,
      ),
    );
  }

  /// 🔗 Pied de page
  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Pas encore affilié ?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            // TODO: Implémenter inscription
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Contactez l\'équipe Alpha pour devenir affilié'),
                backgroundColor: AppColors.info,
              ),
            );
          },
          child: Text(
            'Devenir Affilié',
            style: AppTextStyles.labelLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Alpha Affiliate v1.0.0',
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  /// 🔑 Gérer la connexion
  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();

    print('🔑 Tentative de connexion pour: ${_emailController.text.trim()}');

    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    print('🔑 Résultat de la connexion: $success');
    print('🔑 Erreur: ${authProvider.error}');
    print('🔑 isAuthenticated: ${authProvider.isAuthenticated}');

    if (mounted) {
      if (success && authProvider.isAuthenticated) {
        print('🎉 Connexion réussie, navigation vers le dashboard');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        print('❌ Connexion échouée: ${authProvider.error}');
        // L'erreur sera affichée automatiquement via le Consumer
        if (authProvider.error == null) {
          // Si pas d'erreur spécifique, afficher un message générique
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur de connexion inconnue'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}