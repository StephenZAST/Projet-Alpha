import 'package:get/get.dart';

class DashboardController extends GetxController {
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      // TODO: Implement data fetching logic
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }
}
