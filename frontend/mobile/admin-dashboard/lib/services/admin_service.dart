import '../models/admin.dart';
import 'api_service.dart';

class AdminService {
  static Future<Admin> updateProfile(AdminUpdateDTO dto) async {
    final response = await ApiService.post('admin/profile', dto.toJson());
    return Admin.fromJson(response['data']);
  }
}
