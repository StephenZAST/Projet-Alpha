import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';

class DeleteUserDialog extends StatelessWidget {
  final String userId;
  final String userName;

  const DeleteUserDialog({
    required this.userId,
    required this.userName,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMD),
      title: Text('Confirmer la suppression'),
      content:
          Text('Voulez-vous vraiment supprimer l\'utilisateur $userName ?'),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: Text('Supprimer'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.error,
          ),
        ),
      ],
    );
  }
}
