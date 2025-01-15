import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:spring_button/spring_button.dart';

class OrderConfirmationPopup extends StatelessWidget {
  final VoidCallback onTrackOrder;
  final VoidCallback onContinueShopping;

  const OrderConfirmationPopup({
    Key? key,
    required this.onTrackOrder,
    required this.onContinueShopping,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/validate.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 24),
            const Text(
              'Commande confirmée !',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.gray800,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Votre commande a été enregistrée avec succès.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(height: 32),
            SpringButton(
              SpringButtonType.OnlyScale,
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [AppColors.primaryShadow],
                ),
                child: const Center(
                  child: Text(
                    'Suivre ma commande',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              onTap: onTrackOrder,
              scaleCoefficient: 0.95,
              useCache: false,
            ),
            const SizedBox(height: 16),
            SpringButton(
              SpringButtonType.OnlyScale,
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Center(
                  child: Text(
                    'Continuer',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              onTap: onContinueShopping,
              scaleCoefficient: 0.95,
              useCache: false,
            ),
          ],
        ),
      ),
    );
  }
}
