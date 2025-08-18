import 'package:flutter/material.dart';

class OrderItemRecapCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool darkMode;
  const OrderItemRecapCard(
      {Key? key, required this.item, this.darkMode = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int quantity = item['quantity'] ?? 1;
    final double? weight = item['weight'];
    final int price = item['price'] is int
        ? item['price']
        : (item['price'] as num?)?.toInt() ?? 0;
    final String articleName = item['articleName'] ?? 'Article inconnu';
    final String articleDescription = item['articleDescription'] ?? '';
    final String serviceName = item['serviceName'] ?? '';
    final String serviceTypeLabel = item['serviceTypePricing'] == 'WEIGHT_BASED'
        ? 'Au poids'
        : item['serviceTypePricing'] == 'FIXED'
            ? "À l'article"
            : (item['serviceTypeName'] ?? '');
    final String quantOrWeight = item['serviceTypePricing'] == 'WEIGHT_BASED'
        ? (weight != null ? 'Poids : ${weight.toStringAsFixed(2)} kg' : '')
        : 'Quantité : $quantity';
    final Color textColor = darkMode ? Colors.white : Colors.black87;
    final Color priceColor = Colors.orange[700]!;
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      color: darkMode ? Colors.white.withOpacity(0.04) : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Article : $articleName',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    fontSize: 16)),
            if (articleDescription.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(articleDescription,
                    style: TextStyle(
                        color: textColor.withOpacity(0.7), fontSize: 13)),
              ),
            if (serviceName.isNotEmpty)
              Text('Service : $serviceName',
                  style: TextStyle(color: textColor)),
            if (serviceTypeLabel.isNotEmpty)
              Text('Type de service : $serviceTypeLabel',
                  style: TextStyle(color: textColor)),
            if (quantOrWeight.isNotEmpty)
              Text(quantOrWeight, style: TextStyle(color: textColor)),
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Row(
                children: [
                  Text('Prix unitaire : ', style: TextStyle(color: textColor)),
                  Text('$price FCFA',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: priceColor)),
                ],
              ),
            ),
            Row(
              children: [
                Text('Total : ', style: TextStyle(color: textColor)),
                Text('${price * quantity} FCFA',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: priceColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
