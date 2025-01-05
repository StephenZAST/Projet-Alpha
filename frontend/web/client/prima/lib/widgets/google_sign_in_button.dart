import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:spring_button/spring_button.dart';
import 'package:provider/provider.dart';
import 'package:prima/providers/auth_provider.dart';

class GoogleSignInButton extends StatelessWidget {
  final String text;

  const GoogleSignInButton({
    super.key,
    this.text = 'Continuer avec Google',
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) => SpringButton(
        SpringButtonType.OnlyScale,
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/google-icon.png', height: 24),
              const SizedBox(width: 12),
              Text(
                text,
                style: const TextStyle(
                  color: AppColors.gray800,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        onTap: authProvider.isLoading
            ? null
            : () async {
                final success = await authProvider.signInWithGoogle();
                if (success && context.mounted) {
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
        useCache: false,
        scaleCoefficient: 0.95,
      ),
    );
  }
}
