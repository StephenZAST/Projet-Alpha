import 'package:admin/widgets/shared/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:admin/models/enums.dart';
import 'package:admin/constants.dart';
import 'package:get/get.dart';
import '../../../../../controllers/orders_controller.dart';
import 'order_extra_fields_components.dart';
import 'dart:ui';

class OrderExtraFieldsStep extends StatefulWidget {
  @override
  State<OrderExtraFieldsStep> createState() => _OrderExtraFieldsStepState();
}

class _OrderExtraFieldsStepState extends State<OrderExtraFieldsStep>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  final OrdersController controller = Get.find<OrdersController>();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeDefaultValues();
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

  void _initializeDefaultValues() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      if (controller.orderDraft.value.collectionDate == null) {
        controller.setOrderDraftField(
            'collectionDate', now.add(Duration(days: 1)));
      }
      if (controller.orderDraft.value.deliveryDate == null) {
        final collect = controller.orderDraft.value.collectionDate ??
            now.add(Duration(days: 1));
        controller.setOrderDraftField(
            'deliveryDate', collect.add(Duration(days: 3)));
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
            child: Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepHeader(isDark),
                    SizedBox(height: AppSpacing.xl),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildDatesSection(isDark),
                            SizedBox(height: AppSpacing.lg),
                            _buildOrderDetailsSection(isDark),
                            SizedBox(height: AppSpacing.lg),
                            _buildRecurrenceSection(isDark),
                            SizedBox(height: AppSpacing.lg),
                            _buildNotesSection(isDark),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
                      colors: [AppColors.warning, AppColors.warning.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.warning.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.settings,
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
                  'Options de Commande',
                  style: AppTextStyles.h2.copyWith(
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Configurez les détails supplémentaires',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatesSection(bool isDark) {
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
                Icons.calendar_today,
                color: AppColors.info,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Dates de Service',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          
          Row(
            children: [
              Expanded(
                child: Obx(() => _ModernDateField(
                  label: 'Date de Collecte',
                  icon: Icons.schedule,
                  value: controller.orderDraft.value.collectionDate,
                  onChanged: (date) => controller.setOrderDraftField('collectionDate', date),
                  isDark: isDark,
                )),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Obx(() => _ModernDateField(
                  label: 'Date de Livraison',
                  icon: Icons.local_shipping,
                  value: controller.orderDraft.value.deliveryDate,
                  onChanged: (date) => controller.setOrderDraftField('deliveryDate', date),
                  isDark: isDark,
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsSection(bool isDark) {
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
                Icons.assignment,
                color: AppColors.primary,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Détails de la Commande',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          
          Row(
            children: [
              Expanded(
                child: Obx(() => _ModernDropdown<OrderStatus>(
                  label: 'Statut de la Commande',
                  icon: Icons.flag,
                  value: controller.orderDraft.value.status != null
                      ? OrderStatus.values.firstWhereOrNull(
                          (s) => s.name == controller.orderDraft.value.status)
                      : OrderStatus.PENDING,
                  items: OrderStatus.values.map((status) {
                    return DropdownMenuItem<OrderStatus>(
                      value: status,
                      child: Row(
                        children: [
                          Icon(status.icon, color: status.color, size: 18),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            status.label,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (OrderStatus? newStatus) {
                    if (newStatus != null) {
                      controller.setOrderDraftField('status', newStatus.name);
                    }
                  },
                  isDark: isDark,
                )),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Obx(() => _ModernDropdown<PaymentMethod>(
                  label: 'Méthode de Paiement',
                  icon: Icons.payment,
                  value: controller.orderDraft.value.paymentMethod != null
                      ? PaymentMethod.values.firstWhereOrNull((m) =>
                          m.name == controller.orderDraft.value.paymentMethod)
                      : PaymentMethod.CASH,
                  items: PaymentMethod.values.map((method) {
                    return DropdownMenuItem<PaymentMethod>(
                      value: method,
                      child: Text(
                        method.label,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (PaymentMethod? newMethod) {
                    if (newMethod != null) {
                      controller.setOrderDraftField('paymentMethod', newMethod.name);
                    }
                  },
                  isDark: isDark,
                )),
              ),
            ],
          ),
          
          SizedBox(height: AppSpacing.lg),
          
          Obx(() => _ModernTextField(
            label: 'Code Affilié',
            icon: Icons.card_giftcard,
            initialValue: controller.orderDraft.value.affiliateCode ?? '',
            onChanged: (value) => controller.setOrderDraftField('affiliateCode', value),
            isDark: isDark,
          )),
        ],
      ),
    );
  }

  Widget _buildRecurrenceSection(bool isDark) {
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
                Icons.repeat,
                color: AppColors.accent,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Récurrence de la Commande',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          
          Obx(() {
            final selected = controller.orderDraft.value.recurrenceType ?? 'NONE';
            final types = [
              {'value': 'NONE', 'label': 'Jamais', 'icon': Icons.block},
              {'value': 'WEEKLY', 'label': 'Hebdomadaire', 'icon': Icons.calendar_view_week},
              {'value': 'BIWEEKLY', 'label': '2 Semaines', 'icon': Icons.date_range},
              {'value': 'MONTHLY', 'label': 'Mensuel', 'icon': Icons.calendar_month},
            ];
            
            return Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: types.map((type) {
                final isSelected = selected == type['value'];
                Color color;
                switch (type['value']) {
                  case 'WEEKLY':
                    color = AppColors.info;
                    break;
                  case 'BIWEEKLY':
                    color = AppColors.violet;
                    break;
                  case 'MONTHLY':
                    color = AppColors.orange;
                    break;
                  default:
                    color = AppColors.gray400;
                }
                
                return _ModernOptionChip(
                  label: type['label']!,
                  icon: type['icon'] as IconData,
                  isSelected: isSelected,
                  color: color,
                  onSelected: () {
                    controller.setOrderDraftField('recurrenceType', type['value']);
                    _calculateNextRecurrenceDate(type['value']!);
                  },
                );
              }).toList(),
            );
          }),
          
          SizedBox(height: AppSpacing.lg),
          
          Obx(() {
            final recurrence = controller.orderDraft.value.recurrenceType;
            final nextDate = controller.orderDraft.value.nextRecurrenceDate;
            if (recurrence == null || recurrence == 'NONE') {
              return SizedBox.shrink();
            }
            
            return _NextRecurrenceCard(
              nextDate: nextDate,
              recurrenceType: recurrence,
              isDark: isDark,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNotesSection(bool isDark) {
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
                Icons.note_alt,
                color: AppColors.success,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Notes et Commentaires',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          
          Obx(() => _ModernTextArea(
            label: 'Note de Commande',
            placeholder: 'Ajoutez des instructions spéciales ou des commentaires...',
            initialValue: controller.orderDraft.value.note ?? '',
            onChanged: (value) => controller.setOrderDraftField('note', value),
            isDark: isDark,
          )),
        ],
      ),
    );
  }

  void _calculateNextRecurrenceDate(String recurrenceType) {
    final collectionDate = controller.orderDraft.value.collectionDate;
    if (recurrenceType != 'NONE' && collectionDate != null) {
      DateTime next;
      switch (recurrenceType) {
        case 'WEEKLY':
          next = collectionDate.add(Duration(days: 7));
          break;
        case 'BIWEEKLY':
          next = collectionDate.add(Duration(days: 14));
          break;
        case 'MONTHLY':
          next = DateTime(
            collectionDate.year,
            collectionDate.month + 1,
            collectionDate.day,
          );
          break;
        default:
          next = collectionDate;
      }
      controller.setOrderDraftField('nextRecurrenceDate', next);
    } else {
      controller.setOrderDraftField('nextRecurrenceDate', null);
    }
  }
}
