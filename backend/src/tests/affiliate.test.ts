import { config } from 'dotenv';
import { resolve } from 'path';

// Load test environment variables
config({ path: resolve(__dirname, '../../.env.test') });

import { affiliateService } from '../services/affiliateService';
import { AffiliateStatus, PaymentMethod } from '../models/affiliate';

async function testAffiliateFlow() {
    try {
        console.log('🧪 Starting Affiliate Service Test Flow');

        // 1. Create new affiliate
        console.log('\n1️⃣ Testing affiliate creation...');
        const affiliate = await affiliateService.createAffiliate(
            'Test Affiliate',
            'test@example.com',
            '+22961234567',
            {
                preferredMethod: PaymentMethod.MOBILE_MONEY,
                mobileMoneyNumber: '+22961234567'
            }
        );
        console.log('✅ Affiliate created:', affiliate);

        // 2. Approve affiliate
        console.log('\n2️⃣ Testing affiliate approval...');
        await affiliateService.approveAffiliate(affiliate.id);
        const approvedAffiliate = await affiliateService.getAffiliateProfile(affiliate.id);
        console.log('✅ Affiliate approved:', approvedAffiliate.status === AffiliateStatus.ACTIVE);

        // 3. Simulate some referral activity
        console.log('\n3️⃣ Testing affiliate stats before activity...');
        const initialStats = await affiliateService.getAffiliateStats(affiliate.id);
        console.log('Initial stats:', initialStats);

        // 4. Request withdrawal
        console.log('\n4️⃣ Testing withdrawal request...');
        try {
            await affiliateService.requestWithdrawal(
                affiliate.id,
                1000,
                PaymentMethod.MOBILE_MONEY
            );
        } catch (error: any) {
            console.log('Expected error for insufficient balance:', error.message);
        }

        // 5. Get withdrawal history
        console.log('\n5️⃣ Testing withdrawal history...');
        const withdrawalHistory = await affiliateService.getWithdrawalHistory(affiliate.id, {
            limit: 10,
            offset: 0
        });
        console.log('Withdrawal history:', withdrawalHistory);

        // 6. Get pending withdrawals (admin view)
        console.log('\n6️⃣ Testing pending withdrawals list...');
        const pendingWithdrawals = await affiliateService.getPendingWithdrawals({
            limit: 10,
            offset: 0
        });
        console.log('Pending withdrawals:', pendingWithdrawals);

        // 7. Update affiliate profile
        console.log('\n7️⃣ Testing profile update...');
        await affiliateService.updateProfile(affiliate.id, {
            phone: '+22967891234',
            paymentInfo: {
                preferredMethod: PaymentMethod.MOBILE_MONEY,
                mobileMoneyNumber: '+22967891234'
            }
        });
        const updatedAffiliate = await affiliateService.getAffiliateProfile(affiliate.id);
        console.log('✅ Profile updated:', updatedAffiliate);

        console.log('\n✅ All tests completed successfully!');

    } catch (error) {
        console.error('❌ Test failed:', error);
    }
}

// Run the test
testAffiliateFlow();
