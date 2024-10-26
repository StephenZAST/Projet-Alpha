import * as admin from "firebase-admin";
import { getFirestore, collection, query, where } from "firebase/firestore";

const serviceAccount = require("../../serviceAccountKey.json");

const app = admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

export const db = app.firestore();
export const auth = app.auth();

// Collections references
export const usersRef = db.collection('users');
export const ordersRef = db.collection('orders');
export const articlesRef = db.collection('articles');
export const subscriptionsRef = db.collection('subscriptionPlans');
