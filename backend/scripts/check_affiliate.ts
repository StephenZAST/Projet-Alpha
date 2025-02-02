import supabase from '../src/config/database';

async function checkAffiliate() {
  const { data: affiliate, error } = await supabase
    .from('affiliate_profiles')
    .select(`
      id,
      affiliate_code,
      is_active,
      status,
      user:users(
        email,
        first_name,
        last_name
      )
    `)
    .eq('affiliate_code', '0YI0MR9WX')
    .single();

  if (error) {
    console.error('Error checking affiliate:', error);
    return;
  }

  if (!affiliate) {
    console.log('No affiliate found with code: 0YI0MR9WX');
    return;
  }

  console.log('Affiliate found:', {
    id: affiliate.id,
    code: affiliate.affiliate_code,
    is_active: affiliate.is_active,
    status: affiliate.status,
    user: affiliate.user
  });
}

checkAffiliate();