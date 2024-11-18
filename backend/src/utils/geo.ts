import { GeoPoint } from 'firebase-admin/firestore';
import * as geohash from 'ngeohash';

export interface GeoLocation {
  latitude: number;
  longitude: number;
  geohash?: string;
}

export interface GeoBounds {
  center: GeoLocation;
  radiusKm: number;
}

// Calculate geohash for a location
export function generateGeohash(location: GeoLocation): string {
  return geohash.encode(location.latitude, location.longitude, 9); // 9 is precision level
}

// Calculate distance between two points in kilometers using Haversine formula
export function calculateDistance(point1: GeoLocation, point2: GeoLocation): number {
  const R = 6371; // Earth's radius in kilometers
  const lat1 = toRadians(point1.latitude);
  const lat2 = toRadians(point2.latitude);
  const deltaLat = toRadians(point2.latitude - point1.latitude);
  const deltaLon = toRadians(point2.longitude - point1.longitude);

  const a = Math.sin(deltaLat / 2) * Math.sin(deltaLat / 2) +
    Math.cos(lat1) * Math.cos(lat2) *
    Math.sin(deltaLon / 2) * Math.sin(deltaLon / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

// Convert degrees to radians
function toRadians(degrees: number): number {
  return degrees * (Math.PI / 180);
}

// Get geohash bounds for a radius search
export function getGeohashRange(
  center: GeoLocation,
  radiusKm: number
): { lower: string; upper: string } {
  const lat = center.latitude;
  const lon = center.longitude;
  
  // Calculate rough bounding box
  const latChange = radiusKm / 111.32; // 1 degree = 111.32 km
  const lonChange = radiusKm / (111.32 * Math.cos(toRadians(lat)));
  
  const bounds = {
    minLat: lat - latChange,
    maxLat: lat + latChange,
    minLon: lon - lonChange,
    maxLon: lon + lonChange
  };
  
  // Get geohash precision based on radius
  const precision = getPrecisionForRadius(radiusKm);
  
  return {
    lower: geohash.encode(bounds.minLat, bounds.minLon, precision),
    upper: geohash.encode(bounds.maxLat, bounds.maxLon, precision)
  };
}

// Get optimal geohash precision for a given radius
function getPrecisionForRadius(radiusKm: number): number {
  if (radiusKm <= 0.019) return 9;
  if (radiusKm <= 0.076) return 8;
  if (radiusKm <= 0.61) return 7;
  if (radiusKm <= 2.4) return 6;
  if (radiusKm <= 19.5) return 5;
  if (radiusKm <= 78) return 4;
  if (radiusKm <= 625) return 3;
  return 2;
}

// Check if a point is within a polygon (for zone boundaries)
export function isPointInPolygon(point: GeoLocation, polygon: GeoLocation[]): boolean {
  let inside = false;
  for (let i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    const xi = polygon[i].longitude;
    const yi = polygon[i].latitude;
    const xj = polygon[j].longitude;
    const yj = polygon[j].latitude;

    const intersect = ((yi > point.latitude) !== (yj > point.latitude)) &&
      (point.longitude < (xj - xi) * (point.latitude - yi) / (yj - yi) + xi);
    if (intersect) inside = !inside;
  }
  return inside;
}

// Generate grid points for zone coverage analysis
export function generateGridPoints(bounds: GeoBounds, gridSize: number): GeoLocation[] {
  const points: GeoLocation[] = [];
  const { center, radiusKm } = bounds;
  
  const latChange = radiusKm / 111.32;
  const lonChange = radiusKm / (111.32 * Math.cos(toRadians(center.latitude)));
  
  const latStep = latChange * 2 / gridSize;
  const lonStep = lonChange * 2 / gridSize;
  
  for (let lat = center.latitude - latChange; lat <= center.latitude + latChange; lat += latStep) {
    for (let lon = center.longitude - lonChange; lon <= center.longitude + lonChange; lon += lonStep) {
      points.push({
        latitude: lat,
        longitude: lon,
        geohash: generateGeohash({ latitude: lat, longitude: lon })
      });
    }
  }
  
  return points;
}
