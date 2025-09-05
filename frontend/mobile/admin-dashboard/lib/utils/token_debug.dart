import 'package:get_storage/get_storage.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class TokenDebug {
  static void logTokenState(String context) {
    final storage = GetStorage();
    final tokenFromStorage = storage.read('token');
    final tokenFromApiService = ApiService.getToken();
    final tokenFromAuthService = AuthService.token;
    final currentUser = AuthService.currentUser;
    
    print('\n🔍 [TokenDebug] Context: $context');
    print('📦 Token from Storage: ${tokenFromStorage != null ? tokenFromStorage.toString().substring(0, 20) + '...' : 'NULL'}');
    print('🌐 Token from ApiService: ${tokenFromApiService != null ? tokenFromApiService.substring(0, 20) + '...' : 'NULL'}');
    print('🔐 Token from AuthService: ${tokenFromAuthService != null ? tokenFromAuthService.substring(0, 20) + '...' : 'NULL'}');
    print('👤 Current User: ${currentUser?.email ?? 'NULL'}');
    print('🔄 Tokens Match: ${tokenFromStorage == tokenFromApiService && tokenFromApiService == tokenFromAuthService}');
    print('---\n');
  }
  
  static void logStorageContents() {
    final storage = GetStorage();
    final keys = storage.getKeys();
    
    print('\n📦 [TokenDebug] Storage Contents:');
    for (final key in keys) {
      final value = storage.read(key);
      if (key == 'token') {
        print('🔑 $key: ${value != null ? value.toString().substring(0, 20) + '...' : 'NULL'}');
      } else if (key == 'user') {
        print('👤 $key: ${value != null ? 'USER_DATA_PRESENT' : 'NULL'}');
      } else {
        print('📄 $key: $value');
      }
    }
    print('---\n');
  }
}