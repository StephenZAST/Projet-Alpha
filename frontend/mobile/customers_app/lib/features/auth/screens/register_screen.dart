import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../../../shared/providers/auth_provider.dart';

/// 📝 Écran d'Inscription Premium - Alpha Client App
///
/// Interface d'inscription sophistiquée avec validation temps réel
/// et intégration complète avec le backend Alpha Pressing.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  int _currentStep = 0;
  bool _showErrorDetails = false;
  String? _lastErrorCode;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: AppAnimations.fadeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: AppAnimations.slideIn,
    ));

    // Démarrer les animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary(context),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Inscription',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary(context),
          ),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildProgressIndicator(),
                  const SizedBox(height: 24),
                  _buildRegisterForm(),
                  const SizedBox(height: 32),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🎨 En-tête
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rejoignez Alpha Pressing',
          style: AppTextStyles.display.copyWith(
            color: AppColors.textPrimary(context),
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Créez votre compte pour accéder à nos services premium',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }

  /// 📊 Indicateur de Progression
  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _buildStepIndicator(0, 'Informations'),
        _buildStepConnector(0),
        _buildStepIndicator(1, 'Sécurité'),
        _buildStepConnector(1),
        _buildStepIndicator(2, 'Confirmation'),
      ],
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = step <= _currentStep;
    final isCompleted = step < _currentStep;
    
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.surfaceVariant(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive ? AppColors.primary : AppColors.border(context),
                width: 2,
              ),
            ),
            child: Icon(
              isCompleted ? Icons.check : Icons.circle,
              color: isActive ? Colors.white : AppColors.textTertiary(context),
              size: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isActive ? AppColors.primary : AppColors.textTertiary(context),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int step) {
    final isCompleted = step < _currentStep;
    
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: isCompleted ? AppColors.primary : AppColors.border(context),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  /// 📝 Formulaire d'Inscription
  Widget _buildRegisterForm() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (_currentStep == 0) ..._buildPersonalInfoStep(),
                if (_currentStep == 1) ..._buildSecurityStep(),
                if (_currentStep == 2) ..._buildConfirmationStep(),
                
                const SizedBox(height: 32),
                
                // Boutons de navigation
                _buildNavigationButtons(authProvider),
                
                // Message d'erreur
                if (authProvider.error != null) ...[
                  const SizedBox(height: 16),
                  _buildErrorMessage(authProvider.error!),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// 👤 Étape 1 : Informations Personnelles
  List<Widget> _buildPersonalInfoStep() {
    return [
      Text(
        'Informations personnelles',
        style: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.textPrimary(context),
        ),
      ),
      const SizedBox(height: 20),
      
      Row(
        children: [
          Expanded(
            child: _buildTextField(
              controller: _firstNameController,
              label: 'Prénom',
              hint: 'Ali',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Prénom requis';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildTextField(
              controller: _lastNameController,
              label: 'Nom',
              hint: 'ZEBA',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nom requis';
                }
                return null;
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      
      _buildTextField(
        controller: _emailController,
        label: 'Email',
        hint: 'ali.zeba@email.com',
        icon: Icons.email_outlined,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Email requis';
          }
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Email invalide';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),
      
      _buildTextField(
        controller: _phoneController,
        label: 'Téléphone',
        hint: '+226 12 34 56 78',
        icon: Icons.phone_outlined,
        keyboardType: TextInputType.phone,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Téléphone requis';
          }
          if (!RegExp(r'^[0-9+\-\s\(\)]+$').hasMatch(value)) {
            return 'Numéro invalide';
          }
          return null;
        },
      ),
    ];
  }

  /// 🔒 Étape 2 : Sécurité
  List<Widget> _buildSecurityStep() {
    return [
      Text(
        'Sécurité du compte',
        style: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.textPrimary(context),
        ),
      ),
      const SizedBox(height: 20),
      
      _buildTextField(
        controller: _passwordController,
        label: 'Mot de passe',
        hint: '��•••••••',
        icon: Icons.lock_outlined,
        obscureText: _obscurePassword,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppColors.textSecondary(context),
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Mot de passe requis';
          }
          if (value.length < 8) {
            return 'Au moins 8 caractères';
          }
          if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
            return 'Doit contenir majuscule, minuscule et chiffre';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),
      
      _buildTextField(
        controller: _confirmPasswordController,
        label: 'Confirmer le mot de passe',
        hint: '••••••••',
        icon: Icons.lock_outlined,
        obscureText: _obscureConfirmPassword,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppColors.textSecondary(context),
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Confirmation requise';
          }
          if (value != _passwordController.text) {
            return 'Les mots de passe ne correspondent pas';
          }
          return null;
        },
      ),
      
      const SizedBox(height: 20),
      
      // Critères de mot de passe
      _buildPasswordCriteria(),
    ];
  }

  /// ✅ Étape 3 : Confirmation
  List<Widget> _buildConfirmationStep() {
    return [
      Text(
        'Confirmation',
        style: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.textPrimary(context),
        ),
      ),
      const SizedBox(height: 20),
      
      // Résumé des informations
      _buildSummaryCard(),
      
      const SizedBox(height: 20),
      
      // Acceptation des conditions
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: _acceptTerms,
            onChanged: (value) {
              setState(() {
                _acceptTerms = value ?? false;
              });
            },
            activeColor: AppColors.primary,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _acceptTerms = !_acceptTerms;
                });
              },
              child: Text.rich(
                TextSpan(
                  text: 'J\'accepte les ',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                  children: [
                    TextSpan(
                      text: 'conditions d\'utilisation',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: ' et la '),
                    TextSpan(
                      text: 'politique de confidentialité',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: AppColors.textSecondary(context),
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(
            color: AppColors.border(context),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(
            color: AppColors.border(context),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: AppColors.surface(context),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordCriteria() {
    final password = _passwordController.text;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant(context),
        borderRadius: AppRadius.radiusSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Critères du mot de passe :',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          _buildCriteriaItem('Au moins 8 caractères', password.length >= 8),
          _buildCriteriaItem('Une majuscule', RegExp(r'[A-Z]').hasMatch(password)),
          _buildCriteriaItem('Une minuscule', RegExp(r'[a-z]').hasMatch(password)),
          _buildCriteriaItem('Un chiffre', RegExp(r'\d').hasMatch(password)),
        ],
      ),
    );
  }

  Widget _buildCriteriaItem(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isValid ? AppColors.success : AppColors.textTertiary(context),
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(
            color: isValid ? AppColors.success : AppColors.textTertiary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant(context),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: AppColors.border(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Récapitulatif',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Nom complet', '${_firstNameController.text} ${_lastNameController.text}'),
          _buildSummaryRow('Email', _emailController.text),
          _buildSummaryRow('Téléphone', _phoneController.text),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(AuthProvider authProvider) {
    return Row(
      children: [
        if (_currentStep > 0) ...[
          Expanded(
            child: PremiumButton(
              text: 'Précédent',
              onPressed: () {
                setState(() {
                  _currentStep--;
                });
              },
              isOutlined: true,
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: PremiumButton(
            text: _currentStep == 2 ? 'Créer le compte' : 'Suivant',
            onPressed: authProvider.isLoading ? null : _handleNextStep,
            isLoading: authProvider.isLoading && _currentStep == 2,
            icon: _currentStep == 2 ? Icons.check : Icons.arrow_forward,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String error) {
    _extractErrorCode(error);
    
    return AnimatedContainer(
      duration: AppAnimations.fast,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec icône et titre
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.warning_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Erreur d\'inscription',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Bouton pour voir les détails
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showErrorDetails = !_showErrorDetails;
                  });
                },
                child: Icon(
                  _showErrorDetails
                      ? Icons.expand_less_rounded
                      : Icons.info_outline_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Section expandable : Message d'erreur + Code d'erreur
          AnimatedCrossFade(
            firstChild: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.textTertiary(context).withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Détails de l\'erreur',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    error,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary(context),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Code d\'erreur',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textTertiary(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          _lastErrorCode ?? 'N/A',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary(context),
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: _showErrorDetails
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: AppAnimations.fast,
          ),
          
          if (_showErrorDetails) const SizedBox(height: 12),
          
          // Conseils rassurants
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppColors.info,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Conseil',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Notre serveur peut avoir des délais de retard. Veuillez réessayer l\'opération. Si le problème persiste, contactez notre équipe support.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Bouton de contact support
          SizedBox(
            width: double.infinity,
            child: PremiumButton(
              text: 'Contacter le support',
              icon: Icons.phone,
              onPressed: _contactSupport,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔍 Extraire le code d'erreur du message
  void _extractErrorCode(String error) {
    // Chercher un pattern de code d'erreur (ex: [ERR_001], ERROR_CODE, etc.)
    final codePattern = RegExp(r'\[([A-Z0-9_]+)\]|ERROR[_:]?([A-Z0-9_]+)');
    final match = codePattern.firstMatch(error);
    
    if (match != null) {
      _lastErrorCode = match.group(1) ?? match.group(2);
    } else {
      // Utiliser un hash du message comme code
      _lastErrorCode = 'ERR_${error.hashCode.abs().toString().substring(0, 6)}';
    }
  }

  /// 📞 Contacter le support via WhatsApp
  void _contactSupport() async {
    final whatsappNumber = '+22651542586'; // +226 51 54 25 86
    final message = Uri.encodeComponent(
      'Bonjour, j\'ai une erreur d\'inscription sur Alpha Pressing.\n'
      'Code d\'erreur: $_lastErrorCode\n'
      'Email: ${_emailController.text}\n'
      'Veuillez m\'aider à résoudre ce problème.'
    );
    
    final whatsappUrl = 'https://wa.me/$whatsappNumber?text=$message';
    
    try {
      // Essayer d'ouvrir WhatsApp
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('WhatsApp n\'est pas installé', isError: true);
      }
    } catch (e) {
      _showSnackBar('Erreur lors de l\'ouverture de WhatsApp', isError: true);
    }
  }

  /// 🔗 Pied de page
  Widget _buildFooter() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Déjà un compte ? ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Se connecter',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🎯 Gestionnaires d'événements
  void _handleNextStep() async {
    if (_currentStep < 2) {
      // Valider l'étape actuelle
      if (_formKey.currentState!.validate()) {
        setState(() {
          _currentStep++;
        });
      }
    } else {
      // Dernière étape : créer le compte
      if (!_acceptTerms) {
        _showSnackBar('Veuillez accepter les conditions d\'utilisation', isError: true);
        return;
      }

      if (_formKey.currentState!.validate()) {
        HapticFeedback.lightImpact();
        
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final success = await authProvider.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phone: _phoneController.text.trim(),
        );

        if (success) {
          // Navigation vers l'accueil
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (route) => false,
            );
          }
        }
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusMD,
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}