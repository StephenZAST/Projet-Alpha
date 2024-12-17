export enum RewardRedemptionStatus {
  PENDING = 'PENDING',
  CLAIMED = 'CLAIMED',
  CANCELLED = 'CANCELLED'
}

export interface RewardRedemption {
  id?: string;
  userId: string;
  rewardId: string;
  transactionId: string;
  status: RewardRedemptionStatus;
  notes?: string;
  createdAt: string;
  updatedAt?: string;
}
