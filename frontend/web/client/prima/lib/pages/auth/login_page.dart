import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prima/providers/auth_provider.dart';
import 'package:prima/theme/colors.dart';
import 'package:spring_button/spring_button.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../../redux/store.dart';
import '../../redux/actions/auth_actions.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true; // Ajouter cette variable

  @override
  void initState() {
    super.initState();
    // Définir le contexte au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).setContext(context);
    });
    // Vérifier s'il y a des credentials temporaires
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // Utiliser les getters publics au lieu des champs privés
      if (authProvider.tempEmail != null && authProvider.tempPassword != null) {
        _emailController.text = authProvider.tempEmail!;
        _passwordController.text = authProvider.tempPassword!;
        authProvider.clearTempCredentials();
        _attemptLogin();
      }
    });
  }

  Future<void> _attemptLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      StoreProvider.of<AppState>(context).dispatch(
        LoginRequestAction(
          _emailController.text,
          _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: StoreConnector<AppState, _ViewModel>(
          converter: (Store<AppState> store) => _ViewModel.fromStore(store),
          builder: (context, vm) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    Image.asset('assets/AlphaLogo.png', height: 60),
                    const SizedBox(height: 40),
                    Text(
                      'Ravi de vous revoir !',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Adresse email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Email requis' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Mot de passe',
                      icon: Icons.lock_outline,
                      obscureText: true, // Activé par défaut
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Mot de passe requis' : null,
                    ),
                    const SizedBox(height: 24),
                    SpringButton(
                      SpringButtonType.OnlyScale,
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: vm.isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : const Text(
                                  'Se connecter',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      onTap: vm.isLoading ? null : _attemptLogin,
                      useCache: false,
                      scaleCoefficient: 0.9,
                    ),
                    const SizedBox(height: 32),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/reset_password');
                        },
                        child: const Text('Mot de passe oublié ?'),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        'Vous n\'avez pas de compte ? Créez-en un',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
        prefixIcon: Icon(icon),
        suffixIcon: obscureText
            ? IconButton(
                icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.gray50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      obscureText: obscureText ? _obscurePassword : false,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class _ViewModel {
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  _ViewModel({
    required this.isLoading,
    this.error,
    required this.isAuthenticated,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      isLoading: store.state.authState.isLoading,
      error: store.state.authState.error,
      isAuthenticated: store.state.authState.isAuthenticated,
    );
  }
}
