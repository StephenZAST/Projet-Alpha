import supabase from '../src/config/database';
import jwt from 'jsonwebtoken';
import fetch from 'node-fetch';
import { config } from 'dotenv';

// Load environment variables
config();

interface NotificationPreferences {
  id: string;
  email: boolean;
  sms: boolean;
  push: boolean;
  promotions: boolean;
  order_updates: boolean;
  payments: boolean;
  loyalty: boolean;
  created_at?: string;
  updated_at?: string;
}

interface ProfileResponse {
  id: string;
  user_id: string;
  affiliate_code: string;
  commission_balance: number;
  total_earned: number;
  monthly_earnings: number;
  total_referrals: number;
  status: string;
  user_details: {
    id: string;
    email: string;
    first_name: string;
    last_name: string;
    phone?: string;
    notification_preferences?: NotificationPreferences;
  };
  level: {
    id: string;
    name: string;
    commissionRate: number;
  } | null;
}

async function logProfileData(data: ProfileResponse, title: string) {
  console.log(`\n${title}:`);
  console.log('- Profile Info:', {
    id: data.id,
    affiliate_code: data.affiliate_code,
    status: data.status,
    commission_balance: data.commission_balance,
    total_earned: data.total_earned
  });

  if (data.user_details) {
    console.log('- User Info:', {
      id: data.user_details.id,
      email: data.user_details.email,
      name: `${data.user_details.first_name} ${data.user_details.last_name}`,
      phone: data.user_details.phone || 'Not set'
    });

    if (data.user_details.notification_preferences) {
      console.log('- Notification Preferences:', {
        email: data.user_details.notification_preferences.email,
        sms: data.user_details.notification_preferences.sms,
        push: data.user_details.notification_preferences.push,
        promotions: data.user_details.notification_preferences.promotions,
        order_updates: data.user_details.notification_preferences.order_updates,
        payments: data.user_details.notification_preferences.payments,
        loyalty: data.user_details.notification_preferences.loyalty
      });
    } else {
      console.log('- No notification preferences set');
    }
  }

  if (data.level) {
    console.log('- Level Info:', data.level);
  }
}

async function testAffiliateProfile() {
  try {
    const userId = 'dd49fbbe-e982-42a9-b8cb-358324827694';
    const token = jwt.sign(
      { id: userId, role: 'AFFILIATE' },
      process.env.JWT_SECRET || 'your-secret-key',
      { expiresIn: '1h' }
    );

    console.log('\n=== Testing Affiliate Profile Functionality ===\n');

    // 1. Test GET Profile
    console.log('1. Testing GET Profile...');
    const response = await fetch('http://localhost:3001/api/affiliate/profile', {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error('GET Profile Error Details:', errorText);
      throw new Error(`GET Profile failed: ${response.statusText}`);
    }

    const responseJson = await response.json() as { data: ProfileResponse };
    if (!responseJson.data) {
      throw new Error('No profile data received');
    }
    await logProfileData(responseJson.data, 'Current Profile Data');

    console.log('\nRaw response:', JSON.stringify(responseJson, null, 2));
    // Wait a bit before update to ensure timestamps are different
    await new Promise(resolve => setTimeout(resolve, 1000));

    // 2. Test UPDATE Profile
    console.log('\n2. Testing UPDATE Profile...');
    const updateData = {
      phone: '+1234567890',
      notificationPreferences: {
        email: true,
        sms: true,
        push: false,
        promotions: true,
        order_updates: true,
        payments: true,
        loyalty: false
      }
    };

    const updateResponse = await fetch('http://localhost:3001/api/affiliate/profile', {
      method: 'PUT',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(updateData)
    });

    if (!updateResponse.ok) {
      const errorText = await updateResponse.text();
      console.error('UPDATE Profile Error Details:', errorText);
      throw new Error(`UPDATE Profile failed: ${updateResponse.statusText}`);
    }

    const updateResponseJson = await updateResponse.json() as { data: ProfileResponse };
    if (!updateResponseJson.data) {
      throw new Error('No updated profile data received');
    }
    await logProfileData(updateResponseJson.data, 'Updated Profile Data');

    console.log('\nRaw update response:', JSON.stringify(updateResponseJson, null, 2));

    // 3. Verify Changes in Database
    console.log('\n3. Verifying changes in database...');
    
    // Check user phone
    const { data: userData, error: userError } = await supabase
      .from('users')
      .select('phone')
      .eq('id', userId)
      .single();

    if (userError) {
      console.error('Error checking user:', userError);
      throw userError;
    }

    // Check notification preferences
    const { data: prefsData, error: prefsError } = await supabase
      .from('notification_preferences')
      .select('*')
      .eq('user_id', userId)
      .single();

    if (prefsError) {
      console.error('Error checking preferences:', prefsError);
      throw prefsError;
    }

    console.log('\nVerification Results:');
    const phoneMatch = userData.phone === updateData.phone;
    const prefsMatch = {
      email: prefsData.email === updateData.notificationPreferences.email,
      sms: prefsData.sms === updateData.notificationPreferences.sms,
      push: prefsData.push === updateData.notificationPreferences.push,
      promotions: prefsData.promotions === updateData.notificationPreferences.promotions,
      order_updates: prefsData.order_updates === updateData.notificationPreferences.order_updates,
      payments: prefsData.payments === updateData.notificationPreferences.payments,
      loyalty: prefsData.loyalty === updateData.notificationPreferences.loyalty
    };

    console.log('\nVerification Results:');
    console.log('Phone number updated:', phoneMatch);
    console.log('Notification preferences match:', prefsMatch);
    console.log('\nExpected preferences:', updateData.notificationPreferences);
    console.log('Actual preferences:', {
      email: prefsData.email,
      sms: prefsData.sms,
      push: prefsData.push,
      promotions: prefsData.promotions,
      order_updates: prefsData.order_updates,
      payments: prefsData.payments,
      loyalty: prefsData.loyalty
    });

    // Verify all values match what we sent
    const mismatchedPrefs = Object.entries(prefsMatch)
      .filter(([key, matches]) => !matches)
      .map(([key]) => key);

    if (!phoneMatch || mismatchedPrefs.length > 0) {
      throw new Error(
        'Verification failed:\n' +
        (!phoneMatch ? '- Phone number does not match\n' : '') +
        (mismatchedPrefs.length > 0 ? `- Mismatched preferences: ${mismatchedPrefs.join(', ')}\n` : '')
      );
    }

    console.log('\nAll values verified successfully!');

    console.log('\n=== Test Complete ===\n');
  } catch (error) {
    console.error('Test failed:', error);
    process.exit(1);
  }
}

// Run the test
testAffiliateProfile();