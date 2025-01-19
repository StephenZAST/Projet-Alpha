import 'package:get/get.dart';
import '../models/user.dart';

class AuthController extends GetxController {
  final isAuthenticated = false.obs;
  final user = Rxn<User>();

  Future<void> loginAdmin(String email, String password) async {
    try {
      // TODO: Implement API call
      // Simulate successful login
      user.value = User(email: email, name: "Admin");
      isAuthenticated.value = true;
      Get.offAllNamed('/dashboard');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void logout() {
    isAuthenticated.value = false;
    user.value = null;
    Get.offAllNamed('/login');
  }
}
