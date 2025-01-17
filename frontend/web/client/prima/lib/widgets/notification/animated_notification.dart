import 'package:flutter/material.dart';
import 'package:prima/models/notification.dart' as model;
import 'package:prima/widgets/notification/notification_list_item.dart';

class AnimatedNotification extends StatefulWidget {
  final model.Notification notification;
  final VoidCallback onTap;

  const AnimatedNotification({
    Key? key,
    required this.notification,
    required this.onTap,
  }) : super(key: key);

  @override
  State<AnimatedNotification> createState() => _AnimatedNotificationState();
}

class _AnimatedNotificationState extends State<AnimatedNotification>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(_animation),
      child: FadeTransition(
        opacity: _animation,
        child: NotificationListItem(
          notification: widget.notification,
          onTap: widget.onTap,
        ),
      ),
    );
  }
}
