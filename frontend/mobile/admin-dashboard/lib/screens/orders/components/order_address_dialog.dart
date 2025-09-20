import 'package:admin/controllers/orders_controller.dart';
import 'package:admin/widgets/shared/glass_container.dart';
import 'package:admin/constants.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:admin/models/address.dart';
import 'package:admin/screens/orders/components/address_selection_map.dart';
import 'package:admin/screens/orders/components/client_addresses_tab.dart';
import 'dart:ui';

class OrderAddressDialog extends StatefulWidget {
  final Address initialAddress;
  final String orderId;
  final Function(Address)? onAddressSaved;

  const OrderAddressDialog({
    Key? key,
    required this.initialAddress,
    required this.orderId,
    this.onAddressSaved,
  }) : super(key: key);

  @override
  State<OrderAddressDialog> createState() => _OrderAddressDialogState();
}

class _OrderAddressDialogState extends State<OrderAddressDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _tabAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _selectedTabIndex = _tabController.index);
      }
    });

    final OrdersController controller = Get.find<OrdersController>();
    if (controller.orderAddressEditForm.isEmpty) {
      controller.loadOrderAddressEditForm(widget.initialAddress);
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _tabAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
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
    _tabAnimationController.dispose();
    _tabController.dispose();
    super.dispose();
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
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 800,
                height: MediaQuery.of(context).size.height * 0.85,
                child: GlassContainer(
                  variant: GlassContainerVariant.neutral,
                  padding: EdgeInsets.zero,
                  borderRadius: AppRadius.xl,
                  child: Column(
                    children: [
                      _buildDialogHeader(isDark),
                      _buildTabBar(isDark),
                      Expanded(
                        child: _buildTabContent(isDark),
                      ),
                      _buildDialogActions(isDark),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.info.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
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
                colors: [AppColors.info, AppColors.info.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.info.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.location_on,
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
                  'Modifier l\'Adresse',
                  style: AppTextStyles.h2.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Gestion de l\'adresse de livraison',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
          _ModernCloseButton(
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          _ModernTabButton(
            label: 'Détails',
            icon: Icons.edit_location,
            isSelected: _selectedTabIndex == 0,
            onPressed: () => _tabController.animateTo(0),
            isDark: isDark,
          ),
          SizedBox(width: AppSpacing.sm),
          _ModernTabButton(
            label: 'Carte',
            icon: Icons.map,
            isSelected: _selectedTabIndex == 1,
            onPressed: () => _tabController.animateTo(1),
            isDark: isDark,
          ),
          SizedBox(width: AppSpacing.sm),
          _ModernTabButton(
            label: 'Adresses Client',
            icon: Icons.list_alt,
            isSelected: _selectedTabIndex == 2,
            onPressed: () => _tabController.animateTo(2),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(bool isDark) {
    final OrdersController controller = Get.find<OrdersController>();

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildAddressForm(controller, isDark),
          _buildMapTab(isDark),
          _buildClientAddressesTab(isDark),
        ],
      ),
    );
  }

  Widget _buildDialogActions(bool isDark) {
    final OrdersController controller = Get.find<OrdersController>();

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: (isDark ? AppColors.gray600 : AppColors.gray300)
                .withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModernActionButton(
              icon: Icons.close,
              label: 'Annuler',
              onPressed: () => Get.back(),
              variant: _AddressActionVariant.secondary,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Obx(() => _ModernActionButton(
                  icon: Icons.save,
                  label: 'Enregistrer',
                  onPressed: () => _onSavePressed(context, controller),
                  variant: _AddressActionVariant.primary,
                  isLoading: controller.isLoading.value,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressForm(OrdersController controller, bool isDark) {
    return Obx(() => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section informations de base
              GlassContainer(
                variant: GlassContainerVariant.neutral,
                padding: EdgeInsets.all(AppSpacing.lg),
                borderRadius: AppRadius.lg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.edit_location,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Informations de l\'Adresse',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: isDark
                                ? AppColors.textLight
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.lg),
                    _ModernAddressField(
                      label: 'Nom de l\'adresse',
                      icon: Icons.label,
                      value: controller.orderAddressEditForm['name'] ?? '',
                      onChanged: (v) =>
                          controller.setOrderAddressEditField('name', v),
                      isDark: isDark,
                      hint: 'Ex: Domicile, Bureau...',
                    ),
                    SizedBox(height: AppSpacing.md),
                    _ModernAddressField(
                      label: 'Rue et numéro',
                      icon: Icons.home,
                      value: controller.orderAddressEditForm['street'] ?? '',
                      onChanged: (v) =>
                          controller.setOrderAddressEditField('street', v),
                      isDark: isDark,
                      hint: 'Adresse complète',
                      isRequired: true,
                    ),
                    SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _ModernAddressField(
                            label: 'Ville',
                            icon: Icons.location_city,
                            value:
                                controller.orderAddressEditForm['city'] ?? '',
                            onChanged: (v) =>
                                controller.setOrderAddressEditField('city', v),
                            isDark: isDark,
                            hint: 'Ville',
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _ModernAddressField(
                            label: 'Code postal',
                            icon: Icons.markunread_mailbox,
                            value:
                                controller.orderAddressEditForm['postalCode'] ??
                                    '',
                            onChanged: (v) => controller
                                .setOrderAddressEditField('postalCode', v),
                            isDark: isDark,
                            hint: 'CP',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppSpacing.lg),

              // Section coordonnées GPS
              if (controller.orderAddressEditForm['gpsLatitude'] != null ||
                  controller.orderAddressEditForm['gpsLongitude'] != null)
                GlassContainer(
                  variant: GlassContainerVariant.info,
                  padding: EdgeInsets.all(AppSpacing.lg),
                  borderRadius: AppRadius.lg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.gps_fixed,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            'Coordonnées GPS',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: _GPSInfoCard(
                              label: 'Latitude',
                              value: controller
                                      .orderAddressEditForm['gpsLatitude']
                                      ?.toString() ??
                                  'Non définie',
                              icon: Icons.north,
                            ),
                          ),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _GPSInfoCard(
                              label: 'Longitude',
                              value: controller
                                      .orderAddressEditForm['gpsLongitude']
                                      ?.toString() ??
                                  'Non définie',
                              icon: Icons.east,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ));
  }

  Widget _buildMapTab(bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.lg,
      child: AddressSelectionMap(
        initialAddress: widget.initialAddress,
        onAddressSelected: (address) {
          final controller = Get.find<OrdersController>();
          controller.loadOrderAddressEditForm(address);
          controller.setOrderAddressEditField('isDefault', true);
        },
      ),
    );
  }

  Widget _buildClientAddressesTab(bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.lg,
      child: ClientAddressesTab(
        userId: widget.initialAddress.userId,
        selectedAddress: _addressFromForm(Get.find<OrdersController>()),
        onAddressSelected: (address) {
          final controller = Get.find<OrdersController>();
          controller.loadOrderAddressEditForm(address);
          controller.setOrderAddressEditField('isDefault', true);
          _tabController.animateTo(0);
        },
        onAddNewAddress: () {
          final controller = Get.find<OrdersController>();
          controller.clearOrderAddressEditForm();
          controller.setOrderAddressEditField('isDefault', true);
          _tabController.animateTo(0);
        },
      ),
    );
  }

  Address _addressFromForm(OrdersController controller) {
    // Fournit tous les champs requis pour Address
    return Address(
      id: controller.orderAddressEditForm['id'] ?? '',
      name: controller.orderAddressEditForm['name'] ?? '',
      street: controller.orderAddressEditForm['street'] ?? '',
      city: controller.orderAddressEditForm['city'] ?? '',
      postalCode: controller.orderAddressEditForm['postalCode'] ?? '',
      gpsLatitude: controller.orderAddressEditForm['gpsLatitude'],
      gpsLongitude: controller.orderAddressEditForm['gpsLongitude'],
      userId: controller.orderAddressEditForm['userId'] ?? '',
      isDefault: controller.orderAddressEditForm['isDefault'] ?? false,
      createdAt: controller.orderAddressEditForm['createdAt'] ?? DateTime.now(),
      updatedAt: controller.orderAddressEditForm['updatedAt'] ?? DateTime.now(),
    );
  }

  Future<void> _onSavePressed(
      BuildContext context, OrdersController controller) async {
    // Validation simple
    if ((controller.orderAddressEditForm['street'] ?? '').isEmpty) {
      Get.rawSnackbar(
        messageText: const Text('Veuillez renseigner une adresse valide.'),
        backgroundColor: Colors.red,
        borderRadius: 12,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      return;
    }
    try {
      await controller.updateOrderAddress(widget.orderId,
          Map<String, dynamic>.from(controller.orderAddressEditForm));
      if (widget.onAddressSaved != null) {
        widget.onAddressSaved!(_addressFromForm(controller));
      }
      Navigator.of(context).pop();
      Get.rawSnackbar(
        messageText: const Text('Adresse enregistrée avec succès.'),
        backgroundColor: Colors.green,
        borderRadius: 12,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.rawSnackbar(
        messageText: Text('Erreur lors de la sauvegarde : $e'),
        backgroundColor: Colors.red,
        borderRadius: 12,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }
}

// Composants modernes pour OrderAddressDialog
enum _AddressActionVariant { primary, secondary, info, warning, error }

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

class _ModernTabButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onPressed;
  final bool isDark;

  const _ModernTabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onPressed,
    required this.isDark,
  });

  @override
  _ModernTabButtonState createState() => _ModernTabButtonState();
}

class _ModernTabButtonState extends State<_ModernTabButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

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
        _controller.forward();
      },
      onExit: (_) {
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GlassContainer(
              variant: widget.isSelected
                  ? GlassContainerVariant.primary
                  : GlassContainerVariant.neutral,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              borderRadius: AppRadius.lg,
              onTap: widget.onPressed,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    color: widget.isSelected
                        ? Colors.white
                        : (widget.isDark
                            ? AppColors.textLight
                            : AppColors.textPrimary),
                    size: 18,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    widget.label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: widget.isSelected
                          ? Colors.white
                          : (widget.isDark
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

class _ModernActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final _AddressActionVariant variant;
  final bool isLoading;

  const _ModernActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.variant,
    this.isLoading = false,
  });

  @override
  _ModernActionButtonState createState() => _ModernActionButtonState();
}

class _ModernActionButtonState extends State<_ModernActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

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

  Color _getVariantColor() {
    switch (widget.variant) {
      case _AddressActionVariant.primary:
        return AppColors.primary;
      case _AddressActionVariant.secondary:
        return AppColors.gray600;
      case _AddressActionVariant.info:
        return AppColors.info;
      case _AddressActionVariant.warning:
        return AppColors.warning;
      case _AddressActionVariant.error:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final variantColor = _getVariantColor();
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return MouseRegion(
      onEnter: (_) {
        if (isEnabled) {
          _controller.forward();
        }
      },
      onExit: (_) {
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GlassContainer(
              variant: widget.variant == _AddressActionVariant.primary
                  ? GlassContainerVariant.primary
                  : GlassContainerVariant.neutral,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              borderRadius: AppRadius.lg,
              onTap: isEnabled ? widget.onPressed : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading) ...[
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.variant == _AddressActionVariant.primary
                              ? Colors.white
                              : variantColor,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                  ] else ...[
                    Icon(
                      widget.icon,
                      color: widget.variant == _AddressActionVariant.primary
                          ? Colors.white
                          : variantColor,
                      size: 20,
                    ),
                    SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    widget.isLoading ? 'Traitement...' : widget.label,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: widget.variant == _AddressActionVariant.primary
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

class _ModernAddressField extends StatefulWidget {
  final String label;
  final IconData icon;
  final String value;
  final ValueChanged<String> onChanged;
  final bool isDark;
  final String? hint;
  final bool isRequired;

  const _ModernAddressField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    required this.isDark,
    this.hint,
    this.isRequired = false,
  });

  @override
  _ModernAddressFieldState createState() => _ModernAddressFieldState();
}

class _ModernAddressFieldState extends State<_ModernAddressField> {
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_ModernAddressField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: AppTextStyles.bodyMedium.copyWith(
                color:
                    widget.isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.isRequired) ...[
              SizedBox(width: AppSpacing.xs),
              Text(
                '*',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: (widget.isDark ? AppColors.gray700 : AppColors.gray100)
                .withOpacity(0.5),
            borderRadius: AppRadius.radiusMD,
            border: Border.all(
              color: _isFocused
                  ? AppColors.primary.withOpacity(0.5)
                  : widget.isRequired && widget.value.isEmpty
                      ? AppColors.error.withOpacity(0.5)
                      : (widget.isDark ? AppColors.gray600 : AppColors.gray300)
                          .withOpacity(0.5),
            ),
          ),
          child: TextFormField(
            controller: _controller,
            style: AppTextStyles.bodyMedium.copyWith(
              color:
                  widget.isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
            onChanged: widget.onChanged,
            onTap: () => setState(() => _isFocused = true),
            onEditingComplete: () => setState(() => _isFocused = false),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: widget.isDark ? AppColors.gray400 : AppColors.gray600,
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
        ),
      ],
    );
  }
}

class _GPSInfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _GPSInfoCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 16,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
