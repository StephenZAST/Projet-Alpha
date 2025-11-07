import 'package:flutter/material.dart';
import 'package:admin/controllers/orders_controller.dart';
import '../../../constants.dart';

/// Dialog pour modifier le prix manuel d'une commande
/// 
/// Permet à l'utilisateur de :
/// - Entrer un nouveau prix (validation >= 0)
/// - Ajouter une raison optionnelle
/// - Voir les erreurs de validation en temps réel
Future<void> showManualPriceDialog(
  BuildContext context,
  String orderId,
  OrdersController controller,
) async {
  final manualPriceController = TextEditingController();
  final reasonController = TextEditingController();
  String? errorMessage;

  await showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit_note, color: AppColors.primary, size: 28),
            SizedBox(width: AppSpacing.md),
            Text('Modifier le prix manuel'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Prix manuel
              Text(
                'Nouveau prix (FCFA)',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              TextField(
                controller: manualPriceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Ex: 5000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.attach_money),
                  errorText: errorMessage,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              // Raison (optionnel)
              Text(
                'Raison de la modification (optionnel)',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  hintText: 'Ex: Remise client, erreur de calcul...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.note),
                ),
                minLines: 2,
                maxLines: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final priceStr = manualPriceController.text.trim();
              final reason = reasonController.text.trim();

              // Validation
              if (priceStr.isEmpty) {
                setState(() {
                  errorMessage = 'Le prix est requis';
                });
                return;
              }

              final price = double.tryParse(priceStr);
              if (price == null || price < 0) {
                setState(() {
                  errorMessage = 'Prix invalide (doit être >= 0)';
                });
                return;
              }

              // Appliquer la modification
              try {
                await controller.applyManualPrice(
                  orderId,
                  manualPrice: price,
                  reason: reason.isNotEmpty ? reason : null,
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (context.mounted) {
                  setState(() {
                    errorMessage = 'Erreur: $e';
                  });
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text(
              'Appliquer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Dialog pour marquer une commande comme payée/non payée
/// 
/// Permet à l'utilisateur de :
/// - Confirmer le changement de statut de paiement
/// - Ajouter une raison optionnelle
/// - Voir les icônes et couleurs appropriées selon l'action
Future<void> showPaymentReasonDialog(
  BuildContext context,
  String orderId,
  OrdersController controller,
  bool markAsPaid,
) async {
  final reasonController = TextEditingController();

  await showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Row(
        children: [
          Icon(
            markAsPaid ? Icons.check_circle : Icons.cancel,
            color: markAsPaid ? AppColors.success : AppColors.error,
            size: 28,
          ),
          SizedBox(width: AppSpacing.md),
          Text(
            markAsPaid ? 'Marquer comme payée' : 'Marquer comme non payée',
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Raison (optionnel)',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Ex: Paiement reçu, erreur système...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.note),
              ),
              minLines: 2,
              maxLines: 4,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () async {
            final reason = reasonController.text.trim();

            try {
              if (markAsPaid) {
                await controller.markAsPaid(
                  orderId,
                  reason: reason.isNotEmpty ? reason : null,
                );
              } else {
                await controller.markAsUnpaid(
                  orderId,
                  reason: reason.isNotEmpty ? reason : null,
                );
              }
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: $e')),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                markAsPaid ? AppColors.success : AppColors.error,
          ),
          child: Text(
            'Confirmer',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
