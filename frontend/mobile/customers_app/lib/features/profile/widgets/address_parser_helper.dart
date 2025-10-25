import 'package:flutter/material.dart';

/// 📍 Structure pour stocker les composants d'une adresse parsée
class ParsedAddress {
  final String street;
  final String city;
  final String postalCode;

  ParsedAddress({
    required this.street,
    required this.city,
    required this.postalCode,
  });

  @override
  String toString() => 'ParsedAddress(street: $street, city: $city, postalCode: $postalCode)';
}

/// 🔍 Helper pour Parser et Remplir les Champs d'Adresse - Alpha Client App
///
/// Utilitaire pour extraire intelligemment les composants d'une adresse
/// fournie par la carte et pré-remplir les champs du formulaire.
class AddressParserHelper {
  /// 🔍 Parser une adresse complète et extraire ses composants
  /// 
  /// Format attendu: "Rue, Ville, Code Postal, Pays" ou "Quartier, Ville, Code Postal, Pays"
  /// 
  /// Exemple:
  /// - Input: "Silmissin, Ouagadougou, 01000, Burkina Faso"
  /// - Output: ParsedAddress(street: "Silmissin", city: "Ouagadougou", postalCode: "01000")
  static ParsedAddress parseAddress(String fullAddress) {
    if (fullAddress.isEmpty) {
      return ParsedAddress(street: '', city: '', postalCode: '');
    }

    // Diviser l'adresse par les virgules
    final parts = fullAddress.split(',').map((p) => p.trim()).toList();

    String street = '';
    String city = '';
    String postalCode = '';

    if (parts.length >= 2) {
      // Première partie = rue/quartier
      street = parts[0];
      
      // Deuxième partie = ville
      city = parts[1];
      
      // Troisième partie = code postal (si disponible)
      if (parts.length >= 3) {
        // Vérifier si c'est un code postal (généralement numérique)
        final thirdPart = parts[2];
        if (RegExp(r'^\d+$').hasMatch(thirdPart)) {
          postalCode = thirdPart;
        } else {
          // Si ce n'est pas un code postal, c'est peut-être une région
          city = '$city, ${parts[2]}';
        }
      }
    } else if (parts.length == 1) {
      // Si une seule partie, l'utiliser comme rue
      street = parts[0];
    }

    return ParsedAddress(
      street: street,
      city: city,
      postalCode: postalCode,
    );
  }

  /// ��� Pré-remplir les champs du formulaire avec l'adresse parsée
  /// 
  /// Remplit SEULEMENT les champs vides pour respecter les modifications utilisateur
  static void fillAddressFields({
    required TextEditingController streetController,
    required TextEditingController cityController,
    required TextEditingController postalCodeController,
    required ParsedAddress parsedAddress,
  }) {
    if (streetController.text.isEmpty && parsedAddress.street.isNotEmpty) {
      streetController.text = parsedAddress.street;
    }
    
    if (cityController.text.isEmpty && parsedAddress.city.isNotEmpty) {
      cityController.text = parsedAddress.city;
    }
    
    if (postalCodeController.text.isEmpty && parsedAddress.postalCode.isNotEmpty) {
      postalCodeController.text = parsedAddress.postalCode;
    }
  }

  /// 🔄 Pré-remplir directement depuis une adresse complète
  /// 
  /// Combine le parsing et le remplissage en une seule opération
  static ParsedAddress parseAndFillAddressFields({
    required String fullAddress,
    required TextEditingController streetController,
    required TextEditingController cityController,
    required TextEditingController postalCodeController,
  }) {
    final parsedAddress = parseAddress(fullAddress);
    fillAddressFields(
      streetController: streetController,
      cityController: cityController,
      postalCodeController: postalCodeController,
      parsedAddress: parsedAddress,
    );
    
    _logParsedAddress(parsedAddress);
    
    return parsedAddress;
  }

  /// 📊 Logger les détails du parsing (pour débogage)
  static void _logParsedAddress(ParsedAddress parsedAddress) {
    print('[AddressParserHelper] Parsed address:');
    print('  Street: ${parsedAddress.street}');
    print('  City: ${parsedAddress.city}');
    print('  PostalCode: ${parsedAddress.postalCode}');
  }
}
