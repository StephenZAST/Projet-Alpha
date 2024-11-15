import { collection, addDoc, Timestamp, getFirestore } from "firebase/firestore";
import { db } from "./firebase";
import { User } from "../models/user";
import { AppError, errorCodes } from '../utils/errors';

export async function createUser(user: User): Promise<User | null> {
  try {
    const firestore = getFirestore();
    const usersCollectionRef = collection(firestore, "users");
    const newUser = await addDoc(usersCollectionRef, {
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      phoneNumber: user.phoneNumber,
      address: user.address,
      role: user.role,
      affiliateId: user.affiliateId,
      creationDate: Timestamp.now(),
      lastLogin: Timestamp.now(),
    });
    const newUserData = { ...user, id: newUser.id };
    return newUserData;
  } catch (error) {
    console.error("Error creating user:", error);
    return null;
  }
}

export interface UserProfile {
  id: string;
  defaultAddress?: {
    formattedAddress: string;
    coordinates: {
      latitude: number;
      longitude: number;
    };
  };
  defaultItems?: any[];
  defaultInstructions?: string;
}

export async function getUserProfile(userId: string): Promise<UserProfile | null> {
  try {
    const userDoc = await db.collection('users').doc(userId).get();
    
    if (!userDoc.exists) {
      return null;
    }

    return {
      id: userDoc.id,
      ...userDoc.data()
    } as UserProfile;
  } catch (error) {
    console.error('Error fetching user profile:', error);
    throw new AppError(500, 'Failed to fetch user profile', errorCodes.DATABASE_ERROR);
  }
}
