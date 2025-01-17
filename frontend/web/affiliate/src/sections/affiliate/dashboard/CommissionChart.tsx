import { Card, CardHeader } from '@mui/material';
import { useQuery } from '@tanstack/react-query';
import Chart from '@/components/chart';
import { AffiliateApi } from '../api/affiliate.api';

export function CommissionChart() {
  const { data: commissions } = useQuery({
    queryKey: ['commissionHistory'],
    queryFn: () => AffiliateApi.getCommissions()
  });

  // Transform data for chart
  const chartData = transformCommissionsToChartData(commissions);

  return (
    <Card>
      <CardHeader title="Commission History" />
      <Chart 
        type="area"
        series={chartData}
        // ...existing code...
      />
    </Card>
  );
}
