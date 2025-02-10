import 'dart:io';
import 'package:dio/dio.dart' as dio;
import '../models/admin_profile.dart';
import './api_service.dart';

class AdminProfileService {
  static final _api = ApiService();
  static const _baseUrl = '/api/admin/profile';

  static Future<AdminProfile> getProfile() async {
    try {
      final response = await _api.get(_baseUrl);

      if (response.data == null || !response.data['success']) {
        throw 'Erreur lors de la récupération du profil';
      }

      return AdminProfile.fromJson(response.data['data']);
    } catch (e) {
      print('[AdminProfileService] Error getting profile: $e');
      throw 'Erreur lors de la récupération du profil';
    }
  }

  static Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _api.put(_baseUrl, data: data);

      if (!response.data['success']) {
        throw response.data['message'] ?? 'Erreur lors de la mise à jour';
      }
    } catch (e) {
      print('[AdminProfileService] Error updating profile: $e');
      throw 'Erreur lors de la mise à jour du profil';
    }
  }

  static Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _api.post(
        '$_baseUrl/password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      if (!response.data['success']) {
        throw response.data['message'] ??
            'Erreur lors du changement de mot de passe';
      }
    } catch (e) {
      print('[AdminProfileService] Error updating password: $e');
      throw 'Erreur lors du changement de mot de passe';
    }
  }

  static Future<String> uploadProfileImage(File image) async {
    try {
      final formData = dio.FormData.fromMap({
        'image': await dio.MultipartFile.fromFile(image.path),
      });

      final response = await _api.post(
        '$_baseUrl/image',
        data: formData,
      );

      if (!response.data['success']) {
        throw response.data['message'] ?? 'Erreur lors du téléchargement';
      }

      return response.data['data']['imageUrl'];
    } catch (e) {
      print('[AdminProfileService] Error uploading image: $e');
      throw 'Erreur lors du téléchargement de l\'image';
    }
  }
}
