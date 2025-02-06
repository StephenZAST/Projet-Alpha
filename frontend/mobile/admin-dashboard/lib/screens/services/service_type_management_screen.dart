import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart'; // Corriger le chemin
import '../../controllers/service_type_controller.dart'; // Corriger le chemin
import 'components/service_type_management.dart';

class ServiceTypeManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Types de Services'),
      ),
      body: ServiceTypeManagement(),
    );
  }
}
