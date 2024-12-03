import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';

class AddressSectionComponent extends StatelessWidget {
  const AddressSectionComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: AppColors.gray500),
          const SizedBox(width: 8),
          const Text(
            'Ajouter une adresse',
            style: TextStyle(color: AppColors.gray600),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [AppColors.primaryShadow],
            ),
            child: const Icon(Icons.map, color: AppColors.white),
          ),
        ],
      ),
    );
  }
}
