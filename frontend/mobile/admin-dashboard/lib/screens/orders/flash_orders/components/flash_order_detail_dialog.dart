import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../../../models/order.dart';
import '../../../../constants.dart';
import '../../../../controllers/flash_order_stepper_controller.dart';
import '../../../../widgets/shared/glass_container.dart';
import 'flash_order_stepper.dart';
import 'copy_text_icon.dart';

class FlashOrderDetailDialog extends StatefulWidget {
  final Order order;

  const FlashOrderDetailDialog({Key? key, required this.order})
      : super(key: key);

  @override
  _FlashOrderDetailDialogState createState() => _FlashOrderDetailDialogState();
}

class _FlashOrderDetailDialogState extends State<FlashOrderDetailDialog>
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: 600,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: GlassContainer(
                  variant: GlassContainerVariant.neutral,
                  padding: EdgeInsets.zero,
                  borderRadius: AppRadius.xl,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(isDark),
                      Flexible(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          child: _buildContent(isDark),
                        ),
                      ),
                      _buildActions(isDark),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warning.withOpacity(0.1),
            AppColors.accent.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl),
          topRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.warning, AppColors.warning.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.warning.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.flash_on,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Commande Flash',
                      style: AppTextStyles.h3.copyWith(
                        color: isDark
                            ? AppColors.textLight
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.2),
                            AppColors.primary.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: AppRadius.radiusSM,
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '#${widget.order.id}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Détails de la commande flash',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
          _ModernCloseButton(
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildClientInfo(isDark),
        SizedBox(height: AppSpacing.lg),
        _buildOrderInfo(isDark),
        if (widget.order.items != null && widget.order.items!.isNotEmpty) ...[
          SizedBox(height: AppSpacing.lg),
          _buildArticlesInfo(isDark),
        ],
        SizedBox(height: AppSpacing.lg),
        _buildNoteInfo(isDark),
      ],
    );
  }

  Widget _buildClientInfo(bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: AppColors.primary,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Informations Client',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          if (widget.order.customerName != null &&
              widget.order.customerName!.isNotEmpty) ...[
            _buildInfoRow(
              'Nom',
              widget.order.customerName!,
              Icons.person_outline,
              isDark,
              copyable: true,
            ),
          ],
          if (widget.order.customerPhone != null &&
              widget.order.customerPhone!.isNotEmpty) ...[
            _buildInfoRow(
              'Téléphone',
              widget.order.customerPhone!,
              Icons.phone,
              isDark,
              copyable: true,
            ),
          ],
          if (widget.order.user != null &&
              widget.order.user!.email.isNotEmpty) ...[
            _buildInfoRow(
              'Email',
              widget.order.user!.email,
              Icons.email,
              isDark,
              copyable: true,
            ),
          ],
          if (widget.order.deliveryAddress != null) ...[
            _buildInfoRow(
              'Adresse',
              widget.order.deliveryAddress!,
              Icons.location_on,
              isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderInfo(bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: AppColors.accent,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Informations Commande',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _buildInfoRow(
            'Statut',
            widget.order.status,
            Icons.info,
            isDark,
          ),
          if (widget.order.totalAmount != null) ...[
            _buildInfoRow(
              'Montant Total',
              '${widget.order.totalAmount} FCFA',
              Icons.attach_money,
              isDark,
              highlight: true,
            ),
          ],
          if (widget.order.createdAt != null) ...[
            _buildInfoRow(
              'Date de création',
              _formatDate(widget.order.createdAt!),
              Icons.calendar_today,
              isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildArticlesInfo(bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shopping_bag,
                color: AppColors.info,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Articles (${widget.order.items!.length})',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          ...widget.order.items!.map((item) => Container(
                margin: EdgeInsets.only(bottom: AppSpacing.sm),
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.gray700 : AppColors.gray100)
                      .withOpacity(0.5),
                  borderRadius: AppRadius.radiusSM,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.info.withOpacity(0.2),
                            AppColors.info.withOpacity(0.1)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          '${item.quantity}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.info,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        item.article?.name ?? item.articleId,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.textLight
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildNoteInfo(bool isDark) {
    final note = widget.order.note;
    final hasNote = note != null && note.isNotEmpty;
    
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasNote ? Icons.note : Icons.note_outlined,
                color: hasNote ? AppColors.warning : AppColors.gray500,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Note de Commande',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: hasNote 
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.gray500.withOpacity(0.1),
                  borderRadius: AppRadius.radiusSM,
                  border: Border.all(
                    color: hasNote 
                      ? AppColors.success.withOpacity(0.3)
                      : AppColors.gray500.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  hasNote ? 'Note présente' : 'Aucune note',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: hasNote ? AppColors.success : AppColors.gray500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: hasNote
                ? (isDark ? AppColors.warning.withOpacity(0.1) : AppColors.warning.withOpacity(0.05))
                : (isDark ? AppColors.gray700 : AppColors.gray100).withOpacity(0.5),
              borderRadius: AppRadius.radiusSM,
              border: hasNote 
                ? Border.all(
                    color: AppColors.warning.withOpacity(0.2),
                    width: 1,
                  )
                : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasNote) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.warning,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        'Note créée lors de la commande flash :',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                ],
                Text(
                  hasNote ? note! : 'Aucune note n\'a été ajoutée lors de la création de cette commande flash.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: hasNote 
                      ? (isDark ? AppColors.textLight : AppColors.textPrimary)
                      : (isDark ? AppColors.gray400 : AppColors.gray600),
                    fontStyle: hasNote ? FontStyle.normal : FontStyle.italic,
                    fontWeight: hasNote ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
                if (hasNote) ...[
                  SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: AppRadius.radiusSM,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 14,
                          color: AppColors.info,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          'Cette note peut être modifiée après conversion en commande',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.info,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    bool isDark, {
    bool copyable = false,
    bool highlight = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? AppColors.gray400 : AppColors.gray600,
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
                SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: highlight
                        ? AppColors.success
                        : (isDark
                            ? AppColors.textLight
                            : AppColors.textPrimary),
                    fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (copyable) ...[
            SizedBox(width: AppSpacing.sm),
            CopyTextIcon(
              value: value,
              tooltip: 'Copier $label',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            (isDark ? AppColors.gray800 : AppColors.gray50).withOpacity(0.8),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: (isDark ? AppColors.gray700 : AppColors.gray200)
                .withOpacity(0.5),
          ),
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xl),
          bottomRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModernActionButton(
              label: 'Fermer',
              icon: Icons.close,
              variant: _FlashDetailActionVariant.secondary,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: _ModernActionButton(
              label: 'Convertir en Commande',
              icon: Icons.transform,
              variant: _FlashDetailActionVariant.primary,
              onPressed: () => _handleConversion(),
            ),
          ),
        ],
      ),
    );
  }

  void _handleConversion() {
    Navigator.of(context).pop(); // Ferme le dialog de détails

    final stepperController = Get.put(FlashOrderStepperController());
    stepperController.initDraftFromFlashOrder(widget.order);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 900,
          height: MediaQuery.of(context).size.height * 0.9,
          child: GlassContainer(
            variant: GlassContainerVariant.neutral,
            padding: EdgeInsets.zero,
            borderRadius: AppRadius.xl,
            child: FlashOrderStepper(),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// Composants pour le dialog de détails
enum _FlashDetailActionVariant { primary, secondary }

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
                          : (isDark
                              ? AppColors.textLight
                              : AppColors.textPrimary),
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

class _ModernActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final _FlashDetailActionVariant variant;
  final VoidCallback onPressed;

  const _ModernActionButton({
    required this.label,
    required this.icon,
    required this.variant,
    required this.onPressed,
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
            child: GlassContainer(
              variant: widget.variant == _FlashDetailActionVariant.primary
                  ? GlassContainerVariant.warning
                  : GlassContainerVariant.neutral,
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              borderRadius: AppRadius.lg,
              onTap: widget.onPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    color: widget.variant == _FlashDetailActionVariant.primary
                        ? Colors.white
                        : (isDark
                            ? AppColors.textLight
                            : AppColors.textPrimary),
                    size: 20,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    widget.label,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: widget.variant == _FlashDetailActionVariant.primary
                          ? Colors.white
                          : (isDark
                              ? AppColors.textLight
                              : AppColors.textPrimary),
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
