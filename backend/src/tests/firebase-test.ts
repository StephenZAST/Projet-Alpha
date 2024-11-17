import { db } from '../config/firebase';

async function testFirebaseConnection() {
    try {
        // Try to access a collection
        const testCollection = db.collection('test');
        const testDoc = await testCollection.add({
            test: true,
            timestamp: new Date()
        });
        
        console.log('✅ Firebase connection successful! Document written with ID:', testDoc.id);
        
        // Clean up - delete the test document
        await testDoc.delete();
        
    } catch (error) {
        console.error('❌ Firebase connection failed:', error);
        process.exit(1);
    }
}

// Run the test
testFirebaseConnection();
