import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../constants.dart';
import '../../../widgets/shared/glass_container.dart';
import '../../../widgets/shared/glass_button.dart';

class NotificationFilters extends StatefulWidget {
  final String selectedType;
  final String selectedStatus;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearFilters;

  const NotificationFilters({
    Key? key,
    required this.selectedType,
    required this.selectedStatus,
    required this.onTypeChanged,
    required this.onStatusChanged,
    required this.onSearchChanged,
    required this.onClearFilters,
  }) : super(key: key);

  @override
  State<NotificationFilters> createState() => _NotificationFiltersState();
}

class _NotificationFiltersState extends State<NotificationFilters> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // Première ligne : Recherche
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildSearchField(context, isDark),
              ),
              SizedBox(width: AppSpacing.md),
              if (_searchController.text.isNotEmpty || 
                  widget.selectedType != 'ALL' || 
                  widget.selectedStatus != 'ALL')
                GlassButton(
                  label: 'Effacer',
                  icon: Icons.clear_all,
                  variant: GlassButtonVariant.secondary,
                  size: GlassButtonSize.small,
                  onPressed: () {
                    _searchController.clear();
                    widget.onSearchChanged('');
                    widget.onTypeChanged('ALL');
                    widget.onStatusChanged('ALL');
                    widget.onClearFilters();
                    setState(() {});
                  },
                ),
            ],
          ),
          
          SizedBox(height: AppSpacing.md),
          
          // Deuxième ligne : Filtres
          Row(
            children: [
              Expanded(
                child: _buildTypeFilter(context, isDark),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatusFilter(context, isDark),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildPriorityFilter(context, isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.gray800.withOpacity(0.5)
            : AppColors.white.withOpacity(0.7),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark
              ? AppColors.gray700.withOpacity(0.3)
              : AppColors.gray200.withOpacity(0.5),
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: widget.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Rechercher dans les notifications...',
          hintStyle: TextStyle(
            color: isDark ? AppColors.gray400 : AppColors.gray500,
          ),
          prefixIcon: Icon(
            Icons.search_outlined,
            color: isDark ? AppColors.gray400 : AppColors.gray500,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: isDark ? AppColors.gray400 : AppColors.gray500,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    widget.onSearchChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
        ),
        style: TextStyle(
          color: isDark ? AppColors.textLight : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTypeFilter(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.gray800.withOpacity(0.5)
            : AppColors.white.withOpacity(0.7),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark
              ? AppColors.gray700.withOpacity(0.3)
              : AppColors.gray200.withOpacity(0.5),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: widget.selectedType,
        decoration: InputDecoration(
          labelText: 'Type',
          labelStyle: TextStyle(
            color: isDark ? AppColors.gray300 : AppColors.gray600,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
        dropdownColor: isDark ? AppColors.gray800 : AppColors.white,
        style: TextStyle(
          color: isDark ? AppColors.textLight : AppColors.textPrimary,
        ),
        items: [
          DropdownMenuItem(
            value: 'ALL',
            child: Text('Tous les types'),
          ),
          DropdownMenuItem(
            value: 'order',
            child: Row(
              children: [
                Icon(Icons.shopping_cart, size: 16, color: AppColors.primary),
                SizedBox(width: AppSpacing.xs),
                Text('Commandes'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'payment',
            child: Row(
              children: [
                Icon(Icons.payment, size: 16, color: AppColors.success),
                SizedBox(width: AppSpacing.xs),
                Text('Paiements'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'delivery',
            child: Row(
              children: [
                Icon(Icons.local_shipping, size: 16, color: AppColors.info),
                SizedBox(width: AppSpacing.xs),
                Text('Livraisons'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'user',
            child: Row(
              children: [
                Icon(Icons.person, size: 16, color: AppColors.violet),
                SizedBox(width: AppSpacing.xs),
                Text('Utilisateurs'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'support',
            child: Row(
              children: [
                Icon(Icons.support_agent, size: 16, color: AppColors.warning),
                SizedBox(width: AppSpacing.xs),
                Text('Support'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'system',
            child: Row(
              children: [
                Icon(Icons.settings, size: 16, color: AppColors.gray500),
                SizedBox(width: AppSpacing.xs),
                Text('Système'),
              ],
            ),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            widget.onTypeChanged(value);
          }
        },
      ),
    );
  }

  Widget _buildStatusFilter(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.gray800.withOpacity(0.5)
            : AppColors.white.withOpacity(0.7),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark
              ? AppColors.gray700.withOpacity(0.3)
              : AppColors.gray200.withOpacity(0.5),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: widget.selectedStatus,
        decoration: InputDecoration(
          labelText: 'Statut',
          labelStyle: TextStyle(
            color: isDark ? AppColors.gray300 : AppColors.gray600,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
        dropdownColor: isDark ? AppColors.gray800 : AppColors.white,
        style: TextStyle(
          color: isDark ? AppColors.textLight : AppColors.textPrimary,
        ),
        items: [
          DropdownMenuItem(
            value: 'ALL',
            child: Text('Tous les statuts'),
          ),
          DropdownMenuItem(
            value: 'unread',
            child: Row(
              children: [
                Icon(Icons.mark_email_unread, size: 16, color: AppColors.error),
                SizedBox(width: AppSpacing.xs),
                Text('Non lues'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'read',
            child: Row(
              children: [
                Icon(Icons.mark_email_read, size: 16, color: AppColors.success),
                SizedBox(width: AppSpacing.xs),
                Text('Lues'),
              ],
            ),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            widget.onStatusChanged(value);
          }
        },
      ),
    );
  }

  Widget _buildPriorityFilter(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.gray800.withOpacity(0.5)
            : AppColors.white.withOpacity(0.7),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isDark
              ? AppColors.gray700.withOpacity(0.3)
              : AppColors.gray200.withOpacity(0.5),
        ),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Priorité',
          labelStyle: TextStyle(
            color: isDark ? AppColors.gray300 : AppColors.gray600,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
        dropdownColor: isDark ? AppColors.gray800 : AppColors.white,
        style: TextStyle(
          color: isDark ? AppColors.textLight : AppColors.textPrimary,
        ),
        items: [
          DropdownMenuItem(
            value: 'ALL',
            child: Text('Toutes priorités'),
          ),
          DropdownMenuItem(
            value: 'high',
            child: Row(
              children: [
                Icon(Icons.priority_high, size: 16, color: AppColors.error),
                SizedBox(width: AppSpacing.xs),
                Text('Haute'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'medium',
            child: Row(
              children: [
                Icon(Icons.remove, size: 16, color: AppColors.warning),
                SizedBox(width: AppSpacing.xs),
                Text('Moyenne'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'low',
            child: Row(
              children: [
                Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.success),
                SizedBox(width: AppSpacing.xs),
                Text('Basse'),
              ],
            ),
          ),
        ],
        onChanged: (value) {
          // TODO: Implémenter le filtre par priorité
        },
      ),
    );
  }
}