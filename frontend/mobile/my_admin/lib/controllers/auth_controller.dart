import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final user = Rxn<User>();
  final isLoading = false.obs;
  final storage = GetStorage();

  bool get isAuthenticated => user.value != null;

  @override
  void onInit() {
    super.onInit();
    checkAuth();
  }

  Future<void> checkAuth() async {
    isLoading.value = true;
    try {
      final token = storage.read('token');
      if (token != null && !isTokenExpired()) {
        final userData = await AuthService.getCurrentUser();
        user.value = userData;
      }
    } catch (e) {
      logout();
    } finally {
      isLoading.value = false;
    }
  }

  bool isTokenExpired() {
    final expiry = storage.read('tokenExpiry');
    if (expiry == null) return true;
    return DateTime.parse(expiry).isBefore(DateTime.now());
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      final response = await AuthService.login(email, password);
      storage.write('token', response['token']);
      storage.write('tokenExpiry', response['expiry']);
      user.value = User.fromJson(response['user']);
      Get.offAllNamed('/dashboard');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    storage.remove('token');
    storage.remove('tokenExpiry');
    user.value = null;
    Get.offAllNamed('/login');
  }
}
