import admin from 'firebase-admin';
import { getFirestore } from 'firebase-admin/firestore';
import { getAuth } from 'firebase-admin/auth';

const serviceAccount = require('../../serviceAccountKey.json');

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

export const db = getFirestore();
export const auth = getAuth();
export { admin }; // Export admin for messaging

// Enable timestamps in snapshots
db.settings({
  ignoreUndefinedProperties: true,
  timestampsInSnapshots: true
});

// Export common Firestore types
export const { FieldValue, Timestamp } = admin.firestore;

// Type definitions for Firestore documents
export interface FirestoreDoc {
  id: string;
  createdAt: admin.firestore.Timestamp;
  updatedAt: admin.firestore.Timestamp;
}

// Transaction type
export type FirestoreTransaction = admin.firestore.Transaction;

// Batch type
export type FirestoreBatch = admin.firestore.WriteBatch;

// Reference types
export type DocReference = admin.firestore.DocumentReference;
export type CollectionReference = admin.firestore.CollectionReference;
