import { createAffiliate } from './affiliateController/createAffiliate';
import { getAffiliateProfile } from './affiliateController/getAffiliateProfile';
import { updateProfile } from './affiliateController/updateProfile';
import { getAffiliateStats } from './affiliateController/getAffiliateStats';
import { getPendingAffiliates } from './affiliateController/getPendingAffiliates';
import { approveAffiliate } from './affiliateController/approveAffiliate';
import { getPendingWithdrawals } from './affiliateController/getPendingWithdrawals';
import { processWithdrawal } from './affiliateController/processWithdrawal';
import { getAllAffiliates } from './affiliateController/getAllAffiliates';
import { requestCommissionWithdrawal } from './affiliateController/requestCommissionWithdrawal';
import { getCommissionWithdrawals } from './affiliateController/getCommissionWithdrawals';
import { getAnalytics } from './affiliateController/getAnalytics';
import { updateAffiliate } from './affiliateController/updateAffiliate';
import { getAffiliateById } from './affiliateController/getAffiliateById';
import { deleteAffiliate } from './affiliateController/deleteAffiliate';

const affiliateController = {
  createAffiliate,
  getAffiliateProfile,
  updateProfile,
  getAffiliateStats,
  getPendingAffiliates,
  approveAffiliate,
  getPendingWithdrawals,
  processWithdrawal,
  getAllAffiliates,
  requestCommissionWithdrawal,
  getCommissionWithdrawals,
  getAnalytics,
  updateAffiliate,
  getAffiliateById,
  deleteAffiliate
};

export default affiliateController;
