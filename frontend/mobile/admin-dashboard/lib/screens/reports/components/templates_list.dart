import 'package:flutter/material.dart';
import '../../../models/report_template.dart';

class TemplatesList extends StatelessWidget {
  final List<ReportTemplate> templates = [
    ReportTemplate(
      id: '1',
      name: 'Monthly Sales',
      columns: ['Order ID', 'Customer', 'Amount', 'Date'],
      filters: {'status': 'Completed'},
    ),
    // ...other templates...
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return ListTile(
          title: Text(template.name),
          subtitle: Text('Columns: ${template.columns.join(', ')}'),
          trailing: Icon(Icons.arrow_forward),
          onTap: () {
            // TODO: Implement template selection logic
          },
        );
      },
    );
  }
}
