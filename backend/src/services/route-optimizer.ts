import { DeliveryTask } from '../models/delivery-task';
import { GeoLocation, calculateDistance } from '../utils/geo';
import { Cache } from '../utils/cache';

interface RoutePoint {
  location: GeoLocation;
  task: DeliveryTask;
  timeWindow: {
    start: Date;
    end: Date;
  };
  serviceTime: number; // in minutes
}

interface Route {
  points: RoutePoint[];
  totalDistance: number;
  totalTime: number;
  score: number;
}

interface TrafficData {
  segment: {
    start: GeoLocation;
    end: GeoLocation;
  };
  factor: number; // multiplier for normal travel time
  timestamp: Date;
}

export class RouteOptimizer {
  private readonly trafficCache: Cache<string, TrafficData>;
  private readonly routeCache: Cache<string, Route>;

  constructor() {
    this.trafficCache = new Cache<string, TrafficData>(900); // 15 minutes TTL
    this.routeCache = new Cache<string, Route>(300); // 5 minutes TTL
  }

  async optimizeRoute(
    tasks: DeliveryTask[],
    startLocation: GeoLocation,
    maxTravelTime: number
  ): Promise<Route> {
    // Generate cache key based on inputs
    const cacheKey = this.generateCacheKey(tasks, startLocation);
    const cachedRoute = this.routeCache.get(cacheKey);
    if (cachedRoute) {
      return cachedRoute;
    }

    // Convert tasks to route points
    const points = this.tasksToRoutePoints(tasks);

    // Generate initial solution using nearest neighbor
    let route = this.generateInitialRoute(points, startLocation);

    // Improve solution using 2-opt
    route = this.improve2Opt(route, maxTravelTime);

    // Cache and return the result
    this.routeCache.set(cacheKey, route);
    return route;
  }

  private tasksToRoutePoints(tasks: DeliveryTask[]): RoutePoint[] {
    return tasks.map(task => ({
      location: task.deliveryLocation,
      task: task,
      timeWindow: {
        start: new Date(task.scheduledTime.date),
        end: new Date(new Date(task.scheduledTime.date).getTime() + task.scheduledTime.duration * 60000)
      },
      serviceTime: task.estimatedDuration || 15 // default 15 minutes
    }));
  }

  private generateInitialRoute(points: RoutePoint[], start: GeoLocation): Route {
    const route: RoutePoint[] = [];
    const unvisited = [...points];
    let currentLocation = start;
    let totalDistance = 0;
    let totalTime = 0;

    while (unvisited.length > 0) {
      // Find nearest point considering time windows
      const nextIndex = this.findNearestValidPoint(
        currentLocation,
        unvisited,
        totalTime
      );

      if (nextIndex === -1) break; // No valid points found

      const point = unvisited[nextIndex];
      const distance = this.getAdjustedDistance(currentLocation, point.location);
      
      totalDistance += distance;
      totalTime += this.calculateTravelTime(distance) + point.serviceTime;
      
      route.push(point);
      unvisited.splice(nextIndex, 1);
      currentLocation = point.location;
    }

    return {
      points: route,
      totalDistance,
      totalTime,
      score: this.calculateRouteScore(route, totalDistance, totalTime)
    };
  }

  private improve2Opt(route: Route, maxTravelTime: number): Route {
    let improved = true;
    let bestRoute = route;

    while (improved) {
      improved = false;
      
      for (let i = 0; i < route.points.length - 1; i++) {
        for (let j = i + 1; j < route.points.length; j++) {
          const newRoute = this.trySwap(route, i, j);
          
          if (newRoute.totalTime <= maxTravelTime && 
              newRoute.score > bestRoute.score) {
            bestRoute = newRoute;
            improved = true;
          }
        }
      }

      route = bestRoute;
    }

    return bestRoute;
  }

  private trySwap(route: Route, i: number, j: number): Route {
    const newPoints = [...route.points];
    const segment = newPoints.slice(i, j + 1).reverse();
    newPoints.splice(i, j - i + 1, ...segment);

    let totalDistance = 0;
    let totalTime = 0;
    let currentLocation = route.points[0].location;

    for (const point of newPoints) {
      const distance = this.getAdjustedDistance(currentLocation, point.location);
      totalDistance += distance;
      totalTime += this.calculateTravelTime(distance) + point.serviceTime;
      currentLocation = point.location;
    }

    return {
      points: newPoints,
      totalDistance,
      totalTime,
      score: this.calculateRouteScore(newPoints, totalDistance, totalTime)
    };
  }

  private findNearestValidPoint(
    from: GeoLocation,
    points: RoutePoint[],
    currentTime: number
  ): number {
    let nearestIndex = -1;
    let minScore = Infinity;

    points.forEach((point, index) => {
      const distance = this.getAdjustedDistance(from, point.location);
      const travelTime = this.calculateTravelTime(distance);
      const arrivalTime = currentTime + travelTime;

      // Skip if we can't arrive before the time window ends
      if (arrivalTime > point.timeWindow.end.getTime()) {
        return;
      }

      // Calculate score based on distance and time window
      const waitTime = Math.max(0, point.timeWindow.start.getTime() - arrivalTime);
      const score = distance + waitTime / 60000; // Convert wait time to minutes

      if (score < minScore) {
        minScore = score;
        nearestIndex = index;
      }
    });

    return nearestIndex;
  }

  private getAdjustedDistance(from: GeoLocation, to: GeoLocation): number {
    const distance = calculateDistance(from, to);
    const trafficFactor = this.getTrafficFactor(from, to);
    return distance * trafficFactor;
  }

  private calculateTravelTime(distance: number): number {
    // Assume average speed of 30 km/h in urban areas
    return (distance / 30) * 60; // Convert to minutes
  }

  private getTrafficFactor(from: GeoLocation, to: GeoLocation): number {
    const cacheKey = `${from.latitude},${from.longitude}-${to.latitude},${to.longitude}`;
    const trafficData = this.trafficCache.get(cacheKey);
    return trafficData?.factor || 1.0;
  }

  private calculateRouteScore(
    points: RoutePoint[],
    distance: number,
    time: number
  ): number {
    let score = 0;
    
    // Penalize total distance and time
    score -= distance * 0.1; // -0.1 points per km
    score -= time * 0.05; // -0.05 points per minute

    // Reward on-time deliveries
    points.forEach(point => {
      const isOnTime = time <= point.timeWindow.end.getTime();
      score += isOnTime ? 10 : -20;
    });

    // Reward high priority tasks being done earlier
    points.forEach((point, index) => {
      if (point.task.priority === 'high') {
        score += (points.length - index) * 5;
      }
    });

    return score;
  }

  private generateCacheKey(tasks: DeliveryTask[], start: GeoLocation): string {
    const taskIds = tasks.map(t => t.id).sort().join(',');
    return `${taskIds}:${start.latitude},${start.longitude}`;
  }
}
