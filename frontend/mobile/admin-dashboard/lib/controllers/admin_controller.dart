import 'package:get/get.dart';
import '../models/admin.dart';
import '../services/admin_service.dart';

class AdminController extends GetxController {
  final admin = Rxn<Admin>();
  final isLoading = false.obs;

  Future<void> updateProfile(AdminUpdateDTO dto) async {
    isLoading.value = true;
    try {
      final updated = await AdminService.updateProfile(dto);
      admin.value = updated;
      Get.snackbar('Success', 'Profile updated');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
