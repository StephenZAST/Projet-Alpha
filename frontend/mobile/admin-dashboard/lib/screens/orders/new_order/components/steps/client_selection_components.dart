import 'package:flutter/material.dart';
import 'package:admin/constants.dart';
import 'package:admin/widgets/shared/glass_container.dart';
import '../../../../../models/user.dart';

// Composants modernes pour ClientSelectionStep
enum ClientActionVariant { primary, secondary, info, warning, error }

class ModernSearchField extends StatefulWidget {
  final TextEditingController controller;
  final bool isDark;

  const ModernSearchField({
    required this.controller,
    required this.isDark,
  });

  @override
  ModernSearchFieldState createState() => ModernSearchFieldState();
}

class ModernSearchFieldState extends State<ModernSearchField> {
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
      child: TextFormField(
        controller: widget.controller,
        style: AppTextStyles.bodyMedium.copyWith(
          color: widget.isDark ? AppColors.textLight : AppColors.textPrimary,
        ),
        // onChanged removed (unused parameter)
        onTap: () => setState(() => _isFocused = true),
        onEditingComplete: () => setState(() => _isFocused = false),
        decoration: InputDecoration(
          hintText: 'Rechercher un client...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: widget.isDark ? AppColors.gray400 : AppColors.gray600,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: _isFocused
                ? AppColors.primary
                : (widget.isDark ? AppColors.gray400 : AppColors.gray600),
            size: 20,
          ),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color:
                        widget.isDark ? AppColors.gray400 : AppColors.gray600,
                    size: 20,
                  ),
                  onPressed: () {
                    widget.controller.clear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(AppSpacing.md),
        ),
      ),
    );
  }
}

class ModernFilterDropdown extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final bool isDark;

  const ModernFilterDropdown({
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  ModernFilterDropdownState createState() => ModernFilterDropdownState();
}

class ModernFilterDropdownState extends State<ModernFilterDropdown> {
  bool _isFocused = false;

  final Map<String, Map<String, dynamic>> _filterOptions = {
    'all': {'label': 'Tous les clients', 'icon': Icons.people},
    'name': {'label': 'Par nom', 'icon': Icons.person},
    'email': {'label': 'Par email', 'icon': Icons.email},
    'phone': {'label': 'Par téléphone', 'icon': Icons.phone},
  };

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
      child: DropdownButtonFormField<String>(
        value: widget.value,
        style: AppTextStyles.bodyMedium.copyWith(
          color: widget.isDark ? AppColors.textLight : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            _filterOptions[widget.value]?['icon'] ?? Icons.filter_list,
            color: _isFocused
                ? AppColors.primary
                : (widget.isDark ? AppColors.gray400 : AppColors.gray600),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(AppSpacing.md),
        ),
        items: _filterOptions.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Row(
              children: [
                Icon(
                  entry.value['icon'],
                  size: 18,
                  color: widget.isDark ? AppColors.gray400 : AppColors.gray600,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(entry.value['label']),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            widget.onChanged(value);
          }
        },
        onTap: () => setState(() => _isFocused = true),
        dropdownColor: widget.isDark ? AppColors.gray800 : Colors.white,
      ),
    );
  }
}

class ModernActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final ClientActionVariant variant;

  const ModernActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.variant,
  });

  @override
  ModernActionButtonState createState() => ModernActionButtonState();
}

class ModernActionButtonState extends State<ModernActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  // _isHovered removed (unused field)

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
      case ClientActionVariant.primary:
        return AppColors.primary;
      case ClientActionVariant.secondary:
        return AppColors.gray600;
      case ClientActionVariant.info:
        return AppColors.info;
      case ClientActionVariant.warning:
        return AppColors.warning;
      case ClientActionVariant.error:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final variantColor = _getVariantColor();
    final isEnabled = widget.onPressed != null;

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
              variant: widget.variant == ClientActionVariant.primary
                  ? GlassContainerVariant.primary
                  : widget.variant == ClientActionVariant.info
                      ? GlassContainerVariant.info
                      : GlassContainerVariant.neutral,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              borderRadius: AppRadius.md,
              onTap: isEnabled ? widget.onPressed : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    color: widget.variant == ClientActionVariant.primary ||
                            widget.variant == ClientActionVariant.info
                        ? Colors.white
                        : variantColor,
                    size: 18,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    widget.label,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: widget.variant == ClientActionVariant.primary ||
                              widget.variant == ClientActionVariant.info
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

class ClientCard extends StatefulWidget {
  final User client;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onViewDetails;
  final bool isDark;

  const ClientCard({
    required this.client,
    required this.isSelected,
    required this.onSelect,
    required this.onViewDetails,
    required this.isDark,
  });

  @override
  ClientCardState createState() => ClientCardState();
}

class ClientCardState extends State<ClientCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  // _isHovered removed (unused field)

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
      cursor: SystemMouseCursors.click, // Indique que c'est cliquable
      onEnter: (_) {
        _controller.forward();
      },
      onExit: (_) {
        _controller.reverse();
      },
      child: GestureDetector(
        onTap:
            widget.onSelect, // Rend toute la carte cliquable pour la sélection
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: GlassContainer(
                variant: widget.isSelected
                    ? GlassContainerVariant.primary
                    : GlassContainerVariant.neutral,
                padding: EdgeInsets.all(AppSpacing.md),
                borderRadius: AppRadius.md,
                child: Row(
                  children: [
                    // Avatar client
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.isSelected
                              ? [
                                  Colors.white.withOpacity(0.9),
                                  Colors.white.withOpacity(0.7)
                                ]
                              : [
                                  AppColors.primary,
                                  AppColors.primary.withOpacity(0.8)
                                ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: (widget.isSelected
                                    ? Colors.white
                                    : AppColors.primary)
                                .withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${widget.client.firstName[0]}${widget.client.lastName[0]}'
                              .toUpperCase(),
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: widget.isSelected
                                ? AppColors.primary
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),

                    // Informations client
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.client.firstName} ${widget.client.lastName}',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: widget.isSelected
                                  ? Colors.white
                                  : (widget.isDark
                                      ? AppColors.textLight
                                      : AppColors.textPrimary),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Icon(
                                Icons.email,
                                size: 14,
                                color: widget.isSelected
                                    ? Colors.white.withOpacity(0.8)
                                    : (widget.isDark
                                        ? AppColors.gray400
                                        : AppColors.gray600),
                              ),
                              SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  widget.client.email,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: widget.isSelected
                                        ? Colors.white.withOpacity(0.9)
                                        : (widget.isDark
                                            ? AppColors.gray400
                                            : AppColors.gray600),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Icon(
                                Icons.phone,
                                size: 14,
                                color: widget.isSelected
                                    ? Colors.white.withOpacity(0.8)
                                    : (widget.isDark
                                        ? AppColors.gray400
                                        : AppColors.gray600),
                              ),
                              SizedBox(width: AppSpacing.xs),
                              Text(
                                widget.client.phone ?? 'Pas de téléphone',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: widget.isSelected
                                      ? Colors.white.withOpacity(0.9)
                                      : (widget.isDark
                                          ? AppColors.gray400
                                          : AppColors.gray600),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Actions
                    Column(
                      children: [
                        ClientActionButton(
                          icon: widget.isSelected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          onPressed: widget.onSelect,
                          color: widget.isSelected
                              ? Colors.white
                              : AppColors.primary,
                          isSelected: widget.isSelected,
                        ),
                        SizedBox(height: AppSpacing.sm),
                        ClientActionButton(
                          icon: Icons.visibility,
                          onPressed: widget.onViewDetails,
                          color: widget.isSelected
                              ? Colors.white.withOpacity(0.8)
                              : AppColors.info,
                          isSelected: widget.isSelected,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ClientActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final bool isSelected;

  const ClientActionButton({
    required this.icon,
    required this.onPressed,
    required this.color,
    this.isSelected = false,
  });

  @override
  ClientActionButtonState createState() => ClientActionButtonState();
}

class ClientActionButtonState extends State<ClientActionButton>
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
      end: 1.2,
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
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? Colors.white.withOpacity(0.2)
                    : widget.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: widget.color.withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: 18,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
