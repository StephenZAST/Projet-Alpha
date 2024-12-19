export interface Location {
  latitude: number;
  longitude: number;
}

export interface RouteStop {
  type: 'pickup' | 'delivery';
  location: Location;
  orderId: string;
  scheduledTime: Date;
  address: string;
}

export interface RouteInfo {
  orderId: string;
  location: Location;
  type: 'pickup' | 'delivery';
  scheduledTime: Date;
  status: 'pending' | 'in_progress' | 'completed';
  address: string;
}

export interface OptimizedRoute {
  deliveryPersonId: string;
  zoneId: string;
  date: Date;
  stops: RouteInfo[];
  estimatedDuration: number;
  estimatedDistance: number;
  startLocation: Location;
  endLocation: Location;
}

interface DistanceMatrix {
  [key: string]: {
    [key: string]: number;
  };
}

/**
 * Calcule la distance entre deux points géographiques en utilisant la formule de Haversine
 */
function calculateDistance(point1: Location, point2: Location): number {
  const R = 6371; // Rayon de la Terre en kilomètres
  const dLat = toRad(point2.latitude - point1.latitude);
  const dLon = toRad(point2.longitude - point1.longitude);
  
  const a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(toRad(point1.latitude)) * Math.cos(toRad(point2.latitude)) * 
    Math.sin(dLon/2) * Math.sin(dLon/2);
  
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  return R * c;
}

function toRad(degrees: number): number {
  return degrees * Math.PI / 180;
}

/**
 * Optimise une route pour un ensemble de points de livraison
 */
export function optimizeRoute(stops: RouteStop[]): Promise<RouteStop[]> {
  try {
    // Trier les arrêts par heure programmée
    const sortedStops = stops.sort((a, b) => {
      return a.scheduledTime.getTime() - b.scheduledTime.getTime();
    });

    // Optimiser l'ordre des arrêts en tenant compte des contraintes de temps
    const optimizedStops = sortedStops.reduce((acc: RouteStop[], stop: RouteStop) => {
      if (acc.length === 0) {
        return [stop];
      }

      // Trouver la meilleure position pour insérer l'arrêt
      let bestPosition = 0;
      let minExtraDistance = Infinity;

      for (let i = 0; i <= acc.length; i++) {
        const routeWithStop = [
          ...acc.slice(0, i),
          stop,
          ...acc.slice(i)
        ];

        // Calculer la distance totale de cette route
        let totalDistance = 0;
        for (let j = 1; j < routeWithStop.length; j++) {
          totalDistance += calculateDistance(
            routeWithStop[j-1].location,
            routeWithStop[j].location
          );
        }

        if (totalDistance < minExtraDistance) {
          minExtraDistance = totalDistance;
          bestPosition = i;
        }
      }

      // Insérer l'arrêt à la meilleure position
      acc.splice(bestPosition, 0, stop);
      return acc;
    }, []);

    return Promise.resolve(optimizedStops);
  } catch (error) {
    return Promise.reject(error);
  }
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

/**
 * Optimise une route pour un ensemble de points de livraison
 */
export function optimizeRouteSimple(stops: RouteStop[]): RouteStop[] {
  // Ici, vous pouvez implémenter votre logique d'optimisation de route
  // Pour l'instant, nous retournons simplement les arrêts triés par heure prévue
  return stops.sort((a, b) => a.scheduledTime.getTime() - b.scheduledTime.getTime());
}
