import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants.dart';

class CopyTextButton extends StatefulWidget {
  final String text;
  final String? tooltip;
  final double iconSize;
  final Color? iconColor;

  const CopyTextButton({
    Key? key,
    required this.text,
    this.tooltip,
    this.iconSize = 18,
    this.iconColor,
  }) : super(key: key);

  @override
  State<CopyTextButton> createState() => _CopyTextButtonState();
}

class _CopyTextButtonState extends State<CopyTextButton>
    with SingleTickerProviderStateMixin {
  bool copied = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.text));
    setState(() {
      copied = true;
    });
    
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    Future.delayed(Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          copied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = widget.iconColor ?? 
        (isDark ? AppColors.primary.withOpacity(0.8) : AppColors.primary);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 350),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              ),
              child: copied
                  ? Container(
                      key: ValueKey('check'),
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        size: widget.iconSize,
                        color: AppColors.success,
                      ),
                    )
                  : MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _copyToClipboard,
                        child: Container(
                          key: ValueKey('copy'),
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: defaultColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: defaultColor.withOpacity(0.2),
                            ),
                          ),
                          child: Icon(
                            Icons.content_copy,
                            size: widget.iconSize,
                            color: defaultColor,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}

class CopyTextRow extends StatelessWidget {
  final String label;
  final String text;
  final bool isDark;
  final IconData? prefixIcon;
  final Color? statusColor;

  const CopyTextRow({
    Key? key,
    required this.label,
    required this.text,
    required this.isDark,
    this.prefixIcon,
    this.statusColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          if (prefixIcon != null) ...[
            Icon(
              prefixIcon,
              size: 16,
              color: statusColor ?? (isDark ? AppColors.gray400 : AppColors.gray600),
            ),
            SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: statusColor ?? (isDark ? AppColors.textLight : AppColors.textPrimary),
                      fontWeight: statusColor != null ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                CopyTextButton(
                  text: text,
                  tooltip: 'Copier $label',
                  iconSize: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}