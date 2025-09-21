import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/order_map_controller.dart';
import '../../../widgets/shared/glass_container.dart';
import '../../../widgets/shared/app_button.dart';
import '../../../models/enums.dart' hide AppButtonVariant;

class OrderMapFilters extends StatefulWidget {
  @override
  _OrderMapFiltersState createState() => _OrderMapFiltersState();
}

class _OrderMapFiltersState extends State<OrderMapFilters>
    with SingleTickerProviderStateMixin {
  late OrderMapController controller;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  final List<String> statusOptions = [
    'all',
    'PENDING',
    'COLLECTING',
    'COLLECTED',
    'PROCESSING',
    'READY',
    'DELIVERING',
    'DELIVERED',
    'CANCELLED',
  ];

  final List<String> paymentMethodOptions = [
    'all',
    'CASH',
    'ORANGE_MONEY',
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.find<OrderMapController>();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
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

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value * 100, 0),
          child: GlassContainer(
            variant: GlassContainerVariant.neutral,
            padding: EdgeInsets.all(AppSpacing.lg),
            borderRadius: AppRadius.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        Icons.filter_alt,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Filtres',
                        style: AppTextStyles.h3.copyWith(
                          color: isDark ? AppColors.textLight : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.clear_all,
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                        size: 20,
                      ),
                      onPressed: controller.clearFilters,
                      tooltip: 'Réinitialiser les filtres',
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),

                // Filtres
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Filtre par statut
                        _buildStatusFilter(isDark),
                        SizedBox(height: AppSpacing.lg),

                        // Filtre par type de commande
                        _buildOrderTypeFilter(isDark),
                        SizedBox(height: AppSpacing.lg),

                        // Filtre par méthode de paiement
                        _buildPaymentMethodFilter(isDark),
                        SizedBox(height: AppSpacing.lg),

                        // Filtres de date
                        _buildDateFilters(isDark),
                        SizedBox(height: AppSpacing.lg),

                        // Filtres géographiques
                        _buildLocationFilters(isDark),
                        SizedBox(height: AppSpacing.lg),

                        // Boutons d'action
                        _buildActionButtons(isDark),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusFilter(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statut',
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Obx(() => Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark 
                ? AppColors.gray800.withOpacity(0.5)
                : AppColors.gray100.withOpacity(0.8),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isDark 
                  ? AppColors.gray700.withOpacity(0.3)
                  : AppColors.gray300.withOpacity(0.5),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.filterStatus.value.isEmpty 
                  ? 'all' 
                  : controller.filterStatus.value,
              isExpanded: true,
              dropdownColor: isDark ? AppColors.gray800 : AppColors.white,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
              items: statusOptions.map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(_getStatusLabel(status)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.filterStatus.value = value == 'all' ? '' : value;
                  controller.applyFilters();
                }
              },
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildOrderTypeFilter(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type de commande',
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Obx(() => Column(
          children: [
            _buildFilterChip(
              'Toutes',
              controller.filterIsFlashOrder.value == null,
              () {
                controller.filterIsFlashOrder.value = null;
                controller.applyFilters();
              },
              isDark,
            ),
            SizedBox(height: AppSpacing.xs),
            _buildFilterChip(
              'Flash uniquement',
              controller.filterIsFlashOrder.value == true,
              () {
                controller.filterIsFlashOrder.value = true;
                controller.applyFilters();
              },
              isDark,
            ),
            SizedBox(height: AppSpacing.xs),
            _buildFilterChip(
              'Normales uniquement',
              controller.filterIsFlashOrder.value == false,
              () {
                controller.filterIsFlashOrder.value = false;
                controller.applyFilters();
              },
              isDark,
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildPaymentMethodFilter(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Méthode de paiement',
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Obx(() => Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark 
                ? AppColors.gray800.withOpacity(0.5)
                : AppColors.gray100.withOpacity(0.8),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isDark 
                  ? AppColors.gray700.withOpacity(0.3)
                  : AppColors.gray300.withOpacity(0.5),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.filterPaymentMethod.value.isEmpty 
                  ? 'all' 
                  : controller.filterPaymentMethod.value,
              isExpanded: true,
              dropdownColor: isDark ? AppColors.gray800 : AppColors.white,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
              items: paymentMethodOptions.map((method) {
                return DropdownMenuItem<String>(
                  value: method,
                  child: Text(_getPaymentMethodLabel(method)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.filterPaymentMethod.value = value == 'all' ? '' : value;
                  controller.applyFilters();
                }
              },
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildDateFilters(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtres de date',
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.sm),

        // Date de création
        _buildDateRangeFilter(
          'Création',
          controller.startDateController,
          controller.endDateController,
          controller.pickStartDate,
          controller.pickEndDate,
          isDark,
        ),
        SizedBox(height: AppSpacing.md),

        // Date de collecte
        _buildDateRangeFilter(
          'Collecte',
          controller.collectionStartDateController,
          controller.collectionEndDateController,
          controller.pickCollectionStartDate,
          controller.pickCollectionEndDate,
          isDark,
        ),
        SizedBox(height: AppSpacing.md),

        // Date de livraison
        _buildDateRangeFilter(
          'Livraison',
          controller.deliveryStartDateController,
          controller.deliveryEndDateController,
          controller.pickDeliveryStartDate,
          controller.pickDeliveryEndDate,
          isDark,
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter(
    String label,
    TextEditingController startController,
    TextEditingController endController,
    Function(BuildContext) pickStart,
    Function(BuildContext) pickEnd,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark ? AppColors.gray400 : AppColors.gray600,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => pickStart(context),
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? AppColors.gray800.withOpacity(0.5)
                        : AppColors.gray100.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: isDark 
                          ? AppColors.gray700.withOpacity(0.3)
                          : AppColors.gray300.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          startController.text.isEmpty ? 'Début' : startController.text,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: startController.text.isEmpty
                                ? (isDark ? AppColors.gray500 : AppColors.gray500)
                                : (isDark ? AppColors.textLight : AppColors.textPrimary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: GestureDetector(
                onTap: () => pickEnd(context),
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? AppColors.gray800.withOpacity(0.5)
                        : AppColors.gray100.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: isDark 
                          ? AppColors.gray700.withOpacity(0.3)
                          : AppColors.gray300.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          endController.text.isEmpty ? 'Fin' : endController.text,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: endController.text.isEmpty
                                ? (isDark ? AppColors.gray500 : AppColors.gray500)
                                : (isDark ? AppColors.textLight : AppColors.textPrimary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationFilters(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Localisation',
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.sm),

        // Filtre par ville
        _buildTextFilter(
          'Ville',
          controller.filterCity,
          Icons.location_city,
          'Filtrer par ville...',
          isDark,
        ),
        SizedBox(height: AppSpacing.md),

        // Filtre par code postal
        _buildTextFilter(
          'Code postal',
          controller.filterPostalCode,
          Icons.markunread_mailbox,
          'Filtrer par code postal...',
          isDark,
        ),
      ],
    );
  }

  Widget _buildTextFilter(
    String label,
    RxString filterValue,
    IconData icon,
    String hint,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark ? AppColors.gray400 : AppColors.gray600,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Container(
          decoration: BoxDecoration(
            color: isDark 
                ? AppColors.gray800.withOpacity(0.5)
                : AppColors.gray100.withOpacity(0.8),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: isDark 
                  ? AppColors.gray700.withOpacity(0.3)
                  : AppColors.gray300.withOpacity(0.5),
            ),
          ),
          child: TextField(
            onChanged: (value) {
              filterValue.value = value;
              // Appliquer les filtres avec un délai pour éviter trop d'appels
              Future.delayed(Duration(milliseconds: 500), () {
                if (filterValue.value == value) {
                  controller.applyFilters();
                }
              });
            },
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray500 : AppColors.gray500,
              ),
              prefixIcon: Icon(
                icon,
                color: isDark ? AppColors.gray400 : AppColors.gray600,
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

  Widget _buildActionButtons(bool isDark) {
    return Column(
      children: [
        AppButton(
          label: 'Appliquer les filtres',
          icon: Icons.check,
          onPressed: controller.applyFilters,
          variant: AppButtonVariant.primary,
          fullWidth: true,
        ),
        SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Réinitialiser',
          icon: Icons.clear_all,
          onPressed: controller.clearFilters,
          variant: AppButtonVariant.secondary,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : (isDark 
                  ? AppColors.gray800.withOpacity(0.5)
                  : AppColors.gray100.withOpacity(0.8)),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withOpacity(0.3)
                : (isDark 
                    ? AppColors.gray700.withOpacity(0.3)
                    : AppColors.gray300.withOpacity(0.5)),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.textLight : AppColors.textPrimary),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'all':
        return 'Tous les statuts';
      case 'PENDING':
        return 'En attente';
      case 'COLLECTING':
        return 'Collecte';
      case 'COLLECTED':
        return 'Collecté';
      case 'PROCESSING':
        return 'En traitement';
      case 'READY':
        return 'Prêt';
      case 'DELIVERING':
        return 'En livraison';
      case 'DELIVERED':
        return 'Livré';
      case 'CANCELLED':
        return 'Annulé';
      default:
        return status;
    }
  }

  String _getPaymentMethodLabel(String method) {
    switch (method) {
      case 'all':
        return 'Toutes les méthodes';
      case 'CASH':
        return 'Espèces';
      case 'ORANGE_MONEY':
        return 'Orange Money';
      default:
        return method;
    }
  }
}