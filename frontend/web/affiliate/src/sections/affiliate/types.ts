export type PaymentMethod = 'ORANGE_MONEY' | 'MOBILE_MONEY' | 'BANK_TRANSFER';

export interface WithdrawalRequest {
  amount: number;
  paymentMethod: PaymentMethod;
  accountDetails: {
    accountName?: string;
    accountNumber?: string;
    bankName?: string;
    phoneNumber?: string;
  };
}
