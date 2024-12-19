import { AppError, errorCodes } from '../../utils/errors';
import { RouteStop, Order } from '../../models/order';
import { calculateDistance, getGeohashRange, isPointInPolygon, generateGridPoints } from '../../utils/geo';
import { deliveryTasksService } from '../delivery-tasks';

export const deliveryRouteService = {
  async createDeliveryRoute(
    startLocation: { latitude: number; longitude: number },
    endLocation: { latitude: number; longitude: number },
    stops: RouteStop[]
  ): Promise<RouteStop[]> {
    try {
      // Validate input parameters
      if (!startLocation || !endLocation || !stops || stops.length === 0) {
        throw new AppError(400, 'Invalid input parameters', errorCodes.INVALID_INPUT);
      }

      // Add start and end locations as stops
      const allStops: RouteStop[] = [
        { type: 'pickup', location: startLocation, orderId: '', scheduledTime: new Date(), address: '' },
        ...stops,
        { type: 'delivery', location: endLocation, orderId: '', scheduledTime: new Date(), address: '' },
      ];

      // Optimize the route
      // const optimizedRoute = await calculateOptimizedRoute(allStops);

      // Update scheduled times based on the optimized route
      let currentTime = new Date();
      for (const stop of allStops) {
        stop.scheduledTime = currentTime;
        // Assuming an average time of 15 minutes per stop
        currentTime = new Date(currentTime.getTime() + 15 * 60 * 1000);
      }

      return allStops;
    } catch (error) {
      console.error('Error creating delivery route:', error);
      throw new AppError(500, 'Failed to create delivery route', errorCodes.INTERNAL_ERROR);
    }
  },

  async assignDeliveryRouteToDeliveryPerson(
    routeId: string,
    deliveryPersonId: string,
    orders: Order[]
  ): Promise<void> {
    try {
      // Validate input parameters
      if (!routeId || !deliveryPersonId) {
        throw new AppError(400, 'Invalid input parameters', errorCodes.INVALID_INPUT);
      }

      // Assign the route to the delivery person
      await deliveryTasksService.assignDeliveryTask(deliveryPersonId, routeId);

      // Update the status of the associated orders
      const orderIds = orders.map((order) => order.id);
      await deliveryTasksService.updateOrderStatus(orderIds, 'Assigned');
    } catch (error) {
      console.error('Error assigning delivery route:', error);
      throw new AppError(500, 'Failed to assign delivery route', errorCodes.INTERNAL_ERROR);
    }
  },

  async updateDeliveryRoute(routeId: string, updatedRoute: RouteStop[]): Promise<RouteStop[]> {
    try {
      // Validate input parameters
      if (!routeId || !updatedRoute || updatedRoute.length === 0) {
        throw new AppError(400, 'Invalid input parameters', errorCodes.INVALID_INPUT);
      }

      // Update the route
      // Assuming you have a function to update the route in the database
      // updateRouteInDatabase(routeId, updatedRoute);

      // Re-optimize the route if needed
      // const optimizedRoute = await calculateOptimizedRoute(updatedRoute);

      return updatedRoute;
    } catch (error) {
      console.error('Error updating delivery route:', error);
      throw new AppError(500, 'Failed to update delivery route', errorCodes.INTERNAL_ERROR);
    }
  },

  async getDeliveryRoute(routeId: string): Promise<RouteStop[]> {
    try {
      // Validate input parameters
      if (!routeId) {
        throw new AppError(400, 'Invalid input parameters', errorCodes.INVALID_INPUT);
      }

      // Get the route from the database
      // Assuming you have a function to get the route from the database
      // const route = await getRouteFromDatabase(routeId);

      // For demonstration purposes, let's assume we have a dummy route
      const route: RouteStop[] = [];

      return route;
    } catch (error) {
      console.error('Error getting delivery route:', error);
      throw new AppError(500, 'Failed to get delivery route', errorCodes.INTERNAL_ERROR);
    }
  },

  async getDeliveryPersonLocation(deliveryPersonId: string): Promise<{ latitude: number; longitude: number }> {
    try {
      // Validate input parameters
      if (!deliveryPersonId) {
        throw new AppError(400, 'Invalid input parameters', errorCodes.INVALID_INPUT);
      }

      // Get the delivery person's current location from the database
      // Assuming you have a function to get the location from the database
      // const location = await getDeliveryPersonLocationFromDatabase(deliveryPersonId);

      // For demonstration purposes, let's assume we have a dummy location
      const location = { latitude: 0, longitude: 0 };

      return location;
    } catch (error) {
      console.error('Error getting delivery person location:', error);
      throw new AppError(500, 'Failed to get delivery person location', errorCodes.INTERNAL_ERROR);
    }
  },

  async findNearestDeliveryPerson(location: { latitude: number; longitude: number }): Promise<string> {
    try {
      // Validate input parameters
      if (!location) {
        throw new AppError(400, 'Invalid input parameters', errorCodes.INVALID_INPUT);
      }

      // Find the nearest delivery person from the database
      // Assuming you have a function to find the nearest delivery person from the database
      // const nearestDeliveryPerson = await findNearestDeliveryPersonFromDatabase(location);

      // For demonstration purposes, let's assume we have a dummy delivery person ID
      const nearestDeliveryPerson = 'dummyDeliveryPersonId';

      return nearestDeliveryPerson;
    } catch (error) {
      console.error('Error finding nearest delivery person:', error);
      throw new AppError(500, 'Failed to find nearest delivery person', errorCodes.INTERNAL_ERROR);
    }
  },
};

export default deliveryRouteService;
