import 'package:admin/controllers/flash_order_stepper_controller.dart';
import 'package:flutter/material.dart';

class FlashExtraFieldsStep extends StatelessWidget {
  final FlashOrderStepperController controller;
  const FlashExtraFieldsStep({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final draft = controller.draft.value;
    final now = DateTime.now();
    if (draft.collectionDate == null) {
      controller.setDraftField('collectionDate', now.add(Duration(days: 1)));
    }
    if (draft.deliveryDate == null) {
      final collect = draft.collectionDate ?? now.add(Duration(days: 1));
      controller.setDraftField('deliveryDate', collect.add(Duration(days: 3)));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          title: Text('Date de collecte'),
          subtitle: Text(draft.collectionDate != null
              ? draft.collectionDate!.toLocal().toString().split(' ')[0]
              : 'Non définie'),
          trailing: Icon(Icons.calendar_today),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: draft.collectionDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              controller.setDraftField('collectionDate', picked);
            }
          },
        ),
        ListTile(
          title: Text('Date de livraison'),
          subtitle: Text(draft.deliveryDate != null
              ? draft.deliveryDate!.toLocal().toString().split(' ')[0]
              : 'Non définie'),
          trailing: Icon(Icons.calendar_today),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: draft.deliveryDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              controller.setDraftField('deliveryDate', picked);
            }
          },
        ),
        TextFormField(
          initialValue: draft.note ?? '',
          decoration: InputDecoration(labelText: 'Note de commande'),
          minLines: 2,
          maxLines: 5,
          onChanged: (v) => controller.setDraftField('note', v),
        ),
        // Ajouter d'autres champs extra si besoin
      ],
    );
  }
}
