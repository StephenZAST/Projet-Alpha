import * as admin from 'firebase-admin';
import { getFirestore } from 'firebase-admin/firestore';
import { resolve } from 'path';

// Initialize Firebase Admin
if (!admin.apps.length) {
    try {
        const serviceAccount = require('./serviceAccountKey.json');
        
        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
            databaseURL: `https://${serviceAccount.project_id}.firebaseio.com`,
            storageBucket: `${serviceAccount.project_id}.appspot.com`
        });

        console.log('✅ Firebase Admin SDK initialized successfully');
    } catch (error) {
        console.error('❌ Firebase admin initialization error:', error);
        throw error; // Re-throw to prevent app from starting with invalid Firebase config
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
