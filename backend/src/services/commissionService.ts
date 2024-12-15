import { getCommission, createCommission, updateCommission, deleteCommission } from './commission/commissionManagement';
import { getCommissionRule, createCommissionRule, updateCommissionRule, deleteCommissionRule } from './commission/rules';
import { Commission, CommissionRule } from '../models/commission';
import { AppError, errorCodes } from '../utils/errors';

export class CommissionService {
  async getCommission(id: string): Promise<Commission | null> {
    return getCommission(id);
  }

  async createCommission(commissionData: Commission): Promise<Commission> {
    return createCommission(commissionData);
  }

  async updateCommission(id: string, commissionData: Partial<Commission>): Promise<Commission> {
    return updateCommission(id, commissionData);
  }

  async deleteCommission(id: string): Promise<void> {
    return deleteCommission(id);
  }

  async getCommissionRule(id: string): Promise<CommissionRule | null> {
    return getCommissionRule(id);
  }

  async createCommissionRule(ruleData: CommissionRule): Promise<CommissionRule> {
    return createCommissionRule(ruleData);
  }

  async updateCommissionRule(id: string, ruleData: Partial<CommissionRule>): Promise<CommissionRule> {
    return updateCommissionRule(id, ruleData);
  }

  async deleteCommissionRule(id: string): Promise<void> {
    return deleteCommissionRule(id);
  }
}

export const commissionService = new CommissionService();
