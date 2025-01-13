import 'package:flutter/material.dart';
import 'package:prima/redux/states/app_state.dart';
import 'package:prima/theme/colors.dart';
import 'package:spring_button/spring_button.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../../redux/actions/auth_actions.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  // Définir l'URL de base
  final String baseUrl = 'http://localhost:3001/api/auth';
  int _currentStep = 0;
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _resetPassword() async {
    final store = StoreProvider.of<AppState>(context);

    switch (_currentStep) {
      case 0:
        store.dispatch(RequestResetCodeAction(_emailController.text));
        break;
      case 1:
        store.dispatch(VerifyResetCodeAction(
          email: _emailController.text,
          code: _codeController.text,
        ));
        break;
      case 2:
        if (_newPasswordController.text != _confirmPasswordController.text) {
          return;
        }
        store.dispatch(ResetPasswordAction(
          email: _emailController.text,
          code: _codeController.text,
          newPassword: _newPasswordController.text,
        ));
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/login');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            // Mise à jour du step si nécessaire
            if (vm.resetPasswordSuccess && _currentStep < 3) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() => _currentStep++);
              });
            }

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildContent(vm),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(_ViewModel vm) {
    if (vm.error != null && vm.error!.isNotEmpty) {
      return Center(
        child: Text(
          vm.error!,
          style: const TextStyle(color: AppColors.error),
        ),
      );
    }
    switch (_currentStep) {
      case 0:
        return _buildEmailStep();
      case 1:
        return _buildCodeStep();
      case 2:
        return _buildNewPasswordStep();
      case 3:
        return _buildSuccessStep();
      default:
        return Container();
    }
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        const Text(
          'Mot de passe oublié',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.gray900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        _buildTextField(
          controller: _emailController,
          label: 'Entrez l\'adresse e-mail',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 32),
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
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Continuer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          onTap: _isLoading ? null : _resetPassword,
          useCache: false,
          scaleCoefficient: 0.9,
        ),
      ],
    );
  }

  Widget _buildCodeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        const Text(
          'Vérification',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.gray900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          'Entrez votre code de vérification',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.gray600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Nous avons envoyé un code à 6 chiffres à votre adresse zastph300@gmail.com',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.gray600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        _buildTextField(
          controller: _codeController,
          label: 'Entrez le code',
          icon: Icons.lock_outline,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 32),
        SpringButton(
          SpringButtonType.OnlyScale,
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Center(
              child: Text(
                'Vérifier',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          onTap: _isLoading ? null : _resetPassword,
          useCache: false,
          scaleCoefficient: 0.9,
        ),
      ],
    );
  }

  Widget _buildNewPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        const Text(
          'Réinitialisation',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.gray900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          'Réinitialiser votre mot de passe',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.gray600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Votre nouveau mot de passe doit être différent du précédent',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.gray600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        _buildTextField(
          controller: _newPasswordController,
          label: 'Nouveau mot de passe',
          icon: Icons.lock_outline,
          obscureText: true,
          suffix: IconButton(
            icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _confirmPasswordController,
          label: 'Confirmer mot de passe',
          icon: Icons.lock_outline,
          obscureText: true,
          suffix: IconButton(
            icon: Icon(_obscureConfirmPassword
                ? Icons.visibility_off
                : Icons.visibility),
            onPressed: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword),
          ),
          validator: (value) {
            if (value != _newPasswordController.text) {
              return 'Les mots de passe ne correspondent pas';
            }
            return null;
          },
        ),
        const SizedBox(height: 32),
        SpringButton(
          SpringButtonType.OnlyScale,
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Center(
              child: Text(
                'Continuer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          onTap: _isLoading ? null : _resetPassword,
          useCache: false,
          scaleCoefficient: 0.9,
        ),
      ],
    );
  }

  Widget _buildSuccessStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 80,
          ),
          const SizedBox(height: 20),
          const Text(
            'Félicitations ! Votre mot de passe a été réinitialisé avec succès',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Votre accès a été restauré',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SpringButton(
            SpringButtonType.OnlyScale,
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(
                child: Text(
                  'Continuer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            useCache: false,
            scaleCoefficient: 0.9,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.gray50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      obscureText: obscureText
          ? (label.contains('Nouveau')
              ? _obscurePassword
              : _obscureConfirmPassword)
          : false,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: (value) {
        if (label.contains('Confirmer')) {
          setState(() {}); // Pour rafraîchir la validation
        }
      },
    );
  }
}

class _ViewModel {
  final bool isLoading;
  final String? error;
  final bool resetPasswordSuccess;
  final int currentStep;

  _ViewModel({
    required this.isLoading,
    this.error,
    required this.resetPasswordSuccess,
    required this.currentStep,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      isLoading: store.state.authState.isLoading,
      error: store.state.authState.error,
      resetPasswordSuccess: store.state.authState.resetPasswordSuccess ?? false,
      currentStep: store.state.authState.resetPasswordStep ?? 0,
    );
  }
}
