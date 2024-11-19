import * as admin from "firebase-admin";
import { getFirestore, collection, query, where } from "firebase/firestore";

const serviceAccount = require("../../serviceAccountKey.json");

// Initialize Firebase app only if not already initialized
if (admin.apps.length === 0) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

// Export db, auth, and collection references
export const db = admin.firestore();
export const auth = admin.auth();

// Collections references
export const usersRef = db.collection('users');
export const ordersRef = db.collection('orders');
export const articlesRef = db.collection('articles');
export const subscriptionsRef = db.collection('subscriptionPlans');
