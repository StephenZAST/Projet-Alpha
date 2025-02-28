import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/users_controller.dart';

class ViewToggle extends StatelessWidget {
  const ViewToggle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();

    return Obx(() => SegmentedButton<ViewMode>(
          segments: const [
            ButtonSegment(
              value: ViewMode.list,
              icon: Icon(Icons.list),
              label: Text('Liste'),
            ),
            ButtonSegment(
              value: ViewMode.grid,
              icon: Icon(Icons.grid_view),
              label: Text('Grille'),
            ),
          ],
          selected: {controller.viewMode.value},
          onSelectionChanged: (Set<ViewMode> modes) {
            if (modes.isNotEmpty) {
              controller.viewMode.value = modes.first;
            }
          },
        ));
  }
}
