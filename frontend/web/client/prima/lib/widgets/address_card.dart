import 'package:flutter/material.dart';
import 'package:prima/models/address.dart';
import 'package:prima/theme/colors.dart';
import 'package:spring_button/spring_button.dart';
import 'package:provider/provider.dart';
import 'package:prima/providers/address_provider.dart';

class AddressCard extends StatelessWidget {
  final Address address;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isSelected;

  const AddressCard({
    Key? key,
    required this.address,
    this.onEdit,
    this.onDelete,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryLight : AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        border:
            isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Increased shadow opacity
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SpringButton(
        SpringButtonType.OnlyScale,
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (address.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.successLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Par défaut',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (address.isDefault) const SizedBox(width: 8),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle,
                                    color: AppColors.primary, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Sélectionnée',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Expanded(
                          child: Text(
                            address.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  Colors.white, // Changed text color to white
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (address.latitude != null &&
                            address.longitude != null)
                          Icon(
                            Icons.location_on,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        if (address.latitude != null &&
                            address.longitude != null)
                          const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Vérifier si street existe avant de l'afficher
                              if (address.street != null &&
                                  address.street!.isNotEmpty)
                                Text(
                                  address.street!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              // Gérer le cas où postalCode est optionnel
                              Text(
                                [
                                  if (address.postalCode != null)
                                    address.postalCode,
                                  address.city
                                ].where((e) => e != null).join(' '),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Added building icon
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Image.asset(
                  'assets/Building.png',
                  width: 56,
                  height: 51,
                ),
              ),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: onEdit,
                  color: Colors.white, // Changed icon color to white
                ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                  color: Colors.white, // Changed icon color to white
                ),
            ],
          ),
        ),
        onTap: () {
          context.read<AddressProvider>().selectAddress(address);
          Navigator.pop(context);
        },
      ),
    );
  }
}
