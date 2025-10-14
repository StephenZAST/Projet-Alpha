import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../../components/glass_components.dart';
import '../../../providers/orders_provider.dart';
import '../../../core/models/order.dart';

/// 🔍 Dialog de Filtres de Commandes - Alpha Client App
///
/// Permet de filtrer les commandes par statut et dates
class OrderFiltersDialog extends StatefulWidget {
  const OrderFiltersDialog({Key? key}) : super(key: key);

  @override
  State<OrderFiltersDialog> createState() => _OrderFiltersDialogState();
}

class _OrderFiltersDialogState extends State<OrderFiltersDialog> {
  OrderStatus? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<OrdersProvider>(context, listen: false);
    _selectedStatus = provider.filterStatus;
    _startDate = provider.filterStartDate;
    _endDate = provider.filterEndDate;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildStatusFilter(),
            const SizedBox(height: 24),
            _buildDateFilters(),
            const SizedBox(height: 24),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  /// 📋 Header
  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.filter_list,
          color: AppColors.primary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          'Filtres',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  /// 📊 Filtre par statut
  Widget _buildStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statut',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildStatusChip('Tous', null),
            _buildStatusChip('En attente', OrderStatus.pending),
            _buildStatusChip('En cours', OrderStatus.processing),
            _buildStatusChip('Prête', OrderStatus.ready),
            _buildStatusChip('En livraison', OrderStatus.delivering),
            _buildStatusChip('Livrée', OrderStatus.delivered),
            _buildStatusChip('Annulée', OrderStatus.cancelled),
          ],
        ),
      ],
    );
  }

  /// 🏷️ Chip de statut
  Widget _buildStatusChip(String label, OrderStatus? status) {
    final isSelected = _selectedStatus == status;
    final color = status?.color ?? AppColors.textSecondary(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : AppColors.surface(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : AppColors.border(context),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isSelected ? color : AppColors.textSecondary(context),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// 📅 Filtres par date
  Widget _buildDateFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Période',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: 'Du',
                date: _startDate,
                onTap: () => _selectStartDate(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(
                label: 'Au',
                date: _endDate,
                onTap: () => _selectEndDate(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// ��� Champ de date
  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.border(context),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.textPrimary(context),
                ),
                const SizedBox(width: 8),
                Text(
                  date != null
                      ? DateFormat('dd/MM/yyyy').format(date)
                      : 'Sélectionner',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: date != null
                        ? AppColors.textPrimary(context)
                        : AppColors.textTertiary(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🎯 Actions
  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _clearFilters,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: AppColors.border(context)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Effacer',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PremiumButton(
            text: 'Appliquer',
            onPressed: _applyFilters,
            height: 44,
          ),
        ),
      ],
    );
  }

  /// 📅 Sélectionner date de début
  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _startDate = date;
      });
    }
  }

  /// 📅 Sélectionner date de fin
  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  /// 🧹 Effacer les filtres
  void _clearFilters() {
    final provider = Provider.of<OrdersProvider>(context, listen: false);
    provider.clearFilters();
    Navigator.pop(context);
  }

  /// ✅ Appliquer les filtres
  void _applyFilters() {
    final provider = Provider.of<OrdersProvider>(context, listen: false);
    provider.applyFilters(
      status: _selectedStatus,
      startDate: _startDate,
      endDate: _endDate,
    );
    Navigator.pop(context);
  }
}
