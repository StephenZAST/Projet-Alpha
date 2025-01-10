import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:prima/utils/name_formatter.dart';
import 'package:spring_button/spring_button.dart';
import 'package:provider/provider.dart';
import 'package:prima/providers/auth_provider.dart';

class AppBarComponent extends StatelessWidget {
  final String title;
  final VoidCallback? onMenuPressed;

  const AppBarComponent({
    super.key,
    this.title = '',
    required this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final firstName = user?['firstName'] as String?;
        final lastName = user?['lastName'] as String?;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: onMenuPressed,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenue,',
                      style: TextStyle(
                        color: AppColors.gray600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      NameFormatter.getFormattedName(firstName, lastName),
                      style: TextStyle(
                        color: AppColors.gray800,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SpringButton(
                SpringButtonType.OnlyScale,
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      NameFormatter.getInitials(firstName, lastName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  // Action du bouton
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
