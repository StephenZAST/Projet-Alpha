import express, { Router } from 'express';
import GeocodingController from '../controllers/geocoding.controller';

const router = Router();

/**
 * 🗺️ Routes de Géocodage
 * 
 * Ces routes remplacent les appels directs au frontend vers Nominatim
 * Avantages:
 * ✅ Pas d'erreur CORS (appel backend-to-backend)
 * ✅ Conversion DMS automatique
 * ✅ Validation côté serveur
 * ✅ Rate limiting et caching possibles
 */

/**
 * POST /api/geocoding/search
 * Rechercher une adresse ou convertir des coordonnées
 * 
 * Body: { query: "Paris" } ou { query: "12°22'54.2"N 1°27'45.9"W" }
 * 
 * Response: { success: true, results: [...], inputType: "address|dms|decimal" }
 */
router.post('/search', GeocodingController.searchAddress);

/**
 * POST /api/geocoding/reverse
 * Obtenir l'adresse à partir des coordonnées
 * 
 * Body: { latitude: 12.359364, longitude: -1.473508 }
 * 
 * Response: { success: true, result: { address, city, postalCode, ... } }
 */
router.post('/reverse', GeocodingController.reverseGeocode);

export default router;
