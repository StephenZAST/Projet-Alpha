import 'package:flutter/material.dart';
import '../../constants.dart';
import 'glass_container.dart';

class ModernPagination extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final String paginationInfo;
  final bool isLoading;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final Function(int)? onPageSelected;
  final bool hasPrevious;
  final bool hasNext;

  const ModernPagination({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.paginationInfo,
    this.isLoading = false,
    this.onPrevious,
    this.onNext,
    this.onPageSelected,
    this.hasPrevious = false,
    this.hasNext = false,
  }) : super(key: key);

  @override
  State<ModernPagination> createState() => _ModernPaginationState();
}

class _ModernPaginationState extends State<ModernPagination>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
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

    if (widget.totalPages <= 1) {
      return SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: GlassContainer(
              variant: GlassContainerVariant.neutral,
              padding: EdgeInsets.all(AppSpacing.md),
              borderRadius: AppRadius.lg,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Info de pagination
                  _buildPaginationInfo(isDark),
                  SizedBox(height: AppSpacing.md),
                  
                  // Contrôles de pagination
                  _buildPaginationControls(isDark),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaginationInfo(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.info_outline,
          size: 16,
          color: isDark ? AppColors.gray400 : AppColors.gray600,
        ),
        SizedBox(width: AppSpacing.sm),
        Text(
          widget.paginationInfo,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.gray300 : AppColors.gray700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPaginationControls(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Bouton Précédent
        _ModernPaginationButton(
          icon: Icons.chevron_left,
          label: 'Précédent',
          isEnabled: widget.hasPrevious && !widget.isLoading,
          onPressed: widget.onPrevious,
          variant: _PaginationButtonVariant.navigation,
          isDark: isDark,
        ),
        
        SizedBox(width: AppSpacing.sm),
        
        // Pages
        Expanded(
          child: _buildPageNumbers(isDark),
        ),
        
        SizedBox(width: AppSpacing.sm),
        
        // Bouton Suivant
        _ModernPaginationButton(
          icon: Icons.chevron_right,
          label: 'Suivant',
          isEnabled: widget.hasNext && !widget.isLoading,
          onPressed: widget.onNext,
          variant: _PaginationButtonVariant.navigation,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildPageNumbers(bool isDark) {
    final List<Widget> pageButtons = [];
    final int totalPages = widget.totalPages;
    final int currentPage = widget.currentPage;
    
    // Logique pour afficher les numéros de page
    List<int> pagesToShow = _calculatePagesToShow(currentPage, totalPages);
    
    for (int i = 0; i < pagesToShow.length; i++) {
      final pageNumber = pagesToShow[i];
      
      // Ajouter des ellipses si nécessaire
      if (i > 0 && pagesToShow[i] - pagesToShow[i - 1] > 1) {
        pageButtons.add(_buildEllipsis(isDark));
      }
      
      pageButtons.add(
        _ModernPaginationButton(
          label: pageNumber.toString(),
          isEnabled: !widget.isLoading,
          onPressed: pageNumber == currentPage 
              ? null 
              : () => widget.onPageSelected?.call(pageNumber),
          variant: pageNumber == currentPage 
              ? _PaginationButtonVariant.active 
              : _PaginationButtonVariant.page,
          isDark: isDark,
        ),
      );
      
      if (i < pagesToShow.length - 1) {
        pageButtons.add(SizedBox(width: AppSpacing.xs));
      }
    }
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: pageButtons,
      ),
    );
  }

  Widget _buildEllipsis(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Text(
        '...',
        style: AppTextStyles.bodyMedium.copyWith(
          color: isDark ? AppColors.gray400 : AppColors.gray600,
        ),
      ),
    );
  }

  List<int> _calculatePagesToShow(int currentPage, int totalPages) {
    if (totalPages <= 7) {
      return List.generate(totalPages, (index) => index + 1);
    }
    
    List<int> pages = [];
    
    // Toujours inclure la première page
    pages.add(1);
    
    if (currentPage <= 4) {
      // Si on est près du début
      for (int i = 2; i <= 5; i++) {
        pages.add(i);
      }
      pages.add(totalPages);
    } else if (currentPage >= totalPages - 3) {
      // Si on est près de la fin
      for (int i = totalPages - 4; i < totalPages; i++) {
        pages.add(i);
      }
      pages.add(totalPages);
    } else {
      // Au milieu
      pages.add(currentPage - 1);
      pages.add(currentPage);
      pages.add(currentPage + 1);
      pages.add(totalPages);
    }
    
    return pages.toSet().toList()..sort();
  }
}

enum _PaginationButtonVariant { navigation, page, active }

class _ModernPaginationButton extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final bool isEnabled;
  final VoidCallback? onPressed;
  final _PaginationButtonVariant variant;
  final bool isDark;

  const _ModernPaginationButton({
    this.label,
    this.icon,
    required this.isEnabled,
    this.onPressed,
    required this.variant,
    required this.isDark,
  });

  @override
  State<_ModernPaginationButton> createState() => _ModernPaginationButtonState();
}

class _ModernPaginationButtonState extends State<_ModernPaginationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

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
    final isActive = widget.variant == _PaginationButtonVariant.active;
    final isNavigation = widget.variant == _PaginationButtonVariant.navigation;
    
    return MouseRegion(
      onEnter: (_) {
        if (widget.isEnabled) {
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
            child: GestureDetector(
              onTap: widget.isEnabled ? widget.onPressed : null,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: isNavigation ? AppSpacing.md : AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  gradient: isActive
                      ? LinearGradient(
                          colors: [AppColors.info, AppColors.info.withOpacity(0.8)],
                        )
                      : _isHovered && widget.isEnabled
                          ? LinearGradient(
                              colors: [
                                AppColors.info.withOpacity(0.1),
                                AppColors.info.withOpacity(0.05),
                              ],
                            )
                          : null,
                  color: !isActive && (!_isHovered || !widget.isEnabled)
                      ? (widget.isDark 
                          ? AppColors.gray700.withOpacity(0.3)
                          : AppColors.gray200.withOpacity(0.5))
                      : null,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isActive
                        ? AppColors.info.withOpacity(0.3)
                        : _isHovered && widget.isEnabled
                            ? AppColors.info.withOpacity(0.2)
                            : (widget.isDark 
                                ? AppColors.gray600.withOpacity(0.3)
                                : AppColors.gray300.withOpacity(0.5)),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        size: 18,
                        color: isActive
                            ? Colors.white
                            : widget.isEnabled
                                ? (widget.isDark ? AppColors.textLight : AppColors.textPrimary)
                                : (widget.isDark ? AppColors.gray500 : AppColors.gray400),
                      ),
                      if (widget.label != null) SizedBox(width: AppSpacing.xs),
                    ],
                    if (widget.label != null)
                      Text(
                        widget.label!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isActive
                              ? Colors.white
                              : widget.isEnabled
                                  ? (widget.isDark ? AppColors.textLight : AppColors.textPrimary)
                                  : (widget.isDark ? AppColors.gray500 : AppColors.gray400),
                          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
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