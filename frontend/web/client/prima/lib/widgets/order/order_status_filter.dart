import 'package:flutter/material.dart';
import 'package:prima/models/order_status.dart';
import 'package:prima/theme/colors.dart';

class OrderStatusFilter extends StatelessWidget {
  final OrderStatus? selectedStatus;
  final Function(OrderStatus?) onStatusSelected;

  const OrderStatusFilter({
    Key? key,
    required this.selectedStatus,
    required this.onStatusSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip(
            label: 'Toutes',
            isSelected: selectedStatus == null,
            onTap: () => onStatusSelected(null),
          ),
          ...OrderStatus.values.map((status) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _buildFilterChip(
                  label: status.label,
                  isSelected: selectedStatus == status,
                  onTap: () => onStatusSelected(status),
                  color: status.color,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppColors.primary).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? (color ?? AppColors.primary) : AppColors.gray300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                isSelected ? (color ?? AppColors.primary) : AppColors.gray600,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
