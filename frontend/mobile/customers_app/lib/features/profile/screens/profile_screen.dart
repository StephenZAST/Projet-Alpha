import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../../../shared/providers/user_profile_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../auth/screens/login_screen.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats_card.dart';
import '../widgets/profile_menu_section.dart';
import '../widgets/edit_profile_dialog.dart';
import '../widgets/change_password_dialog.dart';
import '../widgets/notification_preferences_dialog.dart';
import '../widgets/language_preferences_dialog.dart';
import '../widgets/theme_preferences_dialog.dart';
import 'address_management_screen.dart';
import 'help_center_screen.dart';
import 'contact_us_screen.dart';

/// 👤 Écran de Profil Utilisateur - Alpha Client App
///
/// Interface premium pour gérer le profil utilisateur complet
/// avec statistiques, préférences et param��tres.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initializeProfile();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: AppAnimations.slow,
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

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      _slideController.forward();
    });
  }

  void _initializeProfile() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider =
          Provider.of<UserProfileProvider>(context, listen: false);
      profileProvider.initialize();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildBody(),
        ),
      ),
    );
  }

  /// 📱 AppBar Premium
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface(context),
      elevation: 0,
      automaticallyImplyLeading: false, // Retire le bouton retour
      title: Text(
        'Mon Profil',
        style: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.textPrimary(context),
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        Consumer<UserProfileProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            }
            return IconButton(
              icon: Icon(
                Icons.edit,
                color: AppColors.primary,
              ),
              onPressed: () => _showEditProfileDialog(),
            );
          },
        ),
      ],
    );
  }

  /// 🎨 Corps principal
  Widget _buildBody() {
    return Consumer<UserProfileProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && !provider.hasUserData) {
          return _buildLoadingState();
        }

        if (provider.error != null) {
          return _buildErrorState(provider.error!);
        }

        return RefreshIndicator(
          onRefresh: provider.refresh,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                ProfileHeader(),
                const SizedBox(height: 24),
                if (provider.hasStats) ...[
                  ProfileStatsCard(),
                  const SizedBox(height: 24),
                ],
                _buildProfileCompletenessCard(provider),
                const SizedBox(height: 24),
                _buildMenuSections(),
                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        );
      },
    );
  }

  /// 📊 Carte de complétude du profil
  Widget _buildProfileCompletenessCard(UserProfileProvider provider) {
    final completeness = provider.profileCompleteness;
    final suggestions = provider.profileSuggestions;

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_circle_outlined,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Complétude du profil',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${(completeness * 100).toInt()}%',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Barre de progression
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant(context),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: completeness,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Suggestions d\'amélioration:',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...suggestions.take(3).map((suggestion) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_right,
                        color: AppColors.textTertiary(context),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          suggestion,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  /// 📋 Sections du menu
  Widget _buildMenuSections() {
    return Column(
      children: [
        // Section Compte
        ProfileMenuSection(
          title: 'Compte',
          items: [
            ProfileMenuItem(
              icon: Icons.person_outline,
              title: 'Informations personnelles',
              subtitle: 'Nom, email, téléphone',
              onTap: _showEditProfileDialog,
            ),
            ProfileMenuItem(
              icon: Icons.lock_outline,
              title: 'Changer le mot de passe',
              subtitle: 'Sécurité du compte',
              onTap: _showChangePasswordDialog,
            ),
            ProfileMenuItem(
              icon: Icons.location_on_outlined,
              title: 'Mes adresses',
              subtitle: 'Gérer les adresses de livraison',
              onTap: _navigateToAddresses,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Section Préférences
        ProfileMenuSection(
          title: 'Préférences',
          items: [
            ProfileMenuItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Email, push, SMS',
              onTap: _showNotificationPreferencesDialog,
            ),
            ProfileMenuItem(
              icon: Icons.language_outlined,
              title: 'Langue',
              subtitle: 'Français',
              onTap: _showLanguagePreferencesDialog,
            ),
            ProfileMenuItem(
              icon: Icons.palette_outlined,
              title: 'Thème',
              subtitle: 'Clair, sombre, automatique',
              onTap: _showThemePreferencesDialog,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Section Support
        ProfileMenuSection(
          title: 'Support',
          items: [
            ProfileMenuItem(
              icon: Icons.help_outline,
              title: 'Centre d\'aide',
              subtitle: 'FAQ et support',
              onTap: _navigateToHelpCenter,
            ),
            ProfileMenuItem(
              icon: Icons.feedback_outlined,
              title: 'Nous contacter',
              subtitle: 'Questions et suggestions',
              onTap: _navigateToContactUs,
            ),
            ProfileMenuItem(
              icon: Icons.info_outline,
              title: 'À propos',
              subtitle: 'Version et informations',
              onTap: () => _showAboutDialog(),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Section Danger (Logout)
        ProfileMenuSection(
          title: 'Zone de danger',
          items: [
            ProfileMenuItem(
              icon: Icons.logout,
              title: 'Déconnecter',
              subtitle: 'Se déconnecter de votre compte',
              onTap: _showLogoutDialog,
              isDestructive: true,
            ),
          ],
        ),
      ],
    );
  }

  /// 💀 État de chargement
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chargement du profil...',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  /// ❌ État d'erreur
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Erreur de chargement',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PremiumButton(
              text: 'Réessayer',
              onPressed: () {
                final provider =
                    Provider.of<UserProfileProvider>(context, listen: false);
                provider.refresh();
              },
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  /// ✏️ Afficher le dialog d'édition du profil
  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(),
    );
  }

  /// 🔒 Afficher le dialog de changement de mot de passe
  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => ChangePasswordDialog(),
    );
  }

  /// 🔔 Afficher le dialog des préférences de notification
  void _showNotificationPreferencesDialog() {
    showDialog(
      context: context,
      builder: (context) => const NotificationPreferencesDialog(),
    );
  }

  /// 🌍 Afficher le dialog des préférences de langue
  void _showLanguagePreferencesDialog() {
    showDialog(
      context: context,
      builder: (context) => const LanguagePreferencesDialog(),
    );
  }

  /// 🎨 Afficher le dialog des préférences de thème
  void _showThemePreferencesDialog() {
    showDialog(
      context: context,
      builder: (context) => const ThemePreferencesDialog(),
    );
  }

  /// 📍 Naviguer vers la gestion des adresses
  void _navigateToAddresses() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AddressManagementScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: AppAnimations.slideIn)),
            ),
            child: child,
          );
        },
        transitionDuration: AppAnimations.medium,
      ),
    );
  }

  /// 🆘 Naviguer vers le centre d'aide
  void _navigateToHelpCenter() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HelpCenterScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: AppAnimations.slideIn)),
            ),
            child: child,
          );
        },
        transitionDuration: AppAnimations.medium,
      ),
    );
  }

  /// 📞 Naviguer vers nous contacter
  void _navigateToContactUs() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ContactUsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: AppAnimations.slideIn)),
            ),
            child: child,
          );
        },
        transitionDuration: AppAnimations.medium,
      ),
    );
  }

  /// ℹ️ Afficher le dialog À propos
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_laundry_service,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Alpha Pressing',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Application mobile premium pour Alpha Pressing - Excellence & Innovation dans le pressing.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '© 2024 Alpha Pressing. Tous droits réservés.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary(context),
              ),
            ),
          ],
        ),
        actions: [
          PremiumButton(
            text: 'Fermer',
            onPressed: () => Navigator.pop(context),
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ],
      ),
    );
  }

  /// � Afficher le dialog de déconnexion
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.logout,
                color: AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Déconnecter',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                color: AppColors.textSecondary(context),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Voulez-vous vraiment vous déconnecter ? Vous pourrez vous reconnecter depuis la page de connexion.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Vous serez redirigé vers la page de connexion.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary(context),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          PremiumButton(
            text: 'Déconnecter',
            onPressed: () async {
              Navigator.pop(context);
              // Perform logout and navigate to login
              final authService = AuthService();
              await authService.logout();
              // Push replacement to LoginScreen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            backgroundColor: AppColors.error,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          ),
        ],
      ),
    );
  }

  /// 📱 Afficher SnackBar
  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess ? AppColors.success : AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusMD,
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
