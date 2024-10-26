import { collection, addDoc, Timestamp, getFirestore } from "firebase/firestore";
import { db } from "./firebase";
import { User } from "../models/user";

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
