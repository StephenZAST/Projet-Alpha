import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../constants.dart';
import '../../../../controllers/orders_controller.dart';

class DateSelection extends StatelessWidget {
  final controller = Get.find<OrdersController>();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dates', style: AppTextStyles.h3),
            SizedBox(height: AppSpacing.md),

            // Date de collecte
            ListTile(
              title: Text('Date de collecte'),
              subtitle: Obx(() => Text(
                    controller.collectionDate.value != null
                        ? DateFormat('dd/MM/yyyy HH:mm')
                            .format(controller.collectionDate.value!)
                        : 'Non définie',
                  )),
              trailing: IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () => _selectDate(
                  context,
                  isCollection: true,
                ),
              ),
            ),

            Divider(),

            // Date de livraison
            ListTile(
              title: Text('Date de livraison'),
              subtitle: Obx(() => Text(
                    controller.deliveryDate.value != null
                        ? DateFormat('dd/MM/yyyy HH:mm')
                            .format(controller.deliveryDate.value!)
                        : 'Non définie',
                  )),
              trailing: IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () => _selectDate(
                  context,
                  isCollection: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<DateTime?> _selectDate(BuildContext context,
      {required bool isCollection}) async {
    // 1. Sélection de la date
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );

    if (date == null) return null;

    // 2. Sélection de l'heure
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return null;

    // 3. Combiner date et heure
    final DateTime dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    // 4. Mettre à jour le controller
    if (isCollection) {
      controller.collectionDate.value = dateTime;
    } else {
      controller.deliveryDate.value = dateTime;
    }

    return dateTime;
  }
}
