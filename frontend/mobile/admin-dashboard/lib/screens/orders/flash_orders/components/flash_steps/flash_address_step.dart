import 'package:admin/controllers/flash_order_stepper_controller.dart';
import 'package:admin/models/address.dart';
import 'package:admin/services/address_service.dart';
import 'package:admin/widgets/glass_button.dart';
import 'package:admin/widgets/shared/glass_container.dart';
import 'package:admin/screens/orders/components/order_address_dialog.dart';
import 'package:admin/screens/orders/components/client_addresses_tab.dart';
import 'package:admin/screens/orders/components/address_selection_map.dart';
import 'package:admin/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';

class FlashAddressStep extends StatefulWidget {
  final FlashOrderStepperController controller;
  const FlashAddressStep({Key? key, required this.controller})
      : super(key: key);

  @override
  State<FlashAddressStep> createState() => _FlashAddressStepState();
}

class _FlashAddressStepState extends State<FlashAddressStep>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _tabController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  List<Address> addresses = [];
  Address? selectedAddress;
  bool isLoading = false;
  int _tabIndex = 0;

  // Helper local pour remplacer firstWhereOrNull si non dispo
  T? firstWhereOrNull<T extends Object?>(List<T> list, bool Function(T) test) {
    for (var element in list) {
      if (test(element)) return element;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _fetchAddresses();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _tabController = AnimationController(
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
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAddresses() async {
    setState(() => isLoading = true);
    try {
      final userId = widget.controller.draft.value.userId;
      if (userId != null) {
        addresses = await AddressService.getAddressesByUser(userId);
        
        // Sélection intelligente de l'adresse
        final selectedId = widget.controller.draft.value.addressId;
        if (selectedId != null && addresses.any((a) => a.id == selectedId)) {
          selectedAddress = addresses.firstWhere((a) => a.id == selectedId);
        } else if (addresses.isNotEmpty) {
          final defaultAddress = firstWhereOrNull(
                  addresses, (a) => (a as Address).isDefault == true) ??
              addresses.first;
          selectedAddress = defaultAddress;
          widget.controller.draft.value.addressId = defaultAddress.id;
          widget.controller.draft.refresh();
        } else {
          selectedAddress = null;
        }
      }
    } catch (e) {
      print('[FlashAddressStep] Erreur lors du chargement des adresses: $e');
    }
    setState(() => isLoading = false);
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
                  if (isLoading)
                    _buildLoadingState(isDark)
                  else
                    Expanded(
                      child: _buildAddressContent(isDark),
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
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.info, AppColors.info.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(12),
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
                'Adresse de Livraison',
                style: AppTextStyles.h3.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Définissez l\'adresse de livraison',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                ),
              ),
            ],
          ),
        ),
      ],
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
                colors: [AppColors.info, AppColors.info.withOpacity(0.6)],
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
            'Chargement des adresses...',
            style: AppTextStyles.bodyLarge.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressContent(bool isDark) {
    // Synchronisation de l'adresse sélectionnée
    final selectedAddressId = widget.controller.draft.value.addressId;
    if (selectedAddressId != null && addresses.any((a) => a.id == selectedAddressId)) {
      selectedAddress = addresses.firstWhere((a) => a.id == selectedAddressId);
    }

    if (addresses.isEmpty) {
      return _buildNoAddressState(isDark);
    }

    return Column(
      children: [
        // Adresse sélectionnée
        if (selectedAddress != null) ...[
          _buildSelectedAddressCard(isDark),
          SizedBox(height: AppSpacing.lg),
        ],
        
        // Onglets de sélection
        _buildAddressSelectionTabs(isDark),
      ],
    );
  }

  Widget _buildNoAddressState(bool isDark) {
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
                    AppColors.info.withOpacity(0.2),
                    AppColors.info.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.location_off,
                color: AppColors.info,
                size: 40,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Aucune adresse trouvée',
              style: AppTextStyles.h3.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Ajoutez une adresse pour ce client',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.gray700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            _ModernAddressButton(
              label: 'Ajouter une adresse',
              icon: Icons.add_location,
              onPressed: () => _createNewAddress(),
              variant: _AddressButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedAddressCard(bool isDark) {
    return GlassContainer(
      variant: GlassContainerVariant.info,
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
                size: 24,
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Adresse Sélectionnée',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (selectedAddress!.isDefault) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: AppRadius.radiusSM,
                  ),
                  child: Text(
                    'PAR DÉFAUT',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _AddressInfoDisplay(
            address: selectedAddress!,
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSelectionTabs(bool isDark) {
    return Expanded(
      child: GlassContainer(
        variant: GlassContainerVariant.neutral,
        padding: EdgeInsets.all(AppSpacing.md),
        borderRadius: AppRadius.lg,
        child: Column(
          children: [
            // Header avec onglets
            Row(
              children: [
                _ModernTabButton(
                  label: 'Liste',
                  icon: Icons.list,
                  isActive: _tabIndex == 0,
                  onPressed: () => _switchTab(0),
                ),
                SizedBox(width: AppSpacing.sm),
                _ModernTabButton(
                  label: 'Carte',
                  icon: Icons.map,
                  isActive: _tabIndex == 1,
                  onPressed: () => _switchTab(1),
                ),
                Spacer(),
                _ModernAddressButton(
                  label: 'Gérer',
                  icon: Icons.edit_location_alt,
                  onPressed: selectedAddress != null 
                      ? () => _editAddress(selectedAddress!)
                      : null,
                  variant: _AddressButtonVariant.secondary,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            
            // Contenu des onglets
            Expanded(
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: _tabIndex == 0
                    ? _buildAddressList(isDark)
                    : _buildAddressMap(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressList(bool isDark) {
    return ClientAddressesTab(
      key: ValueKey('list'),
      userId: widget.controller.draft.value.userId,
      selectedAddress: selectedAddress,
      onAddressSelected: (address) {
        setState(() {
          selectedAddress = address;
          widget.controller.setDraftField('addressId', address.id);
        });
      },
      onAddNewAddress: () => _createNewAddress(),
    );
  }

  Widget _buildAddressMap(bool isDark) {
    return AddressSelectionMap(
      key: ValueKey('map'),
      initialAddress: selectedAddress,
      onAddressSelected: (address) {
        setState(() {
          selectedAddress = address;
          widget.controller.setDraftField('addressId', address.id);
        });
      },
    );
  }

  void _switchTab(int index) {
    setState(() {
      _tabIndex = index;
    });
    _tabController.forward().then((_) => _tabController.reverse());
  }

  void _createNewAddress() async {
    // Logique pour créer une nouvelle adresse
    await _openAddressDialog(context, selectedAddress ?? Address(
      id: '',
      userId: widget.controller.draft.value.userId ?? '',
      name: '',
      street: '',
      city: '',
      postalCode: '',
      isDefault: false,
    ));
  }

  void _editAddress(Address address) async {
    await _openAddressDialog(context, address);
    await _fetchAddresses();
  }

  Future<void> _openAddressDialog(
      BuildContext context, Address initialAddress) async {
    await showDialog(
      context: context,
      builder: (ctx) => OrderAddressDialog(
        initialAddress: initialAddress,
        orderId: '', // Pas d'orderId pour le flow flash
        onAddressSaved: (address) async {
          widget.controller.setDraftField('addressId', address.id);
          await _fetchAddresses(); // Rafraîchir la liste après modification
        },
      ),
    );
  }
}

// Composants modernes pour l'étape d'adresse
enum _AddressButtonVariant { primary, secondary }

class _ModernTabButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onPressed;

  const _ModernTabButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onPressed,
  });

  @override
  _ModernTabButtonState createState() => _ModernTabButtonState();
}

class _ModernTabButtonState extends State<_ModernTabButton>
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
            child: GestureDetector(
              onTap: widget.onPressed,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  gradient: widget.isActive
                      ? LinearGradient(
                          colors: [AppColors.info, AppColors.info.withOpacity(0.8)],
                        )
                      : null,
                  color: !widget.isActive
                      ? (isDark ? AppColors.gray700 : AppColors.gray200).withOpacity(0.5)
                      : null,
                  borderRadius: AppRadius.md,
                  border: Border.all(
                    color: widget.isActive
                        ? AppColors.info.withOpacity(0.3)
                        : (isDark ? AppColors.gray600 : AppColors.gray300).withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      color: widget.isActive
                          ? Colors.white
                          : (isDark ? AppColors.gray400 : AppColors.gray600),
                      size: 18,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      widget.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: widget.isActive
                            ? Colors.white
                            : (isDark ? AppColors.gray400 : AppColors.gray600),
                        fontWeight: widget.isActive ? FontWeight.bold : FontWeight.w500,
                      ),
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

class _ModernAddressButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final _AddressButtonVariant variant;

  const _ModernAddressButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.variant,
  });

  @override
  _ModernAddressButtonState createState() => _ModernAddressButtonState();
}

class _ModernAddressButtonState extends State<_ModernAddressButton>
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
              variant: widget.variant == _AddressButtonVariant.primary
                  ? GlassContainerVariant.info
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
                    color: widget.variant == _AddressButtonVariant.primary
                        ? Colors.white
                        : (isDark ? AppColors.textLight : AppColors.textPrimary),
                    size: 18,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    widget.label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: widget.variant == _AddressButtonVariant.primary
                          ? Colors.white
                          : (isDark ? AppColors.textLight : AppColors.textPrimary),
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

class _AddressInfoDisplay extends StatelessWidget {
  final Address address;
  final Color textColor;

  const _AddressInfoDisplay({
    required this.address,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (address.name.isNotEmpty) ...[
          Row(
            children: [
              Icon(
                Icons.label,
                color: textColor.withOpacity(0.8),
                size: 16,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  address.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
        ],
        
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.home,
              color: textColor.withOpacity(0.8),
              size: 16,
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                address.street,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: AppSpacing.sm),
        
        Row(
          children: [
            Icon(
              Icons.location_city,
              color: textColor.withOpacity(0.8),
              size: 16,
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              '${address.city} ${address.postalCode}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: textColor,
              ),
            ),
          ],
        ),
        
        if (address.gpsLatitude != null && address.gpsLongitude != null) ...[
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.gps_fixed,
                color: textColor.withOpacity(0.8),
                size: 16,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'GPS: ${address.gpsLatitude?.toStringAsFixed(6)}, ${address.gpsLongitude?.toStringAsFixed(6)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: textColor.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
