import 'package:admin/widgets/glass_button.dart';
import 'package:admin/widgets/shared/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../constants.dart';
import '../../../../../controllers/orders_controller.dart';
import '../../../components/order_address_dialog.dart';
import '../../../../../models/address.dart';
import 'order_address_components.dart';
import 'dart:ui';

class OrderAddressStep extends StatefulWidget {
  @override
  State<OrderAddressStep> createState() => _OrderAddressStepState();
}

class _OrderAddressStepState extends State<OrderAddressStep>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  final OrdersController controller = Get.find<OrdersController>();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _autoSelectDefaultAddress();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
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

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _autoSelectDefaultAddress() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addresses = controller.clientAddresses;
      if ((controller.selectedAddressId.value == null ||
              controller.orderDraft.value.addressId == null) &&
          addresses.isNotEmpty) {
        final defaultAddress =
            addresses.firstWhereOrNull((a) => a.isDefault) ?? addresses.first;
        controller.selectAddress(defaultAddress.id);
        controller.setSelectedAddress(defaultAddress.id);
      }
    });
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
                    child: Obx(() => _buildAddressContent(isDark)),
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
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.lg,
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
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
              );
            },
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adresse de Livraison',
                  style: AppTextStyles.h2.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Sélectionnez l\'adresse de livraison',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            if (controller.selectedAddressId.value != null) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
                  ),
                  borderRadius: AppRadius.md,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Adresse sélectionnée',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }
            return SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildAddressContent(bool isDark) {
    final addresses = controller.clientAddresses;
    final selectedAddress = addresses.firstWhereOrNull(
      (a) => a.id == controller.selectedAddressId.value,
    );

    if (addresses.isEmpty) {
      return _buildEmptyAddresses(isDark);
    }

    return Column(
      children: [
        if (selectedAddress != null) ...[
          _buildSelectedAddress(selectedAddress, isDark),
          SizedBox(height: AppSpacing.lg),
        ],
        
        Expanded(child: _buildAddressList(addresses, isDark)),
        
        SizedBox(height: AppSpacing.lg),
        _buildAddressActions(selectedAddress, isDark),
      ],
    );
  }

  Widget _buildSelectedAddress(Address address, bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.success,
      padding: EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Adresse Sélectionnée',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          
          _AddressInfoCard(
            address: address,
            isSelected: true,
            showActions: false,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList(List<Address> addresses, bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.list_alt,
                color: AppColors.accent,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Adresses Disponibles (${addresses.length})',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          
          Expanded(
            child: ListView.separated(
              itemCount: addresses.length,
              separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final address = addresses[index];
                final isSelected = controller.selectedAddressId.value == address.id;
                
                return _AddressCard(
                  address: address,
                  isSelected: isSelected,
                  onSelect: () {
                    controller.selectAddress(address.id);
                    controller.setSelectedAddress(address.id);
                  },
                  onEdit: () => _openAddressDialog(address),
                  isDark: isDark,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAddresses(bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.neutral,
      padding: EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.lg,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: isDark ? AppColors.gray400 : AppColors.gray500,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Aucune adresse disponible',
              style: AppTextStyles.h3.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.gray700,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Le client n\'a pas d\'adresse enregistrée',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            
            _ModernActionButton(
              icon: Icons.add_location,
              label: 'Créer une adresse',
              onPressed: () => _createNewAddress(),
              variant: _AddressActionVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressActions(Address? selectedAddress, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _ModernActionButton(
            icon: Icons.add_location,
            label: 'Nouvelle Adresse',
            onPressed: () => _createNewAddress(),
            variant: _AddressActionVariant.info,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: _ModernActionButton(
            icon: Icons.edit_location,
            label: selectedAddress != null ? 'Modifier' : 'Choisir',
            onPressed: selectedAddress != null
                ? () => _openAddressDialog(selectedAddress)
                : () => _chooseAddress(),
            variant: _AddressActionVariant.primary,
          ),
        ),
      ],
    );
  }

  Future<void> _openAddressDialog(Address address) async {
    final orderId = controller.currentOrderId.value ?? '';
    await showDialog(
      context: context,
      builder: (ctx) => OrderAddressDialog(
        initialAddress: address,
        orderId: orderId,
        onAddressSaved: (updatedAddress) {
          controller.selectAddress(updatedAddress.id);
          controller.setSelectedAddress(updatedAddress.id);
          _showSuccessSnackbar('Adresse mise à jour avec succès');
        },
      ),
    );
  }

  void _createNewAddress() {
    final clientId = controller.selectedClientId.value;
    if (clientId == null) {
      _showErrorSnackbar('Aucun client sélectionné');
      return;
    }

    final emptyAddress = Address.empty(userId: clientId);
    _openAddressDialog(emptyAddress);
  }

  void _chooseAddress() {
    final addresses = controller.clientAddresses;
    if (addresses.isEmpty) {
      _createNewAddress();
      return;
    }

    final firstAddress = addresses.first;
    _openAddressDialog(firstAddress);
  }

  void _showSuccessSnackbar(String message) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
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

  void _showErrorSnackbar(String message) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.white, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.error.withOpacity(0.85),
      borderRadius: 16,
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 3),
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