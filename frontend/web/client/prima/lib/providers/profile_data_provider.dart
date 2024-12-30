abstract class ProfileDataProvider {
  Future<Map<String, dynamic>> getProfile();
  Future<void> updateProfile(Map<String, dynamic> profile);
}