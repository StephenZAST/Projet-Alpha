import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';

class ErrorTrackingService {
  static final Logger _logger = Logger('GlobalKeyTracker');
  static final Map<String, int> _keyUsageCount = {};

  static void initialize() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      if (kDebugMode) {
        print('${record.level.name}: ${record.time}: ${record.message}');
        if (record.error != null) {
          print('Error: ${record.error}');
          print('Stack trace:\n${record.stackTrace}');
        }
      }
    });
  }

  static void trackGlobalKey(GlobalKey key, String widgetName) {
    final keyString = key.toString();
    _keyUsageCount[keyString] = (_keyUsageCount[keyString] ?? 0) + 1;

    if (_keyUsageCount[keyString]! > 1) {
      _logger.warning(
        'GlobalKey $keyString is used multiple times in $widgetName\n'
        'Current usage count: ${_keyUsageCount[keyString]}',
      );
    }
  }

  static void clearKeyTracking() {
    _keyUsageCount.clear();
  }

  // Ajouter cette méthode pour inspecter les clés
  static void dumpKeyUsage() {
    print('\n=== GlobalKey Usage Report ===');
    if (_keyUsageCount.isEmpty) {
      print('No GlobalKeys tracked yet');
    } else {
      _keyUsageCount.forEach((key, count) {
        print('Key: $key');
        print('Usage count: $count');
        print('------------------------');
      });
    }
    print('===========================\n');
  }

  // Méthode pour vérifier une clé spécifique
  static bool checkKey(GlobalKey key) {
    final keyString = key.toString();
    final count = _keyUsageCount[keyString] ?? 0;
    print('Key $keyString usage count: $count');
    return count <= 1;
  }
}
