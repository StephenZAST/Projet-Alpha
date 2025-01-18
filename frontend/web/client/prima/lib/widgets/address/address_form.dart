import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:spring_button/spring_button.dart';

class AddressForm extends StatelessWidget {
  final TextEditingController addressNameController;
  final TextEditingController streetController;
  final TextEditingController cityController;
  final TextEditingController postalCodeController;
  final VoidCallback onNext;

  const AddressForm({
    Key? key,
    required this.addressNameController,
    required this.streetController,
    required this.cityController,
    required this.postalCodeController,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAddressForm(),
          const SizedBox(height: 24),
          _buildNextButton(context),
        ],
      ),
    );
  }

  Widget _buildAddressForm() {
    return Column(
      children: [
        TextField(
          controller: addressNameController,
          decoration: InputDecoration(
            labelText: 'Nom de l\'adresse *',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            errorText:
                addressNameController.text.isEmpty ? 'Champ requis' : null,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: streetController,
          decoration: InputDecoration(
            labelText: 'Rue ou Quartier (optionnel)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: cityController,
                decoration: InputDecoration(
                  labelText: 'Ville *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText:
                      cityController.text.isEmpty ? 'Champ requis' : null,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: postalCodeController,
                decoration: InputDecoration(
                  labelText: 'Code postal (optionnel)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return SpringButton(
      SpringButtonType.OnlyScale,
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_outlined,
              color: AppColors.primary,
            ),
            SizedBox(width: 8),
            Text(
              'Passer à la localisation',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      onTap: onNext,
    );
  }
}
