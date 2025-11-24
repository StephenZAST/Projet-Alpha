import { Request, Response } from 'express';
import axios from 'axios';

/**
 * 🗺️ Contrôleur de Géocodage - Nominatim Wrapper
 * 
 * Fournit une API proxy pour Nominatim qui :
 * ✅ Accepte les adresses texte
 * ✅ Convertit les coordonnées DMS en décimal
 * ✅ Élimine les erreurs CORS côté client
 * ✅ Ajoute de la validation
 */

interface GeocodingRequest {
  query: string; // Adresse, coordonnées décimales ou DMS
}

interface GeocodingResult {
  latitude: number;
  longitude: number;
  address: string;
  city?: string;
  postalCode?: string;
}

// ========================================================================
// 🔧 FONCTIONS UTILITAIRES (Module Level)
// ========================================================================

/**
 * 🔄 Convertir DMS en décimal
 * Input: "12°22'54.2"N 1°27'45.9"W"
 * Output: { lat: 12.359364, lng: -1.473508 }
 */
function convertDmsToDecimal(dmsString: string): { lat: number; lng: number } | null {
  try {
    // Regex pour parser DMS
    const dmsRegex = /(\d+)°\s*(\d+)?['′]?\s*(\d+\.?\d*)?[\"″]?\s*([NSEW])/gi;
    const matches = [...dmsString.matchAll(dmsRegex)];

    if (matches.length !== 2) {
      console.log('[Geocoding] ❌ DMS format invalide, matches:', matches.length);
      return null;
    }

    // Parser latitude (première coordonnée)
    const latMatch = matches[0];
    const latDegrees = parseInt(latMatch[1]);
    const latMinutes = parseInt(latMatch[2] || '0');
    const latSeconds = parseFloat(latMatch[3] || '0');
    const latDir = latMatch[4].toUpperCase();

    // Parser longitude (deuxième coordonnée)
    const lngMatch = matches[1];
    const lngDegrees = parseInt(lngMatch[1]);
    const lngMinutes = parseInt(lngMatch[2] || '0');
    const lngSeconds = parseFloat(lngMatch[3] || '0');
    const lngDir = lngMatch[4].toUpperCase();

    // Convertir en décimal
    let latitude = latDegrees + latMinutes / 60 + latSeconds / 3600;
    if (latDir === 'S') latitude = -latitude;

    let longitude = lngDegrees + lngMinutes / 60 + lngSeconds / 3600;
    if (lngDir === 'W') longitude = -longitude;

    // Valider les plages
    if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
      console.log('[Geocoding] ❌ Coordonnées hors limites:', { latitude, longitude });
      return null;
    }

    console.log('[Geocoding] ✅ DMS converti:', { latitude, longitude });
    return { lat: latitude, lng: longitude };
  } catch (e) {
    console.error('[Geocoding] ❌ Erreur conversion DMS:', e);
    return null;
  }
}

/**
 * 🔍 Parser les coordonnées décimales
 * Input: "12.359364, -1.473508" ou "12.359364,-1.473508"
 * Output: { lat: 12.359364, lng: -1.473508 }
 */
function parseDecimalCoordinates(input: string): { lat: number; lng: number } | null {
  try {
    const decimalRegex = /^(-?\d+\.?\d*)\s*[,;]\s*(-?\d+\.?\d*)$/;
    const match = decimalRegex.exec(input.trim());

    if (!match) {
      return null;
    }

    const latitude = parseFloat(match[1]);
    const longitude = parseFloat(match[2]);

    // Valider les plages
    if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
      return null;
    }

    console.log('[Geocoding] ✅ Coordonnées décimales parsées:', { latitude, longitude });
    return { lat: latitude, lng: longitude };
  } catch (e) {
    console.error('[Geocoding] ❌ Erreur parsing décimal:', e);
    return null;
  }
}

/**
 * 🔍 Détecter le type d'entrée
 */
function detectInputType(input: string): 'dms' | 'decimal' | 'address' {
  if (input.includes('°')) {
    return 'dms';
  }
  if (/^-?\d+\.?\d*\s*[,;]\s*-?\d+\.?\d*$/.test(input.trim())) {
    return 'decimal';
  }
  return 'address';
}

// ========================================================================
// 🎯 CONTRÔLEUR
// ========================================================================

class GeocodingController {
  /**
   * 📍 Endpoint principal : Géocoder une adresse ou coordonnées
   * 
   * POST /api/geocoding/search
   * Body: { query: "Paris" } ou { query: "12°22'54.2"N 1°27'45.9"W" }
   */
  static async searchAddress(req: Request, res: Response) {
    try {
      const { query } = req.body as GeocodingRequest;

      if (!query || typeof query !== 'string' || query.trim().length === 0) {
        return res.status(400).json({
          error: 'Query parameter is required',
          message: 'Veuillez fournir une adresse ou des coordonnées'
        });
      }

      const trimmedQuery = query.trim();
      const inputType = detectInputType(trimmedQuery);

      console.log(`[GeocodingController] 🔍 Type détecté: ${inputType}, Query: ${trimmedQuery}`);

      let coordinates: { lat: number; lng: number } | null = null;
      let searchQuery = trimmedQuery;

      // 1️⃣ Si coordonnées, les convertir en décimal
      if (inputType === 'dms') {
        coordinates = convertDmsToDecimal(trimmedQuery);
        if (!coordinates) {
          return res.status(400).json({
            error: 'Invalid DMS format',
            message: 'Format DMS invalide. Utilisez: 12°22\'54.2"N 1°27\'45.9"W'
          });
        }
        // Convertir en format de recherche Nominatim
        searchQuery = `${coordinates.lat},${coordinates.lng}`;
      } else if (inputType === 'decimal') {
        coordinates = parseDecimalCoordinates(trimmedQuery);
        if (!coordinates) {
          return res.status(400).json({
            error: 'Invalid decimal coordinates',
            message: 'Coordonnées décimales invalides'
          });
        }
        // Garder le format pour la recherche inverse
        searchQuery = `${coordinates.lat},${coordinates.lng}`;
      }

      // 2️⃣ Appeler Nominatim (côté backend = PAS d'erreur CORS)
      console.log(`[GeocodingController] 📤 Appel Nominatim avec: ${searchQuery}`);

      const nominatimUrl = 'https://nominatim.openstreetmap.org/search';
      const response = await axios.get(nominatimUrl, {
        params: {
          q: searchQuery,
          format: 'json',
          limit: 5,
          addressdetails: 1,
          countrycodes: 'fr', // Limiter à France
          'accept-language': 'fr'
        },
        headers: {
          'User-Agent': 'AlphaPressing/1.0 (https://alphapressing.com)'
        },
        timeout: 10000 // 10 secondes timeout
      });

      if (!response.data || response.data.length === 0) {
        return res.status(404).json({
          error: 'No results found',
          message: 'Aucun résultat trouvé pour cette recherche'
        });
      }

      // 3️⃣ Transformer les résultats
      const results = response.data.map((result: any) => ({
        latitude: parseFloat(result.lat),
        longitude: parseFloat(result.lon),
        address: result.display_name,
        city: result.address?.city || result.address?.town || null,
        postalCode: result.address?.postcode || null
      }));

      console.log(`[GeocodingController] ✅ Résultats trouvés: ${results.length}`);

      return res.status(200).json({
        success: true,
        count: results.length,
        results,
        inputType // Informer le client du type détecté
      });
    } catch (error: any) {
      console.error('[GeocodingController] ❌ Erreur:', error.message);

      if (error.response?.status === 403) {
        return res.status(503).json({
          error: 'Nominatim service unavailable',
          message: 'Service de géolocalisation temporairement indisponible'
        });
      }

      return res.status(500).json({
        error: 'Internal server error',
        message: error.message || 'Erreur lors de la recherche'
      });
    }
  }

  /**
   * 📍 Endpoint de géocodage inverse
   * Convertir des coordonnées en adresse
   * 
   * POST /api/geocoding/reverse
   * Body: { latitude: 12.359364, longitude: -1.473508 }
   */
  static async reverseGeocode(req: Request, res: Response) {
    try {
      const { latitude, longitude } = req.body;

      if (latitude === undefined || longitude === undefined) {
        return res.status(400).json({
          error: 'Missing coordinates',
          message: 'Veuillez fournir latitude et longitude'
        });
      }

      if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
        return res.status(400).json({
          error: 'Invalid coordinates',
          message: 'Coordonnées invalides'
        });
      }

      console.log(`[GeocodingController] 🔄 Géocodage inverse: ${latitude}, ${longitude}`);

      const nominatimUrl = 'https://nominatim.openstreetmap.org/reverse';
      const response = await axios.get(nominatimUrl, {
        params: {
          lat: latitude,
          lon: longitude,
          format: 'json',
          addressdetails: 1,
          'accept-language': 'fr'
        },
        headers: {
          'User-Agent': 'AlphaPressing/1.0'
        },
        timeout: 10000
      });

      const result = {
        latitude,
        longitude,
        address: response.data.display_name,
        city: response.data.address?.city || response.data.address?.town || null,
        postalCode: response.data.address?.postcode || null
      };

      console.log(`[GeocodingController] ✅ Adresse trouvée: ${result.address}`);

      return res.status(200).json({
        success: true,
        result
      });
    } catch (error: any) {
      console.error('[GeocodingController] ❌ Erreur géocodage inverse:', error.message);

      return res.status(500).json({
        error: 'Internal server error',
        message: error.message
      });
    }
  }
}

export default GeocodingController;
