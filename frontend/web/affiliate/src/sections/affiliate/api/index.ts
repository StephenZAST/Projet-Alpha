import axios from 'axios';

const api = axios.create({
  baseURL: process.env.REACT_APP_API_URL,
  headers: {
    'Content-Type': 'application/json'
  }
});

export const affiliateApi = {
  getDashboardStats: () => api.get('/affiliate/stats'),
  getCommissions: (page = 1) => api.get(`/affiliate/commissions?page=${page}`),
  requestWithdrawal: (data: WithdrawalRequest) => api.post('/affiliate/withdraw', data),
  getAffiliateCode: () => api.get('/affiliate/code'),
  generateNewCode: () => api.post('/affiliate/generate-code'),
  getReferrals: () => api.get('/affiliate/referrals')
};
