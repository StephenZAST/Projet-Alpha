import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:spring_button/spring_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:prima/providers/auth_provider.dart';

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
  String _errorMessage = '';

  Future<void> _resetPassword() async {
    setState(() => _isLoading = true);
    try {
      switch (_currentStep) {
        case 0:
          await _requestResetCode();
          break;
        case 1:
          await _verifyCode(); // Nouvelle méthode pour vérifier le code uniquement
          break;
        case 2:
          if (_newPasswordController.text != _confirmPasswordController.text) {
            setState(
                () => _errorMessage = 'Les mots de passe ne correspondent pas');
            return;
          }
          await _setNewPassword(); // Nouvelle méthode pour définir le nouveau mot de passe
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/login');
          break;
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _requestResetCode() async {
    final email = _emailController.text;
    final url = Uri.parse('http://localhost:3001/api/auth/reset-password');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'email': email});

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        setState(() => _currentStep++);
      } else {
        print('Request reset code response: ${response.body}');
        setState(() =>
            _errorMessage = 'Failed to send reset code: ${response.body}');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to connect to server: $e');
    }
  }

  Future<void> _verifyCode() async {
    try {
      final email = _emailController.text;
      final code = _codeController.text;

      final url = Uri.parse('$baseUrl/verify-code');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'code': code,
        }),
      );

      if (response.statusCode == 200) {
        setState(
            () => _currentStep = 2); // Passer à l'étape du nouveau mot de passe
      } else {
        setState(() => _errorMessage = 'Code invalide');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Erreur: $e');
    }
  }

  Future<void> _setNewPassword() async {
    try {
      final email = _emailController.text;
      final code = _codeController.text;
      final newPassword = _newPasswordController.text;

      final url = Uri.parse('$baseUrl/verify-code-and-reset-password');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'code': code,
          'newPassword': newPassword,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        Provider.of<AuthProvider>(context, listen: false)
            .setTempCredentials(email, newPassword);
        setState(() => _currentStep = 3); // Afficher l'écran de succès
      } else {
        setState(() => _errorMessage =
            responseData['error'] ?? 'Échec de la réinitialisation');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Erreur: $e');
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
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
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _confirmPasswordController,
          label: 'Confirmer mot de passe',
          icon: Icons.lock_outline,
          obscureText: true,
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
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: AppColors.gray50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
    );
  }
}
