import 'package:admin/constants.dart';
import 'package:admin/controllers/service_type_controller.dart';
import 'package:admin/models/service_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

class ServiceTypeManagement extends GetView<ServiceTypeController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Types de Services', style: AppTextStyles.h3),
          SizedBox(height: AppSpacing.md),
          Obx(() => controller.isLoading.value
              ? CircularProgressIndicator()
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.serviceTypes.length,
                  itemBuilder: (context, index) {
                    final type = controller.serviceTypes[index];
                    return ListTile(
                      title: Text(type.name),
                      subtitle: type.description != null
                          ? Text(type.description!)
                          : null,
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showEditDialog(context, type),
                      ),
                    );
                  },
                )),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, ServiceType type) {
    // ...implementation du dialogue d'édition...
  }
}
