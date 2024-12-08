import { db } from '../firebase';
import { LoyaltyProgram } from '../../models/loyalty';
import { AppError, errorCodes } from '../../utils/errors';
import { Timestamp } from 'firebase-admin/firestore';

const loyaltyRef = db.collection('loyalty_accounts');

export async function createLoyaltyProgram(data: Omit<LoyaltyProgram, 'id' | 'createdAt' | 'updatedAt'>): Promise<LoyaltyProgram> {
  const newLoyaltyProgram: LoyaltyProgram = {
    ...data,
    createdAt: Timestamp.now(),
    updatedAt: Timestamp.now(),
  } as LoyaltyProgram;

  const docRef = await loyaltyRef.add(newLoyaltyProgram);
  const doc = await docRef.get();

  return {
    id: doc.id,
    ...doc.data(),
  } as LoyaltyProgram;
}

export async function getLoyaltyProgram(): Promise<LoyaltyProgram | null> {
  const snapshot = await loyaltyRef.get();
  if (snapshot.empty) {
    return null;
  }
  return snapshot.docs[0].data() as LoyaltyProgram;
}

export async function getAllLoyaltyPrograms(): Promise<LoyaltyProgram[]> {
  const snapshot = await loyaltyRef.get();
  return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as LoyaltyProgram));
}

export async function getLoyaltyProgramById(id: string): Promise<LoyaltyProgram | null> {
  const loyaltyProgramRef = loyaltyRef.doc(id);
  const loyaltyProgramSnapshot = await loyaltyProgramRef.get();

  if (!loyaltyProgramSnapshot.exists) {
    return null;
  }

  return { id: loyaltyProgramSnapshot.id, ...loyaltyProgramSnapshot.data() } as LoyaltyProgram;
}

export async function updateLoyaltyProgram(id: string, data: Partial<LoyaltyProgram>): Promise<LoyaltyProgram> {
  const loyaltyProgramRef = loyaltyRef.doc(id);
  const loyaltyProgramSnapshot = await loyaltyProgramRef.get();

  if (!loyaltyProgramSnapshot.exists) {
    throw new AppError(404, 'Loyalty program not found', errorCodes.NOT_FOUND);
  }

  const updatedLoyaltyProgram: LoyaltyProgram = {
    ...loyaltyProgramSnapshot.data() as LoyaltyProgram,
    ...data,
    updatedAt: Timestamp.now(),
  };

  await loyaltyProgramRef.update(updatedLoyaltyProgram as Partial<LoyaltyProgram>);
  return updatedLoyaltyProgram;
}

export async function deleteLoyaltyProgram(id: string): Promise<void> {
  const loyaltyProgramRef = loyaltyRef.doc(id);
  const loyaltyProgramSnapshot = await loyaltyProgramRef.get();

  if (!loyaltyProgramSnapshot.exists) {
    throw new AppError(404, 'Loyalty program not found', errorCodes.NOT_FOUND);
  }

  await loyaltyProgramRef.delete();
}
