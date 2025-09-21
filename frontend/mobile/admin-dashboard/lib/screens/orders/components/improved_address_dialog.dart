import 'package:admin/controllers/orders_controller.dart';
import 'package:admin/widgets/shared/glass_container.dart';
import 'package:admin/constants.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:admin/models/address.dart';
import 'package:admin/screens/orders/components/client_addresses_tab.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:ui';
import 'improved_map_widget.dart';
import 'order_address_components.dart';

class ImprovedAddressDialog extends StatefulWidget {
  final Address initialAddress;
  final String orderId;
  final Function(Address)? onAddressSaved;

  const ImprovedAddressDialog({
    Key? key,
    required this.initialAddress,
    required this.orderId,
    this.onAddressSaved,
  }) : super(key: key);

  @override
  State<ImprovedAddressDialog> createState() => _ImprovedAddressDialogState();
}

class _ImprovedAddressDialogState extends State<ImprovedAddressDialog>
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
                width: 900,
                height: MediaQuery.of(context).size.height * 0.9,
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
                  'Gestion avancée de l\'adresse de livraison',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
          ModernCloseButton(
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          ModernTabButton(
            label: 'Détails',
            icon: Icons.edit_location,
            isSelected: _selectedTabIndex == 0,
            onPressed: () => _tabController.animateTo(0),
            isDark: isDark,
          ),
          SizedBox(width: AppSpacing.sm),
          ModernTabButton(
            label: 'Carte Interactive',
            icon: Icons.map,
            isSelected: _selectedTabIndex == 1,
            onPressed: () => _tabController.animateTo(1),
            isDark: isDark,
          ),
          SizedBox(width: AppSpacing.sm),
          ModernTabButton(
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
          _buildImprovedMapTab(controller, isDark),
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
            child: ModernActionButton(
              icon: Icons.close,
              label: 'Annuler',
              onPressed: () => Get.back(),
              variant: AddressActionVariant.secondary,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Obx(() => ModernActionButton(
                  icon: Icons.save,
                  label: 'Enregistrer',
                  onPressed: () => _onSavePressed(context, controller),
                  variant: AddressActionVariant.primary,
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
                    ModernAddressField(
                      label: 'Nom de l\'adresse',
                      icon: Icons.label,
                      value: controller.orderAddressEditForm['name'] ?? '',
                      onChanged: (v) =>
                          controller.setOrderAddressEditField('name', v),
                      isDark: isDark,
                      hint: 'Ex: Domicile, Bureau...',
                    ),
                    SizedBox(height: AppSpacing.md),
                    ModernAddressField(
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
                          child: ModernAddressField(
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
                          child: ModernAddressField(
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
                            child: GPSInfoCard(
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
                            child: GPSInfoCard(
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

  Widget _buildImprovedMapTab(OrdersController controller, bool isDark) {
    return Obx(() {
      final lat = controller.orderAddressEditForm['gpsLatitude'];
      final lng = controller.orderAddressEditForm['gpsLongitude'];
      
      return GlassContainer(
        variant: GlassContainerVariant.neutral,
        padding: EdgeInsets.all(AppSpacing.md),
        borderRadius: AppRadius.lg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de la carte
            Row(
              children: [
                Icon(
                  Icons.map,
                  color: AppColors.primary,
                  size: 20,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Localisation Interactive',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                if (lat != null && lng != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.gps_fixed,
                          color: AppColors.success,
                          size: 14,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          'GPS Défini',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            
            // Carte améliorée
            Expanded(
              child: ImprovedMapWidget(
                initialCenter: lat != null && lng != null
                    ? LatLng(lat.toDouble(), lng.toDouble())
                    : const LatLng(12.3714, -1.5197), // Ouagadougou par défaut
                initialZoom: 15.0,
                markers: lat != null && lng != null
                    ? [
                        Marker(
                          point: LatLng(lat.toDouble(), lng.toDouble()),
                          width: 40,
                          height: 50,
                          builder: (context) => _ModernMapMarker(
                            color: AppColors.primary,
                            borderColor: AppColors.primary.withOpacity(0.8),
                            isSelected: true,
                          ),
                        ),
                      ]
                    : [],
                onTap: (point) {
                  // Permettre de définir une nouvelle position en cliquant
                  controller.setOrderAddressEditField('gpsLatitude', point.latitude);
                  controller.setOrderAddressEditField('gpsLongitude', point.longitude);
                  
                  Get.snackbar(
                    'Position mise à jour',
                    'Nouvelles coordonnées: ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.success.withOpacity(0.1),
                    colorText: AppColors.success,
                    duration: Duration(seconds: 2),
                  );
                },
                showZoomControls: true,
                showAttribution: true,
                mapTheme: 'auto',
              ),
            ),
            
            SizedBox(height: AppSpacing.md),
            
            // Instructions
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: AppColors.info.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: 20,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Cliquez sur la carte pour définir une nouvelle position GPS',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
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
        messageText: Row(
          children: [
            Icon(Icons.warning, color: AppColors.warning, size: 24),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Veuillez renseigner une adresse valide.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.warning.withOpacity(0.9),
        borderRadius: 16,
        margin: EdgeInsets.all(24),
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
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
        messageText: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 24),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Adresse enregistrée avec succès.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success.withOpacity(0.9),
        borderRadius: 16,
        margin: EdgeInsets.all(24),
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.rawSnackbar(
        messageText: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 24),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Erreur lors de la sauvegarde : $e',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error.withOpacity(0.9),
        borderRadius: 16,
        margin: EdgeInsets.all(24),
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
    }
  }
}

// Marqueur moderne pour la carte
class _ModernMapMarker extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final bool isSelected;

  const _ModernMapMarker({
    required this.color,
    required this.borderColor,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ombre
          Positioned(
            bottom: 2,
            child: Container(
              width: 20,
              height: 8,
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          // Marqueur principal
          Positioned(
            top: 0,
            child: Container(
              width: 32,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                ),
                border: Border.all(
                  color: borderColor,
                  width: isSelected ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}