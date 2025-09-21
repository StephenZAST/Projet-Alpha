import 'package:admin/controllers/flash_order_stepper_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'package:admin/services/user_service.dart';
import 'package:admin/widgets/shared/client_selection_dialog.dart';
import 'package:admin/widgets/shared/glass_container.dart';
import 'package:admin/models/user.dart';
import 'package:admin/constants.dart';

class FlashClientStep extends StatefulWidget {
  final FlashOrderStepperController controller;

  const FlashClientStep({Key? key, required this.controller}) : super(key: key);

  @override
  _FlashClientStepState createState() => _FlashClientStepState();
}

class _FlashClientStepState extends State<FlashClientStep>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _fetchUser(String userId) async {
    try {
      final user = await UserService.getUserById(userId);
      return {
        'firstName': user.firstName,
        'lastName': user.lastName,
        'email': user.email,
        'phone': user.phone,
        'role': user.role.label,
        'isActive': user.isActive,
        'loyaltyPoints': user.loyaltyPoints,
      };
    } catch (e) {
      print('[FlashClientStep] Erreur lors de la récupération du client: $e');
      return {'error': e.toString()};
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepHeader(isDark),
                  SizedBox(height: AppSpacing.xl),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Obx(() {
                        // Accès direct à la variable observable pour déclencher la réactivité
                        widget.controller.draft.value;
                        return _buildClientContent(isDark);
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8)
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.person_search,
                color: Colors.white,
                size: 24,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vérification Client',
                    style: AppTextStyles.h3.copyWith(
                      color:
                          isDark ? AppColors.textLight : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Confirmez ou modifiez les informations du client',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClientContent(bool isDark) {
    final draft = widget.controller.draft.value;

    if (draft.userId == null) {
      return _buildNoClientSelected(isDark);
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchUser(draft.userId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(isDark);
        }

        if (snapshot.hasError ||
            (snapshot.hasData && snapshot.data?['error'] != null)) {
          return _buildErrorState(
              isDark, snapshot.data?['error'] ?? snapshot.error.toString());
        }

        if (!snapshot.hasData) {
          return _buildNoDataState(isDark);
        }

        return _buildClientInfo(isDark, snapshot.data!);
      },
    );
  }

  Widget _buildNoClientSelected(bool isDark) {
    return Center(
      child: GlassContainer(
        variant: GlassContainerVariant.neutral,
        padding: EdgeInsets.all(AppSpacing.xl),
        borderRadius: AppRadius.xl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.2),
                    AppColors.primary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.person_add,
                color: AppColors.primary,
                size: 40,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Aucun client sélectionné',
              style: AppTextStyles.h3.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Sélectionnez un client pour continuer la conversion',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.gray700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            _ModernSelectClientButton(
              onPressed: () => _showClientSelection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.6)],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Chargement des informations client...',
            style: AppTextStyles.bodyLarge.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark, String error) {
    return Center(
      child: GlassContainer(
        variant: GlassContainerVariant.error,
        padding: EdgeInsets.all(AppSpacing.xl),
        borderRadius: AppRadius.xl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 32,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Erreur de chargement',
              style: AppTextStyles.h3.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.gray700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            _ModernSelectClientButton(
              onPressed: () => _showClientSelection(),
              label: 'Changer de client',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataState(bool isDark) {
    return Center(
      child: GlassContainer(
        variant: GlassContainerVariant.neutral,
        padding: EdgeInsets.all(AppSpacing.xl),
        borderRadius: AppRadius.xl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_off,
              color: isDark ? AppColors.gray400 : AppColors.gray600,
              size: 64,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Client introuvable',
              style: AppTextStyles.h3.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            _ModernSelectClientButton(
              onPressed: () => _showClientSelection(),
              label: 'Sélectionner un autre client',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfo(bool isDark, Map<String, dynamic> user) {
    return Column(
      children: [
        // Carte principale du client
        GlassContainer(
          variant: GlassContainerVariant.primary,
          padding: EdgeInsets.all(AppSpacing.lg),
          borderRadius: AppRadius.lg,
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.1)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user['firstName']} ${user['lastName']}',
                          style: AppTextStyles.h3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user['email'] ?? 'Email non disponible',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: (user['isActive'] == true
                              ? AppColors.success
                              : AppColors.error)
                          .withOpacity(0.2),
                      borderRadius: AppRadius.radiusSM,
                      border: Border.all(
                        color: (user['isActive'] == true
                                ? AppColors.success
                                : AppColors.error)
                            .withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      user['isActive'] == true ? 'Actif' : 'Inactif',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: AppSpacing.lg),

        // Informations détaillées
        GlassContainer(
          variant: GlassContainerVariant.neutral,
          padding: EdgeInsets.all(AppSpacing.lg),
          borderRadius: AppRadius.lg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informations détaillées',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              if (user['phone'] != null &&
                  user['phone'].toString().isNotEmpty) ...[
                _buildInfoRow(
                  'Téléphone',
                  user['phone'].toString(),
                  Icons.phone,
                  isDark,
                ),
              ],
              if (user['role'] != null) ...[
                _buildInfoRow(
                  'Rôle',
                  user['role'].toString(),
                  Icons.badge,
                  isDark,
                ),
              ],
              if (user['loyaltyPoints'] != null) ...[
                _buildInfoRow(
                  'Points fidélité',
                  '${user['loyaltyPoints']} points',
                  Icons.stars,
                  isDark,
                  highlight: true,
                ),
              ],
            ],
          ),
        ),

        SizedBox(height: AppSpacing.lg),

        // Bouton de changement
        _ModernSelectClientButton(
          onPressed: () => _showClientSelection(),
          label: 'Changer de client',
          variant: _ClientButtonVariant.secondary,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, bool isDark,
      {bool highlight = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: highlight
                ? AppColors.warning
                : (isDark ? AppColors.gray400 : AppColors.gray600),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: highlight
                        ? AppColors.warning
                        : (isDark
                            ? AppColors.textLight
                            : AppColors.textPrimary),
                    fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClientSelection() async {
    final selectedClient = await showDialog(
      context: context,
      builder: (ctx) => ClientSelectionDialog(
        initialSelectedClientId: widget.controller.draft.value.userId,
      ),
    );

    if (selectedClient != null && selectedClient is String) {
      widget.controller.setDraftField('userId', selectedClient);
    }
  }
}

// Composants spécialisés pour l'étape client
enum _ClientButtonVariant { primary, secondary }

class _ModernSelectClientButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final _ClientButtonVariant variant;

  const _ModernSelectClientButton({
    required this.onPressed,
    this.label = 'Sélectionner un client',
    this.variant = _ClientButtonVariant.primary,
  });

  @override
  _ModernSelectClientButtonState createState() =>
      _ModernSelectClientButtonState();
}

class _ModernSelectClientButtonState extends State<_ModernSelectClientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GlassContainer(
              variant: widget.variant == _ClientButtonVariant.primary
                  ? GlassContainerVariant.primary
                  : GlassContainerVariant.neutral,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              borderRadius: AppRadius.lg,
              onTap: widget.onPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    color: widget.variant == _ClientButtonVariant.primary
                        ? Colors.white
                        : AppColors.primary,
                    size: 20,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    widget.label,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: widget.variant == _ClientButtonVariant.primary
                          ? Colors.white
                          : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
