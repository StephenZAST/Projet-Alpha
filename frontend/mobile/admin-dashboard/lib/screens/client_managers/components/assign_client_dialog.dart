import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin/constants.dart';
import 'package:admin/models/client_manager.dart';
import 'package:admin/widgets/shared/glass_container.dart';
import 'package:admin/widgets/shared/glass_button.dart';
import 'package:admin/services/client_manager_service.dart';

/// Dialog pour assigner un client à un agent
class AssignClientDialog extends StatefulWidget {
  final AgentStats agent;
  final VoidCallback onSuccess;

  const AssignClientDialog({
    Key? key,
    required this.agent,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<AssignClientDialog> createState() => _AssignClientDialogState();
}

class _AssignClientDialogState extends State<AssignClientDialog> {
  final TextEditingController clientIdController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    clientIdController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _assignClient() async {
    if (clientIdController.text.isEmpty) {
      setState(() => errorMessage = 'Veuillez entrer l\'ID du client');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await ClientManagerService.assignClient(
        agentId: widget.agent.id,
        clientId: clientIdController.text.trim(),
        notes: notesController.text.isNotEmpty ? notesController.text : null,
      );

      Get.back();
      widget.onSuccess();
      Get.snackbar(
        'Succès',
        'Client assigné avec succès à ${widget.agent.name}',
        backgroundColor: AppColors.success.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      setState(() => errorMessage = e.toString());
      Get.snackbar(
        'Erreur',
        'Impossible d\'assigner le client: $e',
        backgroundColor: AppColors.error.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(AppSpacing.lg),
      child: GlassContainer(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assigner un Client',
                        style: AppTextStyles.h3.copyWith(
                          color: isDark ? AppColors.textLight : AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        'À: ${widget.agent.name}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark ? AppColors.gray300 : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),

              // Formulaire
              if (errorMessage != null) ...[
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: AppRadius.radiusMD,
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: AppColors.error),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.md),
              ],

              // ID Client
              Text(
                'ID du Client *',
                style: AppTextStyles.bodyBold.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              TextField(
                controller: clientIdController,
                enabled: !isLoading,
                decoration: InputDecoration(
                  hintText: 'Entrez l\'ID du client (UUID)',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.radiusMD,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.gray800.withOpacity(0.3)
                      : Colors.white.withOpacity(0.5),
                ),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.lg),

              // Notes
              Text(
                'Notes (Optionnel)',
                style: AppTextStyles.bodyBold.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              TextField(
                controller: notesController,
                enabled: !isLoading,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Ajoutez des notes sur ce client...',
                  prefixIcon: Icon(Icons.note_outlined),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.radiusMD,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.gray800.withOpacity(0.3)
                      : Colors.white.withOpacity(0.5),
                ),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.lg),

              // Boutons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GlassButton(
                    label: 'Annuler',
                    icon: Icons.close,
                    variant: GlassButtonVariant.secondary,
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                  ),
                  SizedBox(width: AppSpacing.md),
                  GlassButton(
                    label: isLoading ? 'Assignation...' : 'Assigner',
                    icon: Icons.check_circle_outline,
                    variant: GlassButtonVariant.primary,
                    onPressed: isLoading ? null : _assignClient,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
