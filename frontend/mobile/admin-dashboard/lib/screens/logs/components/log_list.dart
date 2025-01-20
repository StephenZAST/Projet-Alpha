import 'package:flutter/material.dart';
import '../../../models/admin_log.dart';
import 'log_list_tile.dart';

class LogList extends StatelessWidget {
  final List<AdminLog> logs;

  const LogList({Key? key, required this.logs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return LogListTile(log: log);
      },
    );
  }
}
