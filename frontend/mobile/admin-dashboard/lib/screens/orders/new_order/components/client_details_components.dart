import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:admin/constants.dart';
import 'package:admin/widgets/shared/glass_container.dart';
import 'package:admin/models/address.dart';

// Composants modernes pour le ClientDetailsDialog
enum _ClientActionVariant { primary, secondary, info, warning, error }

class _ModernCloseButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _ModernCloseButton({required this.onPressed});

  @override
  _ModernCloseButtonState createState() => _ModernCloseButtonState();
}

class _ModernCloseButtonState extends State<_ModernCloseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isHovered
                    ? AppColors.error.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isHovered
                      ? AppColors.error.withOpacity(0.3)
                      : (isDark ? AppColors.gray600 : AppColors.gray400),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius: BorderRadius.circular(20),
                  child: Center(
                    child: Icon(
                      Icons.close,
                      color: _isHovered
                          ? AppColors.error
                          : (isDark ? AppColors.textLight : AppColors.textPrimary),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ModernTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final bool isDark;

  const _ModernTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    required this.isDark,
  });

  @override
  _ModernTextFieldState createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<_ModernTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: (widget.isDark ? AppColors.gray700 : AppColors.gray100).withOpacity(0.5),
        borderRadius: AppRadius.md,
        border: Border.all(
          color: _isFocused
              ? AppColors.primary.withOpacity(0.5)
              : (widget.isDark ? AppColors.gray600 : AppColors.gray300).withOpacity(0.5),
        ),
      ),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        style: AppTextStyles.bodyMedium.copyWith(
          color: widget.isDark ? AppColors.textLight : AppColors.textPrimary,
        ),
        onTap: () => setState(() => _isFocused = true),
        onEditingComplete: () => setState(() => _isFocused = false),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            color: _isFocused
                ? AppColors.primary
                : (widget.isDark ? AppColors.gray400 : AppColors.gray600),
          ),
          prefixIcon: Icon(
            widget.icon,
            color: _isFocused
                ? AppColors.primary
                : (widget.isDark ? AppColors.gray400 : AppColors.gray600),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(AppSpacing.md),
        ),
      ),
    );
  }
}

class _ModernSaveButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const _ModernSaveButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  _ModernSaveButtonState createState() => _ModernSaveButtonState();
}

class _ModernSaveButtonState extends State<_ModernSaveButton>
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
        if (widget.onPressed != null) {
          setState(() => _isHovered = true);
          _controller.forward();
        }
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
              variant: GlassContainerVariant.primary,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              borderRadius: AppRadius.lg,
              onTap: widget.onPressed,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isLoading) ...[
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                  ] else ...[
                    Icon(
                      Icons.save,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    widget.isLoading ? 'Enregistrement...' : 'Enregistrer',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: Colors.white,
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

class _ModernActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final _ClientActionVariant variant;

  const _ModernActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.variant,
  });

  @override
  _ModernActionButtonState createState() => _ModernActionButtonState();
}

class _ModernActionButtonState extends State<_ModernActionButton>
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
      end: 1.05,
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

  Color _getVariantColor() {
    switch (widget.variant) {
      case _ClientActionVariant.primary:
        return AppColors.primary;
      case _ClientActionVariant.secondary:
        return AppColors.gray600;
      case _ClientActionVariant.info:
        return AppColors.info;
      case _ClientActionVariant.warning:
        return AppColors.warning;
      case _ClientActionVariant.error:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final variantColor = _getVariantColor();
    final isEnabled = widget.onPressed != null;

    return MouseRegion(
      onEnter: (_) {
        if (isEnabled) {
          setState(() => _isHovered = true);
          _controller.forward();
        }
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
              variant: widget.variant == _ClientActionVariant.warning
                  ? GlassContainerVariant.warning
                  : GlassContainerVariant.neutral,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              borderRadius: AppRadius.md,
              onTap: isEnabled ? widget.onPressed : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    color: widget.variant == _ClientActionVariant.warning
                        ? Colors.white
                        : variantColor,
                    size: 18,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    widget.label,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: widget.variant == _ClientActionVariant.warning
                          ? Colors.white
                          : variantColor,
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

class _AddressCard extends StatefulWidget {
  final Address address;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  _AddressCardState createState() => _AddressCardState();
}

class _AddressCardState extends State<_AddressCard>
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
            child: Container(
              margin: EdgeInsets.only(bottom: AppSpacing.sm),
              child: GlassContainer(
                variant: widget.address.isDefault
                    ? GlassContainerVariant.info
                    : GlassContainerVariant.neutral,
                padding: EdgeInsets.all(AppSpacing.md),
                borderRadius: AppRadius.md,
                child: Row(
                  children: [
                    // Icône d'adresse
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.address.isDefault
                              ? [AppColors.info, AppColors.info.withOpacity(0.8)]
                              : [AppColors.gray500, AppColors.gray400],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.address.isDefault ? Icons.home : Icons.location_on,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    
                    // Informations de l'adresse
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.address.name.isNotEmpty) ...[
                            Text(
                              widget.address.name,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: widget.isDark ? AppColors.textLight : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: AppSpacing.xs),
                          ],
                          Text(
                            widget.address.street,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: widget.isDark ? AppColors.gray300 : AppColors.gray700,
                            ),
                          ),
                          Text(
                            '${widget.address.city} ${widget.address.postalCode}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: widget.isDark ? AppColors.gray400 : AppColors.gray600,
                            ),
                          ),
                          if (widget.address.isDefault) ...[
                            SizedBox(height: AppSpacing.xs),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.info.withOpacity(0.2),
                                borderRadius: AppRadius.radiusXS,
                              ),
                              child: Text(
                                'ADRESSE PAR DÉFAUT',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.info,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Actions
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _AddressActionButton(
                          icon: Icons.edit,
                          onPressed: widget.onEdit,
                          color: AppColors.warning,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        _AddressActionButton(
                          icon: Icons.delete,
                          onPressed: widget.onDelete,
                          color: AppColors.error,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AddressActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const _AddressActionButton({
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  @override
  _AddressActionButtonState createState() => _AddressActionButtonState();
}

class _AddressActionButtonState extends State<_AddressActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.color.withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ModernConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;

  const _ModernConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        child: GlassContainer(
          variant: GlassContainerVariant.neutral,
          padding: EdgeInsets.all(AppSpacing.xl),
          borderRadius: AppRadius.xl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDestructive
                        ? [AppColors.error, AppColors.error.withOpacity(0.8)]
                        : [AppColors.warning, AppColors.warning.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  isDestructive ? Icons.delete_forever : Icons.help_outline,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              
              // Titre
              Text(
                title,
                style: AppTextStyles.h3.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.md),
              
              // Message
              Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.gray300 : AppColors.gray700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xl),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: _ModernActionButton(
                      icon: Icons.close,
                      label: cancelText,
                      onPressed: () => Get.back(result: false),
                      variant: _ClientActionVariant.secondary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _ModernActionButton(
                      icon: isDestructive ? Icons.delete : Icons.check,
                      label: confirmText,
                      onPressed: () => Get.back(result: true),
                      variant: isDestructive 
                          ? _ClientActionVariant.error 
                          : _ClientActionVariant.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModernPasswordResetDialog extends StatelessWidget {
  final dynamic user;
  final String tempPassword;

  const _ModernPasswordResetDialog({
    required this.user,
    required this.tempPassword,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
        child: GlassContainer(
          variant: GlassContainerVariant.neutral,
          padding: EdgeInsets.all(AppSpacing.xl),
          borderRadius: AppRadius.xl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header avec icône
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.lock_reset,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              
              Text(
                'Mot de passe réinitialisé',
                style: AppTextStyles.h2.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.lg),
              
              // Informations client
              GlassContainer(
                variant: GlassContainerVariant.neutral,
                padding: EdgeInsets.all(AppSpacing.md),
                borderRadius: AppRadius.md,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(
                      label: 'Client',
                      value: '${user['firstName']} ${user['lastName']}',
                      isDark: isDark,
                    ),
                    _InfoRow(
                      label: 'Email',
                      value: user['email'],
                      isDark: isDark,
                    ),
                    _InfoRow(
                      label: 'Téléphone',
                      value: user['phone'] ?? '-',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              
              // Nouveau mot de passe
              GlassContainer(
                variant: GlassContainerVariant.warning,
                padding: EdgeInsets.all(AppSpacing.md),
                borderRadius: AppRadius.md,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nouveau mot de passe',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    SelectableText(
                      tempPassword,
                      style: AppTextStyles.h3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: _ModernActionButton(
                      icon: Icons.copy,
                      label: 'Copier tout',
                      onPressed: () => _copyInfo(),
                      variant: _ClientActionVariant.info,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _ModernActionButton(
                      icon: Icons.close,
                      label: 'Fermer',
                      onPressed: () => Get.back(),
                      variant: _ClientActionVariant.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyInfo() {
    final info = '''Client : ${user['firstName']} ${user['lastName']}
Email : ${user['email']}
Téléphone : ${user['phone'] ?? '-'}
Nouveau mot de passe : $tempPassword''';
    
    Clipboard.setData(ClipboardData(text: info));
    
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(Icons.copy, color: Colors.white, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Informations copiées dans le presse-papier',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.success.withOpacity(0.85),
      borderRadius: 16,
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label :',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}