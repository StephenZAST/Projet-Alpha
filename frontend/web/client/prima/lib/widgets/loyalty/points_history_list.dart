import 'package:flutter/material.dart';
import 'package:prima/models/point_transaction.dart';
import 'package:prima/theme/colors.dart';
import 'package:timeago/timeago.dart' as timeago;

class PointsHistoryList extends StatelessWidget {
  final List<PointTransaction> transactions;

  const PointsHistoryList({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: AppColors.gray400),
            SizedBox(height: 16),
            Text(
              'Aucune transaction',
              style: TextStyle(color: AppColors.gray600),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final isEarned = transaction.type == TransactionType.EARNED;

        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isEarned ? AppColors.success : AppColors.error)
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEarned ? Icons.add : Icons.remove,
              color: isEarned ? AppColors.success : AppColors.error,
            ),
          ),
          title: Text(transaction.getSourceText()),
          subtitle: Text(
            timeago.format(transaction.createdAt, locale: 'fr'),
            style: const TextStyle(fontSize: 12),
          ),
          trailing: Text(
            '${isEarned ? '+' : '-'}${transaction.points}',
            style: TextStyle(
              color: isEarned ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
