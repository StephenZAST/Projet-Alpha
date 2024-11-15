import { Location } from '../models/order';
import { RouteInfo, OptimizedRoute } from '../models/delivery';
import { Timestamp } from 'firebase-admin/firestore';

interface DistanceMatrix {
  [key: string]: {
    [key: string]: number;
  };
}

/**
 * Calcule la distance entre deux points géographiques en utilisant la formule de Haversine
 */
export function calculateDistance(point1: Location, point2: Location): number {
  const R = 6371; // Rayon de la Terre en km
  const dLat = toRad(point2.latitude - point1.latitude);
  const dLon = toRad(point2.longitude - point1.longitude);
  const lat1 = toRad(point1.latitude);
  const lat2 = toRad(point2.latitude);

  const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  return R * c;
}

function toRad(value: number): number {
  return value * Math.PI / 180;
}

/**
 * Crée une matrice de distances entre tous les points
 */
function createDistanceMatrix(stops: RouteInfo[]): DistanceMatrix {
  const matrix: DistanceMatrix = {};
  
  stops.forEach((stop1, i) => {
    matrix[i] = {};
    stops.forEach((stop2, j) => {
      if (i !== j) {
        matrix[i][j] = calculateDistance(stop1.location, stop2.location);
      }
    });
  });

  return matrix;
}

/**
 * Algorithme du plus proche voisin pour l'optimisation de route
 */
function nearestNeighborAlgorithm(
  stops: RouteInfo[],
  distanceMatrix: DistanceMatrix,
  startIndex: number = 0
): number[] {
  const numStops = stops.length;
  const visited = new Set<number>([startIndex]);
  const route = [startIndex];

  while (visited.size < numStops) {
    let currentStop = route[route.length - 1];
    let nearestStop = -1;
    let minDistance = Infinity;

    for (let i = 0; i < numStops; i++) {
      if (!visited.has(i) && distanceMatrix[currentStop][i] < minDistance) {
        minDistance = distanceMatrix[currentStop][i];
        nearestStop = i;
      }
    }

    if (nearestStop !== -1) {
      route.push(nearestStop);
      visited.add(nearestStop);
    }
  }

  return route;
}

/**
 * Optimise une route pour un ensemble de points de livraison
 */
export function optimizeRoute(
  deliveryPersonId: string,
  zoneId: string,
  stops: RouteInfo[],
  startLocation: Location,
  endLocation: Location
): OptimizedRoute {
  // Ajouter les points de départ et d'arrivée
  const allStops = [
    {
      orderId: 'start',
      location: startLocation,
      type: 'pickup' as const,
      scheduledTime: Timestamp.now(),
      status: 'pending' as const,
      address: 'Starting Point'
    },
    ...stops,
    {
      orderId: 'end',
      location: endLocation,
      type: 'delivery' as const,
      scheduledTime: Timestamp.now(),
      status: 'pending' as const,
      address: 'Ending Point'
    }
  ];

  // Créer la matrice de distances
  const distanceMatrix = createDistanceMatrix(allStops);

  // Optimiser la route
  const optimizedIndices = nearestNeighborAlgorithm(allStops, distanceMatrix);

  // Réorganiser les arrêts selon l'ordre optimisé
  const optimizedStops = optimizedIndices.map(index => allStops[index]);

  // Calculer la distance totale
  let totalDistance = 0;
  for (let i = 0; i < optimizedIndices.length - 1; i++) {
    const currentIndex = optimizedIndices[i];
    const nextIndex = optimizedIndices[i + 1];
    totalDistance += distanceMatrix[currentIndex][nextIndex];
  }

  // Estimer la durée (en supposant une vitesse moyenne de 30 km/h en ville)
  const averageSpeed = 30; // km/h
  const estimatedDuration = (totalDistance / averageSpeed) * 60; // Conversion en minutes

  return {
    deliveryPersonId,
    zoneId,
    date: Timestamp.now(),
    stops: optimizedStops.slice(1, -1), // Exclure les points de départ et d'arrivée
    estimatedDuration: Math.round(estimatedDuration),
    estimatedDistance: Math.round(totalDistance * 10) / 10,
    startLocation,
    endLocation
  };
}

/**
 * Vérifie si une route est réalisable en fonction des contraintes de temps
 */
export function isRouteViable(route: OptimizedRoute, maxWorkingHours: number = 8): boolean {
  return route.estimatedDuration <= (maxWorkingHours * 60); // Conversion des heures en minutes
}

/**
 * Calcule le score d'efficacité d'une route
 */
export function calculateRouteEfficiency(route: OptimizedRoute): number {
  const stopsPerHour = (route.stops.length / route.estimatedDuration) * 60;
  const distancePerStop = route.estimatedDistance / route.stops.length;
  
  // Score basé sur le nombre d'arrêts par heure et la distance moyenne entre les arrêts
  return (stopsPerHour * 10) - (distancePerStop * 2);
}
