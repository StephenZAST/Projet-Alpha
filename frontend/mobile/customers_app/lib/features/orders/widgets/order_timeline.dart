import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../../core/models/order.dart';

/// 📈 Timeline de Commande - Alpha Client App
///
/// Affiche le suivi visuel de l'évolution d'une commande
class OrderTimeline extends StatelessWidget {
  final Order order;

  const OrderTimeline({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final steps = _getTimelineSteps();

    return Column(
      children: List.generate(
        steps.length,
        (index) => _buildTimelineStep(
          context,
          steps[index],
          isLast: index == steps.length - 1,
        ),
      ),
    );
  }

  /// 📋 Obtenir les étapes de la timeline
  List<TimelineStep> _getTimelineSteps() {
    return [
      TimelineStep(
        status: OrderStatus.pending,
        title: 'Commande creee',
        date: order.createdAt,
        isCompleted: true,
      ),
      TimelineStep(
        status: OrderStatus.collecting,
        title: 'Collecte en cours',
        date: order.status.index >= OrderStatus.collecting.index
            ? (order.createdAt.add(const Duration(hours: 2)))
            : null,
        isCompleted: order.status.index >= OrderStatus.collecting.index,
      ),
      TimelineStep(
        status: OrderStatus.collected,
        title: 'Articles collectes',
        date: order.status.index >= OrderStatus.collected.index
            ? (order.createdAt.add(const Duration(hours: 4)))
            : null,
        isCompleted: order.status.index >= OrderStatus.collected.index,
      ),
      TimelineStep(
        status: OrderStatus.processing,
        title: 'Traitement en cours',
        date: order.processingAt,
        isCompleted: order.status.index >= OrderStatus.processing.index,
      ),
      TimelineStep(
        status: OrderStatus.ready,
        title: 'Prete pour livraison',
        date: order.readyAt,
        isCompleted: order.status.index >= OrderStatus.ready.index,
      ),
      TimelineStep(
        status: OrderStatus.delivering,
        title: 'En cours de livraison',
        date: order.deliveringAt,
        isCompleted: order.status.index >= OrderStatus.delivering.index,
      ),
      TimelineStep(
        status: OrderStatus.delivered,
        title: 'Livree',
        date: order.deliveredAt,
        isCompleted: order.status == OrderStatus.delivered,
      ),
    ];
  }

  /// 🔹 Construire une étape de la timeline
  Widget _buildTimelineStep(BuildContext context, TimelineStep step,
      {required bool isLast}) {
    final isCurrent = order.status == step.status;
    final color =
        step.isCompleted ? step.status.color : AppColors.textTertiary(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indicateur vertical
        Column(
          children: [
            // Cercle
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: step.isCompleted
                    ? color.withOpacity(0.15)
                    : AppColors.surface(context),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: step.isCompleted ? 2 : 1,
                ),
              ),
              child: Center(
                child: step.isCompleted
                    ? Icon(
                        isCurrent ? Icons.radio_button_checked : Icons.check,
                        color: color,
                        size: 16,
                      )
                    : Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
              ),
            ),
            // Ligne verticale
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: step.isCompleted
                    ? color.withOpacity(0.3)
                    : AppColors.border(context),
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Contenu
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: step.isCompleted
                        ? AppColors.textPrimary(context)
                        : AppColors.textSecondary(context),
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                if (step.date != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(step.date!),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary(context),
                    ),
                  ),
                ] else if (!step.isCompleted) ...[
                  const SizedBox(height: 4),
                  Text(
                    'En attente',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary(context),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 📅 Formater la date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Hier ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    }
  }
}

/// 📋 Modèle d'étape de timeline
class TimelineStep {
  final OrderStatus status;
  final String title;
  final DateTime? date;
  final bool isCompleted;

  TimelineStep({
    required this.status,
    required this.title,
    this.date,
    required this.isCompleted,
  });
}
