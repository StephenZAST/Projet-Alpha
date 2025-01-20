import 'package:flutter/material.dart';
import 'components/custom_report_builder.dart';
import 'components/templates_list.dart';

class ReportTemplatesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Report Templates')),
      body: Column(
        children: [
          CustomReportBuilder(),
          Expanded(child: TemplatesList()),
        ],
      ),
    );
  }
}
