import 'package:flutter/material.dart';
import 'package:prima/providers/loyalty_provider.dart';
import 'package:prima/theme/colors.dart';
import 'package:provider/provider.dart';

class PointsHistoryWidget extends StatelessWidget {
  const PointsHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LoyaltyProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.transactions.length,
          itemBuilder: (context, index) {
            final transaction = provider.transactions[index];
            return ListTile(
              leading: Icon(
                transaction.type == 'EARNED'
                    ? Icons.add_circle
                    : Icons.remove_circle,
                color: transaction.type == 'EARNED'
                    ? AppColors.success
                    : AppColors.error,
              ),
              title: Text('${transaction.points} points'),
              subtitle: Text(_getSourceText(transaction.source)),
              trailing: Text(
                transaction.type == 'EARNED'
                    ? '+${transaction.points}'
                    : '-${transaction.points}',
                style: TextStyle(
                  color: transaction.type == 'EARNED'
                      ? AppColors.success
                      : AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getSourceText(String source) {
    switch (source) {
      case 'ORDER':
        return 'Commande';
      case 'REFERRAL':
        return 'Parrainage';
      case 'REWARD':
        return 'Récompense';
      default:
        return source;
    }
  }
}
