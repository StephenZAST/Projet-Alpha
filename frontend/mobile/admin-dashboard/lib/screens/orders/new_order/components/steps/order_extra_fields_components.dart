import 'package:flutter/material.dart';
import 'package:admin/constants.dart';
import 'package:admin/widgets/shared/glass_container.dart';
import 'package:intl/intl.dart';

// Composants modernes pour OrderExtraFieldsStep

class ModernDateField extends StatefulWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final bool isDark;

  const ModernDateField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  ModernDateFieldState createState() => ModernDateFieldState();
}

class ModernDateFieldState extends State<ModernDateField>
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
              variant: GlassContainerVariant.neutral,
              padding: EdgeInsets.all(AppSpacing.md),
              borderRadius: AppRadius.md,
              onTap: () => _selectDate(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.icon,
                        color: widget.isDark
                            ? AppColors.gray400
                            : AppColors.gray600,
                        size: 18,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        widget.label,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: widget.isDark
                              ? AppColors.gray400
                              : AppColors.gray600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.value != null
                              ? DateFormat('dd/MM/yyyy').format(widget.value!)
                              : 'Sélectionner une date',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: widget.value != null
                                ? (widget.isDark
                                    ? AppColors.textLight
                                    : AppColors.textPrimary)
                                : (widget.isDark
                                    ? AppColors.gray500
                                    : AppColors.gray400),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.calendar_today,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                  surface: widget.isDark ? AppColors.gray800 : Colors.white,
                  onSurface: widget.isDark
                      ? AppColors.textLight
                      : AppColors.textPrimary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      widget.onChanged(picked);
    }
  }
}

class ModernDropdown<T> extends StatefulWidget {
  final String label;
  final IconData icon;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final bool isDark;

  const ModernDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.isDark,
  });

  @override
  ModernDropdownState<T> createState() => ModernDropdownState<T>();
}

class ModernDropdownState<T> extends State<ModernDropdown<T>> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: (widget.isDark ? AppColors.gray700 : AppColors.gray100)
            .withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: _isFocused
              ? AppColors.primary.withOpacity(0.5)
              : (widget.isDark ? AppColors.gray600 : AppColors.gray300)
                  .withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              top: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  color: _isFocused
                      ? AppColors.primary
                      : (widget.isDark ? AppColors.gray400 : AppColors.gray600),
                  size: 18,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  widget.label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color:
                        widget.isDark ? AppColors.gray400 : AppColors.gray600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          DropdownButtonFormField<T>(
            value: widget.value,
            style: AppTextStyles.bodyMedium.copyWith(
              color:
                  widget.isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
            items: widget.items,
            onChanged: widget.onChanged,
            onTap: () => setState(() => _isFocused = true),
            dropdownColor: widget.isDark ? AppColors.gray800 : Colors.white,
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: _isFocused
                  ? AppColors.primary
                  : (widget.isDark ? AppColors.gray400 : AppColors.gray600),
            ),
          ),
        ],
      ),
    );
  }
}

class ModernTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final bool isDark;

  const ModernTextField({
    required this.label,
    required this.icon,
    required this.initialValue,
    required this.onChanged,
    required this.isDark,
  });

  @override
  ModernTextFieldState createState() => ModernTextFieldState();
}

class ModernTextFieldState extends State<ModernTextField> {
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: (widget.isDark ? AppColors.gray700 : AppColors.gray100)
            .withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: _isFocused
              ? AppColors.primary.withOpacity(0.5)
              : (widget.isDark ? AppColors.gray600 : AppColors.gray300)
                  .withOpacity(0.5),
        ),
      ),
      child: TextFormField(
        controller: _controller,
        style: AppTextStyles.bodyMedium.copyWith(
          color: widget.isDark ? AppColors.textLight : AppColors.textPrimary,
        ),
        onChanged: widget.onChanged,
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

class ModernTextArea extends StatefulWidget {
  final String label;
  final String placeholder;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final bool isDark;

  const ModernTextArea({
    required this.label,
    required this.placeholder,
    required this.initialValue,
    required this.onChanged,
    required this.isDark,
  });

  @override
  ModernTextAreaState createState() => ModernTextAreaState();
}

class ModernTextAreaState extends State<ModernTextArea> {
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: (widget.isDark ? AppColors.gray700 : AppColors.gray100)
            .withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: _isFocused
              ? AppColors.primary.withOpacity(0.5)
              : (widget.isDark ? AppColors.gray600 : AppColors.gray300)
                  .withOpacity(0.5),
        ),
      ),
      child: TextFormField(
        controller: _controller,
        style: AppTextStyles.bodyMedium.copyWith(
          color: widget.isDark ? AppColors.textLight : AppColors.textPrimary,
        ),
        onChanged: widget.onChanged,
        onTap: () => setState(() => _isFocused = true),
        onEditingComplete: () => setState(() => _isFocused = false),
        minLines: 3,
        maxLines: 6,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.placeholder,
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            color: _isFocused
                ? AppColors.primary
                : (widget.isDark ? AppColors.gray400 : AppColors.gray600),
          ),
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: widget.isDark ? AppColors.gray500 : AppColors.gray400,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(AppSpacing.md),
        ),
      ),
    );
  }
}

class ModernOptionChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onSelected;

  const ModernOptionChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onSelected,
  });

  @override
  ModernOptionChipState createState() => ModernOptionChipState();
}

class ModernOptionChipState extends State<ModernOptionChip>
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onSelected();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                gradient: widget.isSelected
                    ? LinearGradient(
                        colors: [widget.color, widget.color.withOpacity(0.8)],
                      )
                    : null,
                color: widget.isSelected ? null : widget.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: widget.isSelected
                      ? widget.color
                      : widget.color.withOpacity(0.3),
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: widget.color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    color: widget.isSelected ? Colors.white : widget.color,
                    size: 18,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    widget.label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: widget.isSelected ? Colors.white : widget.color,
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

class NextRecurrenceCard extends StatelessWidget {
  final DateTime? nextDate;
  final String recurrenceType;
  final bool isDark;

  const NextRecurrenceCard({
    required this.nextDate,
    required this.recurrenceType,
    required this.isDark,
  });

  String _getRecurrenceLabel(String type) {
    switch (type) {
      case 'WEEKLY':
        return 'Hebdomadaire';
      case 'BIWEEKLY':
        return 'Toutes les 2 semaines';
      case 'MONTHLY':
        return 'Mensuelle';
      default:
        return 'Aucune';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      variant: GlassContainerVariant.info,
      padding: EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.md,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.schedule,
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
                  'Prochaine Récurrence',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  nextDate != null
                      ? DateFormat('dd/MM/yyyy').format(nextDate!)
                      : 'Non définie',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _getRecurrenceLabel(recurrenceType),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.repeat,
            color: Colors.white.withOpacity(0.8),
            size: 24,
          ),
        ],
      ),
    );
  }
}
