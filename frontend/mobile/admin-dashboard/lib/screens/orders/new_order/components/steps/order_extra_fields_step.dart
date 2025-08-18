import 'package:flutter/material.dart';
import 'package:admin/models/enums.dart';
import 'package:admin/constants.dart';
import 'package:get/get.dart';
import '../../../../../../controllers/orders_controller.dart';

class OrderExtraFieldsStep extends StatelessWidget {
  final OrdersController controller = Get.find<OrdersController>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Date de collecte
          Obx(() => ListTile(
                title: Text('Date de collecte'),
                subtitle: Text(
                    controller.orderDraft.value.collectionDate != null
                        ? controller.orderDraft.value.collectionDate!
                            .toLocal()
                            .toString()
                            .split(' ')[0]
                        : 'Non définie'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: controller.orderDraft.value.collectionDate ??
                        DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    controller.setOrderDraftField('collectionDate', picked);
                  }
                },
              )),
          // Date de livraison
          Obx(() => ListTile(
                title: Text('Date de livraison'),
                subtitle: Text(controller.orderDraft.value.deliveryDate != null
                    ? controller.orderDraft.value.deliveryDate!
                        .toLocal()
                        .toString()
                        .split(' ')[0]
                    : 'Non définie'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: controller.orderDraft.value.deliveryDate ??
                        DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    controller.setOrderDraftField('deliveryDate', picked);
                  }
                },
              )),
          // Statut (avec icône/couleur)
          Obx(() => DropdownButtonFormField<OrderStatus>(
                value: controller.orderDraft.value.status != null
                    ? OrderStatus.values.firstWhereOrNull(
                        (s) => s.name == controller.orderDraft.value.status)
                    : OrderStatus.PENDING,
                decoration: InputDecoration(labelText: 'Statut'),
                items: OrderStatus.values.map((status) {
                  return DropdownMenuItem<OrderStatus>(
                    value: status,
                    child: Row(
                      children: [
                        Icon(status.icon, color: status.color, size: 20),
                        SizedBox(width: 8),
                        Text(status.label,
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (OrderStatus? newStatus) {
                  if (newStatus != null) {
                    controller.setOrderDraftField('status', newStatus.name);
                  }
                },
              )),
          // Méthode de paiement
          Obx(() => DropdownButtonFormField<PaymentMethod>(
                value: controller.orderDraft.value.paymentMethod != null
                    ? PaymentMethod.values.firstWhereOrNull((m) =>
                        m.name == controller.orderDraft.value.paymentMethod)
                    : PaymentMethod.CASH,
                decoration: InputDecoration(labelText: 'Méthode de paiement'),
                items: PaymentMethod.values
                    .map((method) => DropdownMenuItem<PaymentMethod>(
                          value: method,
                          child: Text(method.label),
                        ))
                    .toList(),
                onChanged: (PaymentMethod? newMethod) {
                  if (newMethod != null) {
                    controller.setOrderDraftField(
                        'paymentMethod', newMethod.name);
                  }
                },
              )),
          // Code affilié
          TextFormField(
            initialValue: controller.orderDraft.value.affiliateCode ?? '',
            decoration: InputDecoration(labelText: 'Code affilié'),
            onChanged: (v) => controller.setOrderDraftField('affiliateCode', v),
          ),
          // Type de récurrence (chips glassy)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Obx(() {
              final selected =
                  controller.orderDraft.value.recurrenceType ?? 'NONE';
              final types = [
                {'value': 'NONE', 'label': 'Jamais'},
                {'value': 'WEEKLY', 'label': 'Hebdo'},
                {'value': 'BIWEEKLY', 'label': '2 semaines'},
                {'value': 'MONTHLY', 'label': 'Mensuel'},
              ];
              return Wrap(
                spacing: 8,
                children: types.map((type) {
                  final isSelected = selected == type['value'];
                  Color color;
                  switch (type['value']) {
                    case 'WEEKLY':
                      color = AppColors.info;
                      break;
                    case 'BIWEEKLY':
                      color = AppColors.violet;
                      break;
                    case 'MONTHLY':
                      color = AppColors.orange;
                      break;
                    default:
                      color = AppColors.gray400;
                  }
                  return ChoiceChip(
                    label: Text(type['label']!,
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    selected: isSelected,
                    selectedColor: color.withOpacity(0.8),
                    backgroundColor: color.withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                          color: isSelected ? color : color.withOpacity(0.4)),
                    ),
                    onSelected: (selectedChip) {
                      if (selectedChip) {
                        controller.setOrderDraftField(
                            'recurrenceType', type['value']);
                        // Calcul automatique de la prochaine date de récurrence
                        final collectionDate =
                            controller.orderDraft.value.collectionDate;
                        if (type['value'] != 'NONE' && collectionDate != null) {
                          DateTime next;
                          if (type['value'] == 'WEEKLY') {
                            next = collectionDate.add(Duration(days: 7));
                          } else if (type['value'] == 'BIWEEKLY') {
                            next = collectionDate.add(Duration(days: 14));
                          } else if (type['value'] == 'MONTHLY') {
                            next = DateTime(collectionDate.year,
                                collectionDate.month + 1, collectionDate.day);
                          } else {
                            next = collectionDate;
                          }
                          controller.setOrderDraftField(
                              'nextRecurrenceDate', next);
                        } else {
                          controller.setOrderDraftField(
                              'nextRecurrenceDate', null);
                        }
                      }
                    },
                  );
                }).toList(),
              );
            }),
          ),
          // Prochaine date de récurrence (affichage seulement)
          Obx(() {
            final recurrence = controller.orderDraft.value.recurrenceType;
            final nextDate = controller.orderDraft.value.nextRecurrenceDate;
            if (recurrence == null || recurrence == 'NONE')
              return SizedBox.shrink();
            return ListTile(
              title: Text('Prochaine date de récurrence'),
              subtitle: Text(nextDate != null
                  ? nextDate.toLocal().toString().split(' ')[0]
                  : 'Non définie'),
              leading: Icon(Icons.repeat, color: AppColors.info),
            );
          }),
        ],
      ),
    );
  }
}
