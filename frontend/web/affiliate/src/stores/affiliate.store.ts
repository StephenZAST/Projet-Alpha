import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface AffiliateStore {
  affiliateCode: string | null;
  commissionBalance: number;
  setAffiliateData: (data: any) => void;
}

export const useAffiliateStore = create(
  persist<AffiliateStore>(
    (set) => ({
      affiliateCode: null,
      commissionBalance: 0,
      setAffiliateData: (data) => set(data)
    }),
    { name: 'affiliate-storage' }
  )
);
