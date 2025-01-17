import {
  Card,
  Table,
  TableRow,
  TableBody,
  TableCell,
  TableHead,
  CardHeader,
  TableContainer,
} from '@mui/material';
import { useQuery } from '@tanstack/react-query';
import { AffiliateApi } from '../api/affiliate.api';

export function ReferralList() {
  const { data: referralData } = useQuery({
    queryKey: ['recentReferrals'],
    queryFn: () => AffiliateApi.getReferrals(1, 5) // Get most recent 5
  });

  const referrals = referralData?.data || [];

  return (
    <Card>
      // ...existing code...
    </Card>
  );
}
