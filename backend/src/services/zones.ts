import { db } from '../config/firebase';
import { AppError, errorCodes } from '../utils/errors';

interface Zone {
  id: string;
  name: string;
  deliveryFee: number;
  coordinates: {
    latitude: number;
    longitude: number;
  }[];
}

const zonesRef = db.collection('zones');

export const getZoneById = async (zoneId: string): Promise<Zone | null> => {
  try {
    const zoneDoc = await zonesRef.doc(zoneId).get();

    if (!zoneDoc.exists) {
      return null;
    }

    return zoneDoc.data() as Zone;
  } catch (error) {
    console.error('Error getting zone by ID:', error);
    throw new AppError(500, 'Failed to get zone by ID.', errorCodes.DATABASE_ERROR);
  }
};
