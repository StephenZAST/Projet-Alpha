import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/offer_service.dart';

class DebugHelper {
  static void logOfferUpdateFlow(String step, dynamic data) {
    print('🔍 [OFFER_UPDATE_DEBUG] $step');
    if (data != null) {
      if (data is Map || data is List) {
        print('📊 Data: ${JsonEncoder.withIndent('  ').convert(data)}');
      } else {
        print('📊 Data: $data');
      }
    }
    print('─' * 50);
  }

  static Future<void> testOfferUpdateFlow() async {
    try {
      logOfferUpdateFlow('DÉBUT DU TEST', null);

      // 1. Test de connectivité de base
      logOfferUpdateFlow('1. Test de connectivité avec OfferService', null);

      // 2. Récupération des offres
      logOfferUpdateFlow('2. Récupération des offres', null);
      final offers = await OfferService.getAllOffersAsMap();
      logOfferUpdateFlow(
          '2. Offres récupérées', {'count': offers.length, 'offers': offers});

      if (offers.isEmpty) {
        logOfferUpdateFlow('ERREUR', 'Aucune offre trouvée pour le test');
        return;
      }

      final firstOffer = offers.first;
      logOfferUpdateFlow('3. Offre sélectionnée pour test', firstOffer);

      // 3. Préparation des données de test
      final testData = {
        'name': 'Test Update - ${DateTime.now().millisecondsSinceEpoch}',
        'description': 'Description mise à jour par le test de debug',
        'discountType': 'PERCENTAGE',
        'discountValue': 15.0,
        'isCumulative': true,
        'startDate': DateTime.now().toIso8601String(),
        'endDate': DateTime.now().add(Duration(days: 30)).toIso8601String(),
        'isActive': true,
      };

      logOfferUpdateFlow('4. Données de test préparées', testData);

      // 4. Test de mise à jour
      logOfferUpdateFlow('5. Envoi de la requête PATCH via OfferService', null);
      final result = await OfferService.updateOfferFromMap(firstOffer['id'], testData);

      if (result != null) {
        logOfferUpdateFlow('✅ SUCCÈS - Mise à jour réussie', result);

        // Afficher un snackbar de succès
        Get.rawSnackbar(
          title: '✅ Test Debug Réussi',
          message: 'La mise à jour d\'offre fonctionne correctement',
          backgroundColor: Get.theme.colorScheme.primary,
          duration: Duration(seconds: 3),
        );
      } else {
        logOfferUpdateFlow('❌ ÉCHEC - Mise à jour échouée', 'Result is null');

        Get.rawSnackbar(
          title: '❌ Test Debug Échoué',
          message: 'La mise à jour d\'offre a échoué',
          backgroundColor: Get.theme.colorScheme.error,
          duration: Duration(seconds: 3),
        );
      }
    } catch (e, stackTrace) {
      logOfferUpdateFlow('❌ EXCEPTION',
          {'error': e.toString(), 'stackTrace': stackTrace.toString()});

      Get.rawSnackbar(
        title: '❌ Erreur Debug',
        message: 'Exception: ${e.toString()}',
        backgroundColor: Get.theme.colorScheme.error,
        duration: Duration(seconds: 5),
      );
    }
  }

  static void logApiRequest(String method, String url, dynamic data) {
    print('🌐 [API_REQUEST] $method $url');
    if (data != null) {
      print('📤 Request Data: ${JsonEncoder.withIndent('  ').convert(data)}');
    }
  }

  static void logApiResponse(
      String method, String url, int statusCode, dynamic data) {
    print('🌐 [API_RESPONSE] $method $url - Status: $statusCode');
    if (data != null) {
      print('📥 Response Data: ${JsonEncoder.withIndent('  ').convert(data)}');
    }
  }

  static void showDebugInfo() {
    final info = {
      'API Base URL': ApiService.baseUrl,
      'Token Present': ApiService.getToken() != null,
      'Token Preview': ApiService.getToken()?.substring(0, 20) ?? 'None',
      'Current Route': Get.currentRoute,
      'Platform': GetPlatform.isAndroid
          ? 'Android'
          : GetPlatform.isIOS
              ? 'iOS'
              : 'Other',
    };

    Get.dialog(
      AlertDialog(
        title: Text('🔍 Debug Info'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: info.entries
                .map((entry) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text('${entry.key}: ${entry.value}'),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Fermer'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              testOfferUpdateFlow();
            },
            child: Text('Tester API'),
          ),
        ],
      ),
    );
  }
}
