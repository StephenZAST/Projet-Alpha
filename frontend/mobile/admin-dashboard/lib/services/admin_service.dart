import '../models/admin.dart';

class AdminService {
  static Future<Admin> updateProfile(AdminUpdateDTO dto) async {
    // TODO: Implement API call
    return Admin(
      id: '1',
      name: dto.name,
      email: dto.email,
      profilePicture: dto.profilePicture,
    );
  }
}
