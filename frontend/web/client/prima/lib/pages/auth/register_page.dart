import 'package:flutter/material.dart';
import 'package:prima/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:prima/theme/colors.dart';
import 'package:spring_button/spring_button.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../../redux/store.dart';
import '../../redux/actions/auth_actions.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSubmitting = false;

  bool _obscurePassword = true;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _affiliateCodeController =
      TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _affiliateCodeController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    StoreProvider.of<AppState>(context).dispatch(
      RegisterRequestAction(
        email: _emailController.text,
        password: _passwordController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phone: _phoneController.text,
        affiliateCode: _affiliateCodeController.text.isEmpty
            ? null
            : _affiliateCodeController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gray900),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: StoreConnector<AppState, _ViewModel>(
          converter: (Store<AppState> store) => _ViewModel.fromStore(store),
          builder: (context, vm) {
            if (vm.isAuthenticated) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacementNamed(context, '/');
              });
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    Image.asset('assets/AlphaLogo.png', height: 60),
                    const SizedBox(height: 32),
                    const Text(
                      'Créer un compte',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    _buildTextField(
                      controller: _firstNameController,
                      label: 'Prénom',
                      icon: Icons.person_outline,
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _lastNameController,
                      label: 'Nom de famille',
                      icon: Icons.person_outline,
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Adresse email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v?.isEmpty ?? true) return 'Champ requis';
                        if (!v!.contains('@')) return 'Email invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Mot de passe',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.gray600,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) {
                        if (v?.isEmpty ?? true) return 'Champ requis';
                        if (v!.length < 6) return 'Minimum 6 caractères';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Numéro de téléphone',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Champ requis' : null,
                      helperText: 'Ex: +225 0708090102',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _affiliateCodeController,
                      label: 'Code affilié (optionnel)',
                      icon: Icons.group_outlined,
                      helperText: 'Si vous avez été parrainé',
                    ),
                    const SizedBox(height: 32),
                    SpringButton(
                      SpringButtonType.OnlyScale,
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [AppColors.primaryShadow],
                        ),
                        child: Center(
                          child: vm.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Créer un compte',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      onTap: vm.isLoading ? null : _register,
                      useCache: false,
                      scaleCoefficient: 0.9,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text(
                        'Déjà un compte ? Se connecter',
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffix,
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
          color: AppColors.gray600,
        ),
        prefixIcon: Icon(icon, color: AppColors.gray600),
        suffixIcon: suffix,
        helperText: helperText,
        helperStyle: TextStyle(
          color: AppColors.gray600,
          fontSize: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gray200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gray200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: AppColors.gray50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
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
