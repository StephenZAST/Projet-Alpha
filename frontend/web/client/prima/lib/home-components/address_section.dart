import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/utils/bottom_sheet_manager.dart';
import 'package:spring_button/spring_button.dart';
import 'package:prima/widgets/address_list_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:prima/providers/address_provider.dart';

class AddressSectionComponent extends StatelessWidget {
  const AddressSectionComponent({Key? key}) : super(key: key);

  void _showAddressBottomSheet(BuildContext context) {
    // Utiliser BottomSheetManager au lieu de showModalBottomSheet
    BottomSheetManager().showCustomBottomSheet(
      context: context,
      isDismissible: true,
      builder: (context) => AddressListBottomSheet(
        onSelected: (selectedAddress) {
          Provider.of<AddressProvider>(context, listen: false)
              .setSelectedAddress(selectedAddress);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddressProvider>(
      builder: (context, addressProvider, child) {
        final selectedAddress = addressProvider.selectedAddress;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showAddressBottomSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.labelColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          selectedAddress?.name ?? 'Ajouter une adresse',
                          style: const TextStyle(
                            color: AppColors.labelColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SpringButton(
                SpringButtonType.OnlyScale,
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [AppColors.primaryShadow],
                  ),
                  child: const Icon(Icons.map, color: AppColors.white),
                ),
                onTap: () => _showAddressBottomSheet(context),
                scaleCoefficient: 0.9,
                useCache: false,
              ),
            ],
          ),
        );
      },
    );
  }
}
