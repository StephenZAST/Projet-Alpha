import 'package:admin/controllers/flash_order_stepper_controller.dart';
import 'package:admin/models/flash_order_draft.dart';
import 'package:admin/models/user.dart';
import 'package:admin/models/address.dart';
import 'package:admin/models/service.dart';
import 'package:admin/models/service_type.dart';
import 'package:admin/services/article_service_couple_service.dart';
import 'package:admin/services/user_service.dart';
import 'package:admin/services/address_service.dart';
import 'package:admin/services/service_service.dart';
import 'package:admin/services/service_type_service.dart';
import 'package:admin/models/enums.dart';
import 'package:admin/constants.dart';
import 'package:admin/widgets/shared/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';

class FlashSummaryStep extends StatefulWidget {
  final FlashOrderStepperController controller;
  const FlashSummaryStep({Key? key, required this.controller})
      : super(key: key);

  @override
  State<FlashSummaryStep> createState() => _FlashSummaryStepState();
}

class _FlashSummaryStepState extends State<FlashSummaryStep>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  User? user;
  Address? address;
  List<Address> addresses = [];
  Service? service;
  ServiceType? serviceType;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _fetchAllInfos();
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

  @override
  void didUpdateWidget(covariant FlashSummaryStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fetchAllInfos();
  }

  List<Map<String, dynamic>> couples = [];
  
  Future<void> _fetchAllInfos() async {
    final draft = widget.controller.draft.value;
    setState(() => isLoading = true);
    
    try {
      if (draft.userId != null) {
        user = await UserService.getUserById(draft.userId!);
      }
      
      if (draft.userId != null) {
        addresses = await AddressService.getAddressesByUser(draft.userId!);
      }
      
      if (draft.addressId != null && addresses.isNotEmpty) {
        address = addresses.firstWhere(
          (a) => a.id == draft.addressId,
          orElse: () => addresses.first,
        );
      } else {
        address = null;
      }
      
      if (draft.serviceId != null) {
        final services = await ServiceService.getAllServices();
        service = services.isNotEmpty
            ? services.firstWhere((s) => s.id == draft.serviceId,
                orElse: () => services.first)
            : null;
      }
      
      if (draft.serviceTypeId != null) {
        final types = await ServiceTypeService.getAllServiceTypes();
        serviceType = types.isNotEmpty
            ? types.firstWhere((t) => t.id == draft.serviceTypeId,
                orElse: () => types.first)
            : null;
      }
      
      if (draft.serviceTypeId != null && draft.serviceId != null) {
        couples = await ArticleServiceCoupleService.getCouplesForServiceType(
          serviceTypeId: draft.serviceTypeId!,
          serviceId: draft.serviceId!,
        );
        widget.controller.syncSelectedItemsFrom(couples: couples);
        setState(() {});
      }
    } catch (e) {
      print('[FlashSummaryStep] Erreur lors du chargement: $e');
    }
    
    setState(() => isLoading = false);
  }

  int _calculateTotal() {
    final draft = widget.controller.draft.value;
    int total = 0;
    for (var item in draft.items) {
      total += (item.unitPrice * item.quantity).toInt();
    }
    return total;
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
                      child: SingleChildScrollView(
                        child: Obx(() => _buildSummaryContent(isDark)),
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
    return Row(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.4),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.transform,
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
                'Validation Conversion',
                style: AppTextStyles.h3.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Vérifiez et convertissez',
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
                colors: [AppColors.success, AppColors.success.withOpacity(0.6)],
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
            'Préparation du récapitulatif...',
            style: AppTextStyles.bodyLarge.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryContent(bool isDark) {
    final draft = widget.controller.draft.value;

    return Column(
      children: [
        // Section Client
        _buildClientSection(isDark),
        SizedBox(height: AppSpacing.lg),
        
        // Section Service & Articles
        _buildServiceSection(isDark, draft),
        SizedBox(height: AppSpacing.lg),
        
        // Section Adresse
        _buildAddressSection(isDark),
        SizedBox(height: AppSpacing.lg),
        
        // Section Options & Dates
        _buildOptionsSection(isDark, draft),
        SizedBox(height: AppSpacing.lg),
        
        // Section Total
        _buildTotalSection(isDark),
      ],
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1),
    );
  }

  Widget _buildClientSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Client associé', style: TextStyle(fontWeight: FontWeight.w600)),
        if (user != null) ...[
          Text('Nom : ${user!.firstName} ${user!.lastName}'),
          Text('Email : ${user!.email}'),
          if (user!.phone != null) Text('Téléphone : ${user!.phone}'),
        ] else ...[
          Text('ID : -'),
        ],
      ],
    );
  }

  Widget _buildAddressSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Adresse', style: TextStyle(fontWeight: FontWeight.w600)),
        if (address != null) ...[
          Text('Nom : ${address!.name ?? '-'}'),
          Text('Ville : ${address!.city}'),
          Text('Rue : ${address!.street}'),
        ] else ...[
          Text('ID : -'),
        ],
      ],
    );
  }

  Widget _buildServiceSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Service', style: TextStyle(fontWeight: FontWeight.w600)),
        if (serviceType != null) Text('Type : ${serviceType!.name}'),
        if (service != null) Text('Service : ${service!.name}'),
      ],
    );
  }

  Widget _buildArticlesSummary(FlashOrderDraft draft) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Articles/Services',
            style: TextStyle(fontWeight: FontWeight.w600)),
        if (draft.items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Aucun article/service sélectionné',
                style: TextStyle(color: Colors.grey)),
          )
        else
          ...draft.items.map((item) {
            final name = item.articleName ?? item.articleId;
            final price = item.unitPrice;
            final premiumLabel = item.isPremium ? ' (Premium)' : '';
            return Text(
                '$name x${item.quantity}$premiumLabel - ${(price * item.quantity).toStringAsFixed(0)} FCFA');
          }),
      ],
    );
  }

  Widget _buildExtraFieldsSummary(FlashOrderDraft draft) {
    String? statusLabel;
    Color? statusColor;
    IconData? statusIcon;
    if (draft.status != null) {
      final statusEnum =
          OrderStatus.values.firstWhereOrNull((s) => s.name == draft.status);
      statusLabel = statusEnum?.label;
      statusColor = statusEnum?.color;
      statusIcon = statusEnum?.icon;
    }
    String? paymentLabel;
    if (draft.paymentMethod != null) {
      final paymentEnum = PaymentMethod.values
          .firstWhereOrNull((p) => p.name == draft.paymentMethod);
      paymentLabel = paymentEnum?.label;
    }
    String? recurrenceLabel;
    if (draft.recurrenceType != null) {
      switch (draft.recurrenceType) {
        case 'WEEKLY':
          recurrenceLabel = 'Hebdomadaire';
          break;
        case 'BIWEEKLY':
          recurrenceLabel = 'Toutes les 2 semaines';
          break;
        case 'MONTHLY':
          recurrenceLabel = 'Mensuelle';
          break;
        default:
          recurrenceLabel = 'Aucune';
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Informations complémentaires',
            style: TextStyle(fontWeight: FontWeight.w600)),
        _buildInfoRow(
            'Date de collecte',
            draft.collectionDate != null
                ? draft.collectionDate!.toLocal().toString().split(' ')[0]
                : ''),
        _buildInfoRow(
            'Date de livraison',
            draft.deliveryDate != null
                ? draft.deliveryDate!.toLocal().toString().split(' ')[0]
                : ''),
        if (draft.note != null && draft.note!.trim().isNotEmpty)
          _buildInfoRow('Note de commande', draft.note!),
        if (statusLabel != null)
          Row(
            children: [
              if (statusIcon != null)
                Icon(statusIcon, color: statusColor, size: 18),
              SizedBox(width: 6),
              _buildInfoRow('Statut', statusLabel),
            ],
          ),
        if (paymentLabel != null)
          _buildInfoRow('Méthode de paiement', paymentLabel),
        if (draft.affiliateCode != null && draft.affiliateCode!.isNotEmpty)
          _buildInfoRow('Code affilié', draft.affiliateCode!),
        if (recurrenceLabel != null && recurrenceLabel != 'Aucune')
          _buildInfoRow('Type de récurrence', recurrenceLabel),
        if (draft.nextRecurrenceDate != null &&
            draft.recurrenceType != null &&
            draft.recurrenceType != 'NONE')
          _buildInfoRow('Prochaine récurrence',
              draft.nextRecurrenceDate!.toLocal().toString().split(' ')[0]),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientSection(bool isDark) {
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
          
          if (user != null) ...[
            _SummaryInfoRow(
              icon: Icons.badge,
              label: 'Nom complet',
              value: '${user!.firstName} ${user!.lastName}',
              isDark: isDark,
            ),
            _SummaryInfoRow(
              icon: Icons.email,
              label: 'Email',
              value: user!.email,
              isDark: isDark,
            ),
            if (user!.phone != null)
              _SummaryInfoRow(
                icon: Icons.phone,
                label: 'Téléphone',
                value: user!.phone!,
                isDark: isDark,
              ),
          ] else ...[
            _EmptyStateInfo(
              message: 'Aucun client sélectionné',
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServiceSection(bool isDark, FlashOrderDraft draft) {
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
                Icons.design_services,
                color: AppColors.accent,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Service & Articles',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          
          // Informations service
          if (serviceType != null)
            _SummaryInfoRow(
              icon: Icons.category,
              label: 'Type de service',
              value: serviceType!.name,
              isDark: isDark,
            ),
          if (service != null)
            _SummaryInfoRow(
              icon: Icons.room_service,
              label: 'Service',
              value: service!.name,
              isDark: isDark,
            ),
          
          SizedBox(height: AppSpacing.md),
          
          // Articles sélectionnés
          if (draft.items.isNotEmpty) ...[
            Text(
              'Articles sélectionnés',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            ...draft.items.map((item) => _ArticleItem(
              item: item,
              isDark: isDark,
            )),
          ] else ...[
            _EmptyStateInfo(
              message: 'Aucun article sélectionné',
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddressSection(bool isDark) {
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
                Icons.location_on,
                color: AppColors.info,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Adresse de Livraison',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          
          if (address != null) ...[
            if (address!.name.isNotEmpty)
              _SummaryInfoRow(
                icon: Icons.label,
                label: 'Nom',
                value: address!.name,
                isDark: isDark,
              ),
            _SummaryInfoRow(
              icon: Icons.home,
              label: 'Adresse',
              value: address!.street,
              isDark: isDark,
            ),
            _SummaryInfoRow(
              icon: Icons.location_city,
              label: 'Ville',
              value: '${address!.city} ${address!.postalCode}',
              isDark: isDark,
            ),
          ] else ...[
            _EmptyStateInfo(
              message: 'Aucune adresse sélectionnée',
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionsSection(bool isDark, FlashOrderDraft draft) {
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
                Icons.settings,
                color: AppColors.warning,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Options & Planning',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          
          // Dates
          if (draft.collectionDate != null)
            _SummaryInfoRow(
              icon: Icons.calendar_today,
              label: 'Date de collecte',
              value: _formatDate(draft.collectionDate!),
              isDark: isDark,
            ),
          if (draft.deliveryDate != null)
            _SummaryInfoRow(
              icon: Icons.local_shipping,
              label: 'Date de livraison',
              value: _formatDate(draft.deliveryDate!),
              isDark: isDark,
            ),
          
          // Options spéciales
          if (draft.isUrgent == true)
            _OptionBadge(
              label: 'Commande Urgente',
              icon: Icons.priority_high,
              color: AppColors.error,
            ),
          if (draft.isExpress == true)
            _OptionBadge(
              label: 'Livraison Express',
              icon: Icons.flash_on,
              color: AppColors.warning,
            ),
          if (draft.isEcoFriendly == true)
            _OptionBadge(
              label: 'Éco-Responsable',
              icon: Icons.eco,
              color: AppColors.success,
            ),
          
          // Note
          if (draft.note != null && draft.note!.trim().isNotEmpty) ...[
            SizedBox(height: AppSpacing.md),
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.gray700 : AppColors.gray100).withOpacity(0.5),
                borderRadius: AppRadius.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.note,
                        color: AppColors.info,
                        size: 16,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'Note de commande',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.gray300 : AppColors.gray700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    draft.note!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTotalSection(bool isDark) {
    final total = _calculateTotal();
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseAnimation.value - 1.0) * 0.02,
          child: GlassContainer(
            variant: GlassContainerVariant.success,
            padding: EdgeInsets.all(AppSpacing.xl),
            borderRadius: AppRadius.lg,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.calculate,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Estimé',
                            style: AppTextStyles.h3.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Prix final de la conversion',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${total.toStringAsFixed(0)} FCFA',
                      style: AppTextStyles.h2.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                if (total > 0) ...[
                  SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: AppRadius.md,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.white.withOpacity(0.8),
                          size: 16,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Ce montant est une estimation basée sur les articles sélectionnés',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// Composants modernes pour l'étape de résumé
class _SummaryInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _SummaryInfoRow({
    required this.icon,
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
          Icon(
            icon,
            color: isDark ? AppColors.gray400 : AppColors.gray600,
            size: 16,
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
                SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleItem extends StatelessWidget {
  final dynamic item;
  final bool isDark;

  const _ArticleItem({
    required this.item,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final name = item.articleName ?? item.articleId;
    final price = item.unitPrice;
    final quantity = item.quantity;
    final total = price * quantity;
    final isPremium = item.isPremium ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withOpacity(0.1),
            AppColors.accent.withOpacity(0.05),
          ],
        ),
        borderRadius: AppRadius.md,
        border: Border.all(
          color: AppColors.accent.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.checkroom,
              color: AppColors.accent,
              size: 16,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark ? AppColors.textLight : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isPremium) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.2),
                          borderRadius: AppRadius.radiusXS,
                        ),
                        child: Text(
                          'PREMIUM',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Text(
                      'Qté: $quantity',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Text(
                      '${price.toStringAsFixed(0)} FCFA/u',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${total.toStringAsFixed(0)} FCFA',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _OptionBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: AppSpacing.sm),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: AppRadius.md,
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateInfo extends StatelessWidget {
  final String message;
  final bool isDark;

  const _EmptyStateInfo({
    required this.message,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.gray700 : AppColors.gray100).withOpacity(0.5),
        borderRadius: AppRadius.md,
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: isDark ? AppColors.gray400 : AppColors.gray600,
            size: 20,
          ),
          SizedBox(width: AppSpacing.md),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.gray600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
