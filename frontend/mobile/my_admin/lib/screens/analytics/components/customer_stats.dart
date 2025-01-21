import 'package:flutter/material.dart';
import '../../../constants.dart';

class CustomerStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.secondaryBg,
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Customer Stats",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: defaultPadding),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Customer ${index + 1}'),
                    trailing: Text('50 orders'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
