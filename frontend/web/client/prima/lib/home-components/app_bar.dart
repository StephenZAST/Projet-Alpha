import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:spring_button/spring_button.dart';
import 'package:provider/provider.dart';
import 'package:prima/providers/auth_provider.dart';
import 'package:prima/utils/string_utils.dart';

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
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        final firstName = user?['firstName'] as String?;
        final lastName = user?['lastName'] as String?;
        final initials = getInitials(firstName, lastName);
        final displayName = getDisplayName(firstName, lastName);

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SpringButton(
                    SpringButtonType.OnlyScale,
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [AppColors.primaryShadow],
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ),
                    onTap: () {},
                    scaleCoefficient: 0.9,
                    useCache: false,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.isEmpty ? 'Bienvenue' : title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray800,
                        ),
                      ),
                      Text(
                        displayName,
                        style: const TextStyle(
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SpringButton(
                SpringButtonType.OnlyScale,
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.menu,
                    color: AppColors.gray800,
                    size: 20,
                  ),
                ),
                onTap: onMenuPressed,
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
