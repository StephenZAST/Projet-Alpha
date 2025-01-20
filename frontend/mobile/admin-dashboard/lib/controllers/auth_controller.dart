import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;
  final user = Rxn<User>();

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      final response = await ApiService.post(
          'auth/login', {'email': email, 'password': password});

      final token = response['data']['token'];
      GetStorage().write('token', token);

      user.value = User.fromJson(response['data']['user']);
      Get.offAllNamed('/dashboard');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    isLoading.value = false;
    user.value = null;
    Get.offAllNamed('/login');
  }
}
