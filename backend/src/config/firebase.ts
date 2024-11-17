import * as admin from 'firebase-admin';
import { getFirestore } from 'firebase-admin/firestore';

// Initialize Firebase Admin
if (!admin.apps.length) {
    try {
        admin.initializeApp({
            credential: admin.credential.applicationDefault(),
            databaseURL: process.env.FIREBASE_DATABASE_URL,
            projectId: process.env.FIREBASE_PROJECT_ID,
            storageBucket: process.env.FIREBASE_STORAGE_BUCKET
        });
    } catch (error) {
        console.error('Firebase admin initialization error:', error);
    }
}

// Initialize Firestore
const db = getFirestore();

// Enable timestamps in snapshots
db.settings({
    ignoreUndefinedProperties: true,
    timestampsInSnapshots: true
});

export { admin, db };

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
