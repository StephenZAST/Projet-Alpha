import { createClient } from '@supabase/supabase-js';
import * as dotenv from 'dotenv';
import bcrypt from 'bcryptjs';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('SUPABASE_URL and SUPABASE_SERVICE_KEY must be set in the .env file');
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function setupTestData() {
  try {
    console.log('Creating test data for affiliate system...');

    // 1. Créer les niveaux d'affiliation
    const levels = [
      {
        name: 'Bronze',
        min_earnings: 0,
        commission_rate: 0.10,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      },
      {
        name: 'Argent',
        min_earnings: 500000,
        commission_rate: 0.15,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      },
      {
        name: 'Or',
        min_earnings: 2000000,
        commission_rate: 0.20,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }
    ];

    let bronzeLevel;
    for (const level of levels) {
      const { data, error } = await supabase
        .from('affiliate_levels')
        .insert([level])
        .select()
        .single();

      if (error && error.code !== '23505') throw error; // Ignore unique constraint violations
      if (level.name === 'Bronze') bronzeLevel = data;
    }

    console.log('Affiliate levels created');

    // 2. Créer une catégorie d'article test
    const { data: category, error: categoryError } = await supabase
      .from('article_categories')
      .insert([{
        name: 'Test Category',
        description: 'Category for test items',
        created_at: new Date().toISOString()
      }])
      .select()
      .single();

    if (categoryError && categoryError.code !== '23505') throw categoryError;
    console.log('Article category created');

    // 3. Créer un article test
    const { data: article, error: articleError } = await supabase
      .from('articles')
      .insert([{
        category_id: category.id,
        name: 'Test Article',
        description: 'Test article for orders',
        base_price: 5000,
        premium_price: 7500,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }])
      .select()
      .single();

    if (articleError && articleError.code !== '23505') throw articleError;
    console.log('Test article created');

    // 4. Créer un service test
    const { data: service, error: serviceError } = await supabase
      .from('services')
      .insert([{
        name: 'Test Service',
        description: 'Service for test orders',
        price: 1000,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }])
      .select()
      .single();

    if (serviceError && serviceError.code !== '23505') throw serviceError;
    console.log('Test service created');

    // 5. Créer un affilié test
    const { data: affiliate, error: affiliateError } = await supabase
      .from('users')
      .insert([{
        email: 'affiliate.test@alphaomedia.com',
        password: await bcrypt.hash('affiliate123', 10),
        first_name: 'Affiliate',
        last_name: 'Test',
        role: 'AFFILIATE',
        phone: '+22502345678',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }])
      .select()
      .single();

    if (affiliateError && affiliateError.code !== '23505') throw affiliateError;
    console.log('Affiliate created:', affiliate.email);

    // 6. Créer le profil d'affilié
    const affiliateCode = 'TEST' + Math.random().toString(36).substring(2, 6).toUpperCase();
    const { data: affiliateProfile, error: profileError } = await supabase
      .from('affiliate_profiles')
      .insert([{
        user_id: affiliate.id,
        affiliate_code: affiliateCode,
        commission_balance: 0,
        total_earned: 0,
        monthly_earnings: 0,
        level_id: bronzeLevel.id,
        total_referrals: 0,
        status: 'ACTIVE',
        is_active: true,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }])
      .select()
      .single();

    if (profileError && profileError.code !== '23505') throw profileError;
    console.log('Affiliate profile created with code:', affiliateCode);

    // 7. Créer un client test
    const { data: client, error: clientError } = await supabase
      .from('users')
      .insert([{
        email: 'client.test@alphaomedia.com',
        password: await bcrypt.hash('client123', 10),
        first_name: 'Client',
        last_name: 'Test',
        role: 'CLIENT',
        phone: '+22503456789',
        referral_code: affiliateCode,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }])
      .select()
      .single();

    if (clientError && clientError.code !== '23505') throw clientError;
    console.log('Client created:', client.email);

    // 8. Créer une adresse pour le client
    const { data: address, error: addressError } = await supabase
      .from('addresses')
      .insert([{
        user_id: client.id,
        name: 'Domicile',
        street: '123 Rue Test',
        city: 'Abidjan',
        postal_code: '00225',
        is_default: true,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }])
      .select()
      .single();

    if (addressError && addressError.code !== '23505') throw addressError;
    console.log('Client address created');

    // 9. Créer une commande test avec le code d'affiliation
    const { data: order, error: orderError } = await supabase.rpc(
      'create_order_with_items',
      {
        p_userid: client.id,
        p_serviceid: service.id,
        p_addressid: address.id,
        p_isrecurring: false,
        p_recurrencetype: 'NONE',
        p_collectiondate: new Date().toISOString(),
        p_deliverydate: new Date(Date.now() + 86400000).toISOString(),
        p_affiliatecode: affiliateCode,
        p_service_type_id: null,
        p_paymentmethod: 'CASH',
        p_items: [{
          articleId: article.id,
          quantity: 2,
          isPremium: true
        }]
      }
    );

    if (orderError) throw orderError;
    console.log('Test order created with commission');

    console.log('\nTest Credentials:');
    console.log('Affiliate - Email: affiliate.test@alphaomedia.com / Password: affiliate123');
    console.log('Client - Email: client.test@alphaomedia.com / Password: client123');
    console.log('Affiliate Code:', affiliateCode);

  } catch (error) {
    console.error('Error setting up test data:', error);
    throw error;
  }
}

setupTestData().catch(console.error);