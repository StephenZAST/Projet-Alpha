import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/service_controller.dart';
import 'components/service_card.dart';
import 'components/service_form_screen.dart';

class ServicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ServiceController());

    return Scaffold(
      appBar: AppBar(title: Text('Services')),
      body: Obx(
        () => controller.isLoading.value
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: controller.services.length,
                itemBuilder: (context, index) {
                  final service = controller.services[index];
                  return ServiceCard(service: service);
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => ServiceFormScreen()),
        child: Icon(Icons.add),
      ),
    );
  }
}
