import 'package:flutter/material.dart';
import '../dashboard/components/notification_badge.dart';

class Header extends StatelessWidget {
  final String title;

  const Header({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Spacer(),
          NotificationBadge(),
        ],
      ),
    );
  }
}
