import 'package:flutter/material.dart';
import 'package:prima/theme/colors.dart';
import 'package:spring_button/spring_button.dart';

class ErrorDialog extends StatelessWidget {
  final String message;
  final String? title;

  const ErrorDialog({
    Key? key,
    required this.message,
    this.title,
  }) : super(key: key);

  static Future<void> show(BuildContext context, String message,
      {String? title}) {
    return showDialog(
      context: context,
      builder: (context) => ErrorDialog(message: message, title: title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.gray700,
              ),
            ),
            const SizedBox(height: 24),
            SpringButton(
              SpringButtonType.OnlyScale,
              Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [AppColors.primaryShadow],
                ),
                child: const Center(
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              onTap: () => Navigator.pop(context),
              scaleCoefficient: 0.95,
              useCache: false,
            ),
          ],
        ),
      ),
    );
  }
}
