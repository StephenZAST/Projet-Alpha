import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../../controllers/users_controller.dart';

class UserSearchBar extends StatelessWidget {
  UserSearchBar({Key? key}) : super(key: key);

  final _debouncer = Debouncer(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();

    return TextField(
      decoration: InputDecoration(
        hintText: 'Rechercher un utilisateur...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onChanged: (value) {
        _debouncer.run(() {
          controller.searchUsers(value);
        });
      },
    );
  }
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
