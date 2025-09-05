import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'token_debug.dart';

class ApiTestHelper {
  static Future<void> testAffiliateAPIs() async {
    print('\n🧪 [ApiTestHelper] Testing Affiliate APIs...\n');
    
    // 1. Vérifier l'état du token
    TokenDebug.logTokenState('Before API Tests');
    
    final apiService = ApiService();
    
    try {
      // 2. Test de l'API publique (pas d'auth requise)
      print('📡 Testing public API: /api/affiliate/levels');
      final levelsResponse = await apiService.get('/affiliate/levels');
      print('✅ Levels API Status: ${levelsResponse.statusCode}');
      
      // 3. Test de l'API protégée (auth requise)
      print('\n📡 Testing protected API: /api/affiliate/admin/stats');
      final statsResponse = await apiService.get('/affiliate/admin/stats');
      print('✅ Stats API Status: ${statsResponse.statusCode}');
      
      // 4. Test de l'API de liste (auth requise)
      print('\n📡 Testing protected API: /api/affiliate/admin/list');
      final listResponse = await apiService.get('/affiliate/admin/list?page=1&limit=5');
      print('✅ List API Status: ${listResponse.statusCode}');
      
    } catch (e) {
      print('❌ API Test Error: $e');
    }
    
    print('\n🏁 API Tests completed\n');
  }
  
  static Future<void> testTokenValidity() async {
    print('\n🔐 [ApiTestHelper] Testing Token Validity...\n');
    
    final token = AuthService.token;
    if (token == null) {
      print('❌ No token found');
      return;
    }
    
    print('✅ Token found: ${token.substring(0, 20)}...');
    
    try {
      // Test avec une API simple qui nécessite l'auth
      final apiService = ApiService();
      final response = await apiService.get('/auth/admin/me');
      print('✅ Token validation Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ Token is valid');
      } else {
        print('❌ Token is invalid or expired');
      }
      
    } catch (e) {
      print('❌ Token validation error: $e');
    }
    
    print('\n🏁 Token validation completed\n');
  }
  
  static Future<void> compareWithWorkingAPI() async {
    print('\n🔄 [ApiTestHelper] Comparing with working Users API...\n');
    
    final apiService = ApiService();
    
    try {
      // Test de l'API Users qui fonctionne
      print('📡 Testing working API: /api/users/stats');
      final usersResponse = await apiService.get('/users/stats');
      print('✅ Users API Status: ${usersResponse.statusCode}');
      
      // Immédiatement après, test de l'API Affiliates
      print('\n📡 Testing affiliate API: /api/affiliate/admin/stats');
      final affiliateResponse = await apiService.get('/affiliate/admin/stats');
      print('✅ Affiliate API Status: ${affiliateResponse.statusCode}');
      
    } catch (e) {
      print('❌ Comparison test error: $e');
    }
    
    print('\n🏁 Comparison test completed\n');
  }
}