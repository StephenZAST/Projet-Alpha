import 'package:admin/controllers/flash_order_stepper_controller.dart';
import 'package:admin/constants.dart';
import 'package:admin/widgets/shared/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';

class FlashExtraFieldsStep extends StatefulWidget {
  final FlashOrderStepperController controller;
  const FlashExtraFieldsStep({Key? key, required this.controller})
      : super(key: key);

  @override
  _FlashExtraFieldsStepState createState() => _FlashExtraFieldsStepState();
}

class _FlashExtraFieldsStepState extends State<FlashExtraFieldsStep>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeDefaults();
    _noteController = TextEditingController(
      text: widget.controller.draft.value.note ?? '',
    );
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

  void _initializeDefaults() {
    final draft = widget.controller.draft.value;
    final now = DateTime.now();
    
    if (draft.collectionDate == null) {
      widget.controller.setDraftField('collectionDate', now.add(Duration(days: 1)));
    }
    if (draft.deliveryDate == null) {
      final collect = draft.collectionDate ?? now.add(Duration(days: 1));
      widget.controller.setDraftField('deliveryDate', collect.add(Duration(days: 3)));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _noteController.dispose();
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
            child: Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepHeader(isDark),
                  SizedBox(height: AppSpacing.xl),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Obx(() => _buildExtraFieldsContent(isDark)),
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
        Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.warning, AppColors.warning.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.settings,
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
                'Informations Complémentaires',
                style: AppTextStyles.h3.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Dates, notes et options',
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

  Widget _buildExtraFieldsContent(bool isDark) {
    final draft = widget.controller.draft.value;

    return Column(
      children: [
        // Section Dates
        _buildDatesSection(isDark, draft),
        SizedBox(height: AppSpacing.lg),
        
        // Section Options
        _buildOptionsSection(isDark, draft),
        SizedBox(height: AppSpacing.lg),
        
        // Section Note
        _buildNoteSection(isDark, draft),
      ],
    );
  }

  Widget _buildDatesSection(bool isDark, dynamic draft) {
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
                Icons.schedule,
                color: AppColors.warning,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Planning de Service',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          
          // Date de collecte
          _ModernDateField(
            label: 'Date de Collecte',
            icon: Icons.calendar_today,
            date: draft.collectionDate,
            onDateSelected: (date) {
              widget.controller.setDraftField('collectionDate', date);
              // Auto-ajuster la date de livraison si nécessaire
              if (draft.deliveryDate != null && draft.deliveryDate!.isBefore(date)) {
                widget.controller.setDraftField('deliveryDate', date.add(Duration(days: 3)));
              }
            },
            isDark: isDark,
            color: AppColors.info,
          ),
          
          SizedBox(height: AppSpacing.md),
          
          // Date de livraison
          _ModernDateField(
            label: 'Date de Livraison',
            icon: Icons.local_shipping,
            date: draft.deliveryDate,
            onDateSelected: (date) {
              widget.controller.setDraftField('deliveryDate', date);
            },
            isDark: isDark,
            color: AppColors.success,
            minDate: draft.collectionDate,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsSection(bool isDark, dynamic draft) {
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
                Icons.tune,
                color: AppColors.accent,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Options de Commande',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          
          // Option urgente
          _ModernOptionTile(
            title: 'Commande Urgente',
            subtitle: 'Traitement prioritaire (+20%)',
            icon: Icons.priority_high,
            value: draft.isUrgent ?? false,
            onChanged: (value) {
              widget.controller.setDraftField('isUrgent', value);
            },
            color: AppColors.error,
            isDark: isDark,
          ),
          
          SizedBox(height: AppSpacing.md),
          
          // Option livraison express
          _ModernOptionTile(
            title: 'Livraison Express',
            subtitle: 'Livraison le jour même (+15%)',
            icon: Icons.flash_on,
            value: draft.isExpress ?? false,
            onChanged: (value) {
              widget.controller.setDraftField('isExpress', value);
            },
            color: AppColors.warning,
            isDark: isDark,
          ),
          
          SizedBox(height: AppSpacing.md),
          
          // Option éco-responsable
          _ModernOptionTile(
            title: 'Service Éco-Responsable',
            subtitle: 'Produits écologiques (-5%)',
            icon: Icons.eco,
            value: draft.isEcoFriendly ?? false,
            onChanged: (value) {
              widget.controller.setDraftField('isEcoFriendly', value);
            },
            color: AppColors.success,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection(bool isDark, dynamic draft) {
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
                Icons.note_add,
                color: AppColors.info,
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
            ],
          ),
          SizedBox(height: AppSpacing.md),
          
          _ModernTextArea(
            controller: _noteController,
            hint: 'Ajoutez des instructions spéciales, préférences ou remarques...',
            onChanged: (value) {
              widget.controller.setDraftField('note', value);
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

// Composants modernes pour l'��tape des champs extra
class _ModernDateField extends StatefulWidget {
  final String label;
  final IconData icon;
  final DateTime? date;
  final ValueChanged<DateTime> onDateSelected;
  final bool isDark;
  final Color color;
  final DateTime? minDate;

  const _ModernDateField({
    required this.label,
    required this.icon,
    required this.date,
    required this.onDateSelected,
    required this.isDark,
    required this.color,
    this.minDate,
  });

  @override
  _ModernDateFieldState createState() => _ModernDateFieldState();
}

class _ModernDateFieldState extends State<_ModernDateField>
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
            child: GestureDetector(
              onTap: () => _selectDate(),
              child: Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.color.withOpacity(0.1),
                      widget.color.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: AppRadius.md,
                  border: Border.all(
                    color: widget.color.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.color,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.label,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: widget.isDark ? AppColors.textLight : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            widget.date != null
                                ? _formatDate(widget.date!)
                                : 'Sélectionner une date',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: widget.date != null
                                  ? widget.color
                                  : (widget.isDark ? AppColors.gray400 : AppColors.gray600),
                              fontWeight: widget.date != null ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: widget.color,
                      size: 16,
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

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.date ?? DateTime.now(),
      firstDate: widget.minDate ?? DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: widget.color,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      widget.onDateSelected(picked);
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _ModernOptionTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color color;
  final bool isDark;

  const _ModernOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
    required this.color,
    required this.isDark,
  });

  @override
  _ModernOptionTileState createState() => _ModernOptionTileState();
}

class _ModernOptionTileState extends State<_ModernOptionTile>
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                gradient: widget.value
                    ? LinearGradient(
                        colors: [
                          widget.color.withOpacity(0.2),
                          widget.color.withOpacity(0.1),
                        ],
                      )
                    : null,
                color: !widget.value
                    ? (widget.isDark ? AppColors.gray700 : AppColors.gray100).withOpacity(0.5)
                    : null,
                borderRadius: AppRadius.md,
                border: Border.all(
                  color: widget.value
                      ? widget.color.withOpacity(0.5)
                      : (widget.isDark ? AppColors.gray600 : AppColors.gray300).withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      gradient: widget.value
                          ? LinearGradient(
                              colors: [widget.color, widget.color.withOpacity(0.8)],
                            )
                          : null,
                      color: !widget.value
                          ? (widget.isDark ? AppColors.gray600 : AppColors.gray400)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: widget.isDark ? AppColors.textLight : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          widget.subtitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: widget.isDark ? AppColors.gray400 : AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _ModernSwitch(
                    value: widget.value,
                    onChanged: widget.onChanged,
                    activeColor: widget.color,
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

class _ModernSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const _ModernSwitch({
    required this.value,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  _ModernSwitchState createState() => _ModernSwitchState();
}

class _ModernSwitchState extends State<_ModernSwitch>
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Switch(
              value: widget.value,
              onChanged: widget.onChanged,
              activeColor: Colors.white,
              activeTrackColor: widget.activeColor.withOpacity(0.8),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
            ),
          );
        },
      ),
    );
  }
}

class _ModernTextArea extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final bool isDark;

  const _ModernTextArea({
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: (isDark ? AppColors.gray700 : AppColors.gray100).withOpacity(0.5),
        borderRadius: AppRadius.md,
        border: Border.all(
          color: (isDark ? AppColors.gray600 : AppColors.gray300).withOpacity(0.5),
        ),
      ),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        minLines: 3,
        maxLines: 6,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isDark ? AppColors.textLight : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.gray400 : AppColors.gray600,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(AppSpacing.md),
        ),
      ),
    );
  }
}
