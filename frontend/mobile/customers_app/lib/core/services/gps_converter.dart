/// 🔄 Convertisseur GPS Minimaliste
///
/// Convertit les coordonnées DMS en décimal
/// Formats acceptés:
/// ✅ Décimal: 12.359364, -1.473508
/// ✅ DMS: 12°22'54.2"N 1°27'45.9"W
class GpsConverter {
  /// 🔍 Détecter si c'est une coordonnée GPS
  static bool isGpsCoordinate(String input) {
    if (input.trim().isEmpty) return false;
    final trimmed = input.trim();

    // Format décimal: nombre, nombre
    if (RegExp(r'^-?\d+\.?\d*\s*[,;]\s*-?\d+\.?\d*$').hasMatch(trimmed)) {
      return true;
    }

    // Format DMS: contient ° et [NSEW]
    if (trimmed.contains('°') &&
        (trimmed.contains('N') ||
            trimmed.contains('S') ||
            trimmed.contains('E') ||
            trimmed.contains('W'))) {
      return true;
    }

    return false;
  }

  /// 🔄 Convertir en format décimal normalisé
  ///
  /// Entrée peut être:
  /// - "12.359364, -1.473508" → sortie: "12.359364,-1.473508"
  /// - "12°22'54.2"N 1°27'45.9"W" → sortie: "12.359364,-1.473508"
  static String? toDecimalFormat(String input) {
    if (input.trim().isEmpty) return null;

    final trimmed = input.trim();

    // 1️⃣ Si déjà décimal, normaliser
    final decimalMatch =
        RegExp(r'^(-?\d+\.?\d*)\s*[,;]\s*(-?\d+\.?\d*)$').firstMatch(trimmed);
    if (decimalMatch != null) {
      final lat = decimalMatch.group(1);
      final lng = decimalMatch.group(2);
      return '$lat,$lng'; // Format normalisé: lat,lng
    }

    // 2️⃣ Si DMS, convertir en décimal
    if (trimmed.contains('°')) {
      return _convertDmsToDecimal(trimmed);
    }

    return null;
  }

  /// 🔧 Convertir DMS en décimal
  /// Format: 12°22'54.2"N 1°27'45.9"W
  static String? _convertDmsToDecimal(String dmsString) {
    try {
      // Parser DMS: degrés°minutes'secondes"direction
      // Pattern: degrés°minutes'secondes"direction
      final dmsRegex = RegExp(
        '(\\d+)°\\s*(\\d+)?[\'\\u2032]?\\s*(\\d+\\.?\\d*)?[\"\\u2033]?\\s*([NSEW])',
        caseSensitive: false,
      );

      final matches = dmsRegex.allMatches(dmsString).toList();

      // Doit avoir exactement 2 coordonnées (lat et lng)
      if (matches.length != 2) {
        print('[GpsConverter] ❌ DMS invalide: $dmsString');
        return null;
      }

      // Parser latitude
      final latMatch = matches[0];
      final latDegrees = int.parse(latMatch.group(1)!);
      final latMinutes = int.tryParse(latMatch.group(2) ?? '0') ?? 0;
      final latSeconds = double.tryParse(latMatch.group(3) ?? '0') ?? 0;
      final latDir = latMatch.group(4)!.toUpperCase();

      // Parser longitude
      final lngMatch = matches[1];
      final lngDegrees = int.parse(lngMatch.group(1)!);
      final lngMinutes = int.tryParse(lngMatch.group(2) ?? '0') ?? 0;
      final lngSeconds = double.tryParse(lngMatch.group(3) ?? '0') ?? 0;
      final lngDir = lngMatch.group(4)!.toUpperCase();

      // Convertir en décimal
      double latitude = latDegrees + (latMinutes / 60) + (latSeconds / 3600);
      if (latDir == 'S') latitude = -latitude;

      double longitude = lngDegrees + (lngMinutes / 60) + (lngSeconds / 3600);
      if (lngDir == 'W') longitude = -longitude;

      // Valider les plages
      if (latitude < -90 ||
          latitude > 90 ||
          longitude < -180 ||
          longitude > 180) {
        print(
            '[GpsConverter] ❌ Coordonnées hors limites: $latitude, $longitude');
        return null;
      }

      print(
          '[GpsConverter] ✅ DMS converti: ${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}');
      return '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}';
    } catch (e) {
      print('[GpsConverter] ❌ Erreur conversion DMS: $e');
      return null;
    }
  }
}
