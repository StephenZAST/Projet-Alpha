import 'package:admin/controllers/service_type_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

class ServiceTypeSelector extends GetView<ServiceTypeController> {
  final String? value;
  final Function(String?) onChanged;

  const ServiceTypeSelector({
    Key? key,
    this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const CircularProgressIndicator();
      }

      return DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: 'Type de service',
          border: OutlineInputBorder(),
        ),
        items: controller.serviceTypes.map((type) {
          return DropdownMenuItem(
            value: type.id,
            child: Text(type.name),
          );
        }).toList(),
        onChanged: onChanged,
      );
    });
  }
}
