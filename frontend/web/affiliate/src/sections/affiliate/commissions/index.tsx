import { Container, Grid } from '@mui/material';
import { CommissionHistory } from './CommissionHistory';
import { WithdrawalForm } from './WithdrawalForm';
import { useQuery } from '@tanstack/react-query';

export default function CommissionsPage() {
  const { data: stats } = useQuery({
    queryKey: ['affiliateStats'],
    queryFn: AffiliateApi.getDashboardStats
  });

  return (
    <Container maxWidth={false}>
      <Grid container spacing={3}>
        <Grid item xs={12} md={8}>
          <CommissionHistory />
        </Grid>
        
        <Grid item xs={12} md={4}>
          <WithdrawalForm 
            availableBalance={stats?.totalCommissions || 0}
          />
        </Grid>
      </Grid>
    </Container>
  );
}
