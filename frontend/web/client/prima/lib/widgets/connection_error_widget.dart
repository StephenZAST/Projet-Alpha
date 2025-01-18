import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:spring_button/spring_button.dart';

class ConnectionErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;
  final String? customMessage;

  const ConnectionErrorWidget({
    Key? key,
    required this.onRetry,
    this.customMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 80,
              color: AppColors.gray400,
            ),
            const SizedBox(height: 24),
            Text(
              customMessage ?? 'Problème de connexion',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.gray800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Vérifiez votre connexion internet et réessayez',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SpringButton(
              SpringButtonType.OnlyScale,
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [AppColors.primaryShadow],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Réessayer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              onTap: onRetry,
              scaleCoefficient: 0.95,
              useCache: false,
            ),
          ],
        ),
      ),
    );
  }
}
