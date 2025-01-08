import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:spring_button/spring_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:prima/widgets/address_bottom_sheet.dart';

class AddressSectionComponent extends StatelessWidget {
  const AddressSectionComponent({Key? key}) : super(key: key);

  void _showAddressBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddressBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  Icon(
                    Icons.location_on_outlined,
                    color: AppColors.labelColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Ajouter une adresse',
                    style: TextStyle(
                      color: AppColors.labelColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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
  }
}
