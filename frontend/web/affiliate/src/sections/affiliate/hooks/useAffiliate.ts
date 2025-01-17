import { useQuery, useMutation } from '@tanstack/react-query';
import { affiliateApi } from '../api';

export const useAffiliate = () => {
  const { data: stats } = useQuery(['stats'], affiliateApi.getDashboardStats);
  const { data: commissions } = useQuery(['commissions'], affiliateApi.getCommissions);
  const { data: referrals } = useQuery(['referrals'], affiliateApi.getReferrals);

  const { mutate: withdraw } = useMutation(affiliateApi.requestWithdrawal);
  const { mutate: generateCode } = useMutation(affiliateApi.generateNewCode);

  return {
    stats,
    commissions,
    referrals,
    withdraw,
    generateCode
  };
};
