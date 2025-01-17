import axios from '../../../utils/axios'; // Utiliser l'instance axios existante
import { AffiliateStats, CommissionData, WithdrawalRequest, TrackingStats } from '../types';

const BASE_URL = process.env.REACT_APP_API_URL;

export class AffiliateApi {
  static async getDashboardStats(): Promise<AffiliateStats> {
    const { data } = await axios.get('/affiliate/dashboard');
    return data;
  }

  static async getCommissionHistory(params: any): Promise<CommissionData> {
    const { data } = await axios.get(`${BASE_URL}/affiliate/commissions`, { params });
    return data;
  }

  static async requestWithdrawal(request: WithdrawalRequest): Promise<void> {
    await axios.post(`${BASE_URL}/affiliate/withdrawals`, request);
  }

  static async getBalance(): Promise<{ available: number; pending: number }> {
    const { data } = await axios.get(`${BASE_URL}/affiliate/balance`);
    return data;
  }

  static async getTrackingStats(): Promise<TrackingStats> {
    const { data } = await axios.get(`${BASE_URL}/affiliate/tracking/stats`);
    return data;
  }
}
