import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/affiliates_controller.dart';
import '../../../models/affiliate.dart';
import '../../../widgets/shared/glass_button.dart';
import '../../../widgets/shared/glass_container.dart';
import 'affiliate_client_link_dialogs.dart';

/// 🔍 Dropdown avec recherche pour les affiliés et clients
class SearchableDropdown<T> extends StatefulWidget {
  final String hintText;
  final List<T> items;
  final T? value;
  final String Function(T item) displayText;
  final String Function(T item) searchText;
  final void Function(T?) onChanged;
  final bool isExpanded;

  const SearchableDropdown({
    Key? key,
    required this.hintText,
    required this.items,
    required this.value,
    required this.displayText,
    required this.searchText,
    required this.onChanged,
    this.isExpanded = true,
  }) : super(key: key);

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  final TextEditingController _searchController = TextEditingController();
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;
  List<T> _filteredItems = [];
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  @override
  void didUpdateWidget(SearchableDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _filteredItems = widget.items;
    }
    // Forcer la mise à jour si la valeur a changé
    if (oldWidget.value != widget.value) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _removeOverlay();
    _searchController.removeListener(_filterItems);
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredItems = widget.items;
      });
    } else {
      setState(() {
        _filteredItems = widget.items.where((item) {
          final searchText = widget.searchText(item).toLowerCase();
          return searchText.contains(query);
        }).toList();
      });
    }
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _removeOverlay,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height + 4,
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height + 4),
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: 200,
                      minWidth: size.width,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.cardBgDark
                          : AppColors.cardBgLight,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.gray700.withOpacity(0.3)
                            : AppColors.gray200.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Barre de recherche
                        Padding(
                          padding: EdgeInsets.all(AppSpacing.sm),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Rechercher...',
                              prefixIcon: Icon(Icons.search, size: 20),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              isDense: true,
                            ),
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                        Divider(height: 1),
                        // Liste filtrée
                        Expanded(
                          child: _filteredItems.isEmpty
                              ? Padding(
                                  padding: EdgeInsets.all(AppSpacing.md),
                                  child: Text(
                                    'Aucun résultat trouvé',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _filteredItems.length,
                                  itemBuilder: (context, index) {
                                    final item = _filteredItems[index];
                                    final isSelected = item == widget.value;

                                    return InkWell(
                                      onTap: () {
                                        widget.onChanged(item);
                                        _removeOverlay();

                                        // Feedback visuel avec vibration légère
                                        if (mounted) {
                                          // Animation de feedback
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    '${widget.displayText(item)} sélectionné',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                              backgroundColor:
                                                  AppColors.success,
                                              duration:
                                                  Duration(milliseconds: 1500),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              margin: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                        .size
                                                        .height -
                                                    100,
                                                left: 20,
                                                right: 20,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: AppSpacing.md,
                                          vertical: AppSpacing.sm,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? (Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? AppColors.primary
                                                      .withOpacity(0.1)
                                                  : AppColors.primaryLight
                                                      .withOpacity(0.1))
                                              : Colors.transparent,
                                        ),
                                        child: Row(
                                          children: [
                                            if (isSelected) ...[
                                              Icon(
                                                Icons.check_circle,
                                                color: AppColors.primary,
                                                size: 16,
                                              ),
                                              SizedBox(width: AppSpacing.xs),
                                            ],
                                            Expanded(
                                              child: Text(
                                                widget.displayText(item),
                                                style: AppTextStyles.bodySmall
                                                    .copyWith(
                                                  color: isSelected
                                                      ? AppColors.primary
                                                      : Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.dark
                                                          ? AppColors.textLight
                                                          : AppColors
                                                              .textPrimary,
                                                  fontWeight: isSelected
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isDropdownOpen = true;
    });
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    
    // Nettoyer le contrôleur seulement s'il n'est pas disposé
    if (!_isDisposed && _searchController.hasListeners) {
      try {
        _searchController.clear();
      } catch (e) {
        // Ignorer les erreurs si le contrôleur est déjà disposé
        print('[SearchableDropdown] Warning: Could not clear search controller: $e');
      }
    }
    
    _filteredItems = widget.items;
    
    if (mounted && !_isDisposed) {
      setState(() {
        _isDropdownOpen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasSelection = widget.value != null;

    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: _toggleDropdown,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: hasSelection
                ? (isDark
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.primaryLight.withOpacity(0.1))
                : (isDark ? AppColors.cardBgDark : AppColors.cardBgLight),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: hasSelection
                  ? AppColors.primary.withOpacity(0.5)
                  : (isDark
                      ? AppColors.gray700.withOpacity(0.3)
                      : AppColors.gray200.withOpacity(0.5)),
              width: hasSelection ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Icône de sélection
              if (hasSelection) ...[
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 18,
                ),
                SizedBox(width: AppSpacing.xs),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Label du champ
                    if (hasSelection) ...[
                      Text(
                        widget.hintText,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2),
                    ],
                    // Valeur sélectionnée ou placeholder
                    Text(
                      hasSelection
                          ? widget.displayText(widget.value as T)
                          : widget.hintText,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: hasSelection
                            ? (isDark
                                ? AppColors.textLight
                                : AppColors.textPrimary)
                            : AppColors.textMuted,
                        fontWeight:
                            hasSelection ? FontWeight.w600 : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Icon(
                _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: hasSelection ? AppColors.primary : AppColors.textMuted,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AffiliateClientLinks extends StatelessWidget {
  const AffiliateClientLinks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AffiliatesController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header avec bouton d'ajout
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Liaisons Affilié-Client',
              style: AppTextStyles.h3.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            GlassButton(
              label: 'Nouvelle liaison',
              icon: Icons.add,
              onPressed: () => showCreateAffiliateClientLinkDialog(context),
              size: GlassButtonSize.small,
            ),
          ],
        ),
        SizedBox(height: defaultPadding),

        // Liste des liaisons
        Expanded(
          child: Obx(() {
            if (controller.isLoadingLinks.value) {
              return Center(child: CircularProgressIndicator());
            }

            if (controller.affiliateClientLinks.isEmpty) {
              return _buildEmptyState(context, isDark);
            }

            return ListView.builder(
              itemCount: controller.affiliateClientLinks.length,
              itemBuilder: (context, index) {
                final link = controller.affiliateClientLinks[index];
                return _buildLinkCard(context, link, isDark);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.link_off,
            size: 64,
            color: isDark ? AppColors.gray400 : AppColors.gray500,
          ),
          SizedBox(height: defaultPadding),
          Text(
            'Aucune liaison trouvée',
            style: AppTextStyles.bodyLarge.copyWith(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Créez votre première liaison affilié-client',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLinkCard(
      BuildContext context, AffiliateClientLink link, bool isDark) {
    return GlassContainer(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Affilié: ${link.affiliateName}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textLight
                              : AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        'Client: ${link.clientName}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.gray300
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: link.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    link.statusLabel,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: link.statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppColors.gray500),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'Début: ${_formatDate(link.startDate)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                  ),
                ),
                if (link.endDate != null) ...[
                  SizedBox(width: AppSpacing.md),
                  Text(
                    'Fin: ${_formatDate(link.endDate!)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color:
                          isDark ? AppColors.gray300 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GlassButton(
                  label: 'Modifier',
                  onPressed: () =>
                      showEditAffiliateClientLinkDialog(context, link),
                  size: GlassButtonSize.small,
                  variant: GlassButtonVariant.secondary,
                ),
                SizedBox(width: AppSpacing.sm),
                GlassButton(
                  label: 'Supprimer',
                  onPressed: () =>
                      showDeleteAffiliateClientLinkDialog(context, link),
                  size: GlassButtonSize.small,
                  variant: GlassButtonVariant.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
