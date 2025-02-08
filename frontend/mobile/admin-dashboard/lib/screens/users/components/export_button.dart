import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/users_controller.dart';
import '../../../services/export_service.dart';

class ExportButton extends StatelessWidget {
  const ExportButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopupMenuButton<String>(
      tooltip: 'Exporter les données',
      icon: Icon(
        Icons.download_outlined,
        color: isDark ? AppColors.gray300 : AppColors.gray600,
      ),
      itemBuilder: (context) => [
        _buildMenuItem(
          'current',
          'Exporter la page courante',
          Icons.file_download_outlined,
        ),
        _buildMenuItem(
          'all',
          'Exporter tous les utilisateurs',
          Icons.cloud_download_outlined,
        ),
      ],
      onSelected: (value) => _handleExport(value, controller),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
      String value, String text, IconData icon) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20),
          SizedBox(width: AppSpacing.sm),
          Text(text),
        ],
      ),
    );
  }

  Future<void> _handleExport(String value, UsersController controller) async {
    try {
      switch (value) {
        case 'current':
          ExportService.exportUsersToCsv(
            controller.users,
            prefix: 'users_current_page',
          );
          break;
        case 'all':
          final allUsers = await controller.getAllUsersForExport();
          ExportService.exportUsersToCsv(
            allUsers,
            prefix: 'users_all',
          );
          break;
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'exporter les données',
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    }
  }
}
