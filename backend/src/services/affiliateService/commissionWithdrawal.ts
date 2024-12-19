import { supabase } from '../../config/supabase';
import { CommissionWithdrawal, PayoutStatus, Affiliate, PaymentMethod } from '../../models/affiliate';
import { AppError, errorCodes } from '../../utils/errors';

const commissionWithdrawalsTable = 'commissionWithdrawals';
const affiliatesTable = 'affiliates';

export async function requestCommissionWithdrawal(
    affiliateId: string,
    amount: number,
    paymentMethod: PaymentMethod,
    paymentDetails: CommissionWithdrawal['paymentDetails']
): Promise<CommissionWithdrawal> {
    try {
        const withdrawal: Omit<CommissionWithdrawal, 'id'> = {
            affiliateId,
            amount,
            paymentMethod,
            paymentDetails,
            status: PayoutStatus.PENDING,
            requestedAt: new Date().toISOString(),
            processedAt: null,
            processedBy: null,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
        };

        const { data, error } = await supabase.from(commissionWithdrawalsTable).insert([withdrawal]).select().single();

        if (error) {
            throw new AppError(500, 'Failed to request commission withdrawal', errorCodes.COMMISSION_WITHDRAWAL_REQUEST_FAILED);
        }

        return data as CommissionWithdrawal;
    } catch (error) {
        if (error instanceof AppError) throw error;
        throw new AppError(500, 'Failed to request commission withdrawal', errorCodes.COMMISSION_WITHDRAWAL_REQUEST_FAILED);
    }
}

export async function getCommissionWithdrawals(): Promise<CommissionWithdrawal[]> {
    try {
        const { data, error } = await supabase.from(commissionWithdrawalsTable).select('*').order('requestedAt', { ascending: false });

        if (error) {
            throw new AppError(500, 'Failed to fetch commission withdrawals', errorCodes.COMMISSION_WITHDRAWAL_FETCH_FAILED);
        }

        return data as CommissionWithdrawal[];
    } catch (error) {
        throw new AppError(500, 'Failed to fetch commission withdrawals', errorCodes.COMMISSION_WITHDRAWAL_FETCH_FAILED);
    }
}

export async function updateCommissionWithdrawalStatus(withdrawalId: string, status: PayoutStatus): Promise<CommissionWithdrawal> {
    try {
        const { data: withdrawal, error: withdrawalError } = await supabase
            .from(commissionWithdrawalsTable)
            .select('*')
            .eq('id', withdrawalId)
            .single();

        if (withdrawalError) {
            throw new AppError(404, 'Commission withdrawal not found', errorCodes.COMMISSION_WITHDRAWAL_NOT_FOUND);
        }

        const { error } = await supabase
            .from(commissionWithdrawalsTable)
            .update({
                status,
                processedAt: new Date().toISOString(),
                processedBy: 'admin', // Placeholder for admin ID
                updatedAt: new Date().toISOString()
            })
            .eq('id', withdrawalId);

        if (error) {
            throw new AppError(500, 'Failed to update commission withdrawal status', errorCodes.COMMISSION_WITHDRAWAL_UPDATE_FAILED);
        }

        return {
            ...withdrawal,
            status,
            processedAt: new Date().toISOString(),
            processedBy: 'admin', // Placeholder for admin ID
            updatedAt: new Date().toISOString()
        } as CommissionWithdrawal;
    } catch (error) {
        if (error instanceof AppError) throw error;
        throw new AppError(500, 'Failed to update commission withdrawal status', errorCodes.COMMISSION_WITHDRAWAL_UPDATE_FAILED);
    }
}

export async function getWithdrawalHistory(
    affiliateId: string,
    options: {
        limit?: number;
        offset?: number;
        startDate?: Date;
        endDate?: Date;
    } = {}
): Promise<{
    withdrawals: CommissionWithdrawal[];
    total: number;
    totalAmount: number;
}> {
    try {
        let query = supabase.from(commissionWithdrawalsTable).select('*').eq('affiliateId', affiliateId).order('requestedAt', { ascending: false });

        if (options.startDate) {
            query = query.gte('requestedAt', options.startDate.toISOString());
        }

        if (options.endDate) {
            query = query.lte('requestedAt', options.endDate.toISOString());
        }

        if (options.limit) {
            query = query.limit(options.limit);
        }

        if (options.offset) {
            query = query.range(options.offset, options.offset + (options.limit || 50) - 1);
        }

        const { data: withdrawals, error: withdrawalsError } = await query;

        if (withdrawalsError) {
            throw new AppError(500, 'Failed to fetch withdrawal history', errorCodes.COMMISSION_WITHDRAWAL_FETCH_FAILED);
        }

        const total = withdrawals.length;
        const totalAmount = withdrawals.reduce((sum: any, withdrawal: { amount: any; }) => sum + withdrawal.amount, 0);

        return {
            withdrawals: withdrawals as CommissionWithdrawal[],
            total,
            totalAmount
        };
    } catch (error) {
        throw new AppError(500, 'Failed to fetch withdrawal history', errorCodes.COMMISSION_WITHDRAWAL_FETCH_FAILED);
    }
}

export async function getPendingWithdrawals(
    options: {
        limit?: number;
        offset?: number;
    } = {}
): Promise<{
    withdrawals: (CommissionWithdrawal & { affiliate: Pick<Affiliate, 'firstName' | 'lastName' | 'email' | 'phoneNumber'> })[];
    total: number;
    totalAmount: number;
}> {
    try {
        let query = supabase.from(commissionWithdrawalsTable).select('*').eq('status', PayoutStatus.PENDING).order('requestedAt', { ascending: false });

        if (options.limit) {
            query = query.limit(options.limit);
        }

        if (options.offset) {
            query = query.range(options.offset, options.offset + (options.limit || 50) - 1);
        }

        const { data: withdrawals, error: withdrawalsError } = await query;

        if (withdrawalsError) {
            throw new AppError(500, 'Failed to fetch pending withdrawals', errorCodes.COMMISSION_WITHDRAWAL_FETCH_FAILED);
        }

        const affiliateIds = withdrawals.map((withdrawal: { affiliateId: any; }) => withdrawal.affiliateId);
        const { data: affiliates, error: affiliatesError } = await supabase
            .from(affiliatesTable)
            .select('*')
            .in('id', affiliateIds);

        if (affiliatesError) {
            throw new AppError(500, 'Failed to fetch affiliates', errorCodes.AFFILIATE_FETCH_FAILED);
        }

        const affiliateMap = new Map(affiliates.map((affiliate: Affiliate) => [affiliate.id, affiliate]));

        const withdrawalsWithAffiliate = withdrawals.map((withdrawal: CommissionWithdrawal) => ({
            ...withdrawal,
            affiliate: affiliateMap.get(withdrawal.affiliateId) as Pick<Affiliate, 'firstName' | 'lastName' | 'email' | 'phoneNumber'>
        }));

        const total = withdrawals.length;
        const totalAmount = withdrawals.reduce((sum: any, withdrawal: { amount: any; }) => sum + withdrawal.amount, 0);

        return {
            withdrawals: withdrawalsWithAffiliate as (CommissionWithdrawal & { affiliate: Pick<Affiliate, 'firstName' | 'lastName' | 'email' | 'phoneNumber'> })[],
            total,
            totalAmount
        };
    } catch (error) {
        throw new AppError(500, 'Failed to fetch pending withdrawals', errorCodes.COMMISSION_WITHDRAWAL_FETCH_FAILED);
    }
}

export async function processWithdrawal(
    withdrawalId: string,
    adminId: string,
    status: PayoutStatus,
    notes?: string
): Promise<void> {
    try {
        const { data: withdrawal, error: withdrawalError } = await supabase
            .from(commissionWithdrawalsTable)
            .select('*')
            .eq('id', withdrawalId)
            .single();

        if (withdrawalError) {
            throw new AppError(404, 'Commission withdrawal not found', errorCodes.COMMISSION_WITHDRAWAL_NOT_FOUND);
        }

        const { error } = await supabase
            .from(commissionWithdrawalsTable)
            .update({
                status,
                processedAt: new Date().toISOString(),
                processedBy: adminId,
                notes,
                updatedAt: new Date().toISOString()
            })
            .eq('id', withdrawalId);

        if (error) {
            throw new AppError(500, 'Failed to process commission withdrawal', errorCodes.COMMISSION_WITHDRAWAL_UPDATE_FAILED);
        }
    } catch (error) {
        if (error instanceof AppError) throw error;
        throw new AppError(500, 'Failed to process commission withdrawal', errorCodes.COMMISSION_WITHDRAWAL_UPDATE_FAILED);
    }
}
