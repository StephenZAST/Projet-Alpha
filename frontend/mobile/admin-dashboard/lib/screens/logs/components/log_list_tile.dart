import 'package:flutter/material.dart';
import '../../../models/admin_log.dart';

class LogListTile extends StatelessWidget {
  final AdminLog log;

  const LogListTile({Key? key, required this.log}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('${log.adminName} ${log.action} ${log.entityType}'),
      subtitle: Text('ID: ${log.entityId}'),
      trailing: Text(
        '${log.createdAt}',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
