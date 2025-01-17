import { useQuery } from '@tanstack/react-query';

import { Grid } from '@mui/material';
import { useTheme } from '@mui/material/styles';

import { AffiliateApi } from '../api/affiliate.api';
import { StatCard } from './StatCard';
import { Iconify } from '@/components/iconify';
import { fCurrency, fNumber, fPercent } from '@/utils/format-number';

export function AnalyticsSummary() {
  const theme = useTheme();
  
  const { data: stats, isLoading } = useQuery({
    queryKey: ['affiliateStats'],
    queryFn: () => AffiliateApi.getDashboardStats()
  });

  const SUMMARY_CARDS = [
    {
      title: 'Total Gagné',
      value: fCurrency(stats?.totalEarnings || 0),
      icon: <Iconify 
        icon="solar:dollar-linear" 
        sx={{ 
          width: 48, 
          height: 48, 
          color: theme.palette.primary.main 
        }} 
      />
    },
    {
      title: 'Gains Mensuels',
      value: fCurrency(stats?.monthlyEarnings || 0),
      icon: <Iconify 
        icon="solar:chart-2-linear" 
        sx={{ 
          width: 48, 
          height: 48, 
          color: theme.palette.info.main 
        }} 
      />
    },
    {
      title: 'Parrainages',
      value: fNumber(stats?.referralsCount || 0),
      icon: <Iconify 
        icon="solar:users-group-rounded-linear" 
        sx={{ 
          width: 48, 
          height: 48, 
          color: theme.palette.success.main 
        }} 
      />
    },
    {
      title: 'Taux de Conversion',
      value: fPercent(stats?.conversionRate || 0),
      icon: <Iconify 
        icon="solar:percent-linear" 
        sx={{ 
          width: 48, 
          height: 48, 
          color: theme.palette.warning.main 
        }} 
      />
    }
  ];

  if (isLoading) {
    return (
      <Grid container spacing={3}>
        {[...Array(4)].map((_, index) => (
          <Grid key={index} item xs={12} sm={6} md={3}>
            <StatCard.Skeleton />
          </Grid>
        ))}
      </Grid>
    );
  }

  return (
    <Grid container spacing={3}>
      {SUMMARY_CARDS.map((card) => (
        <Grid key={card.title} item xs={12} sm={6} md={3}>
          <StatCard
            title={card.title}
            value={card.value}
            icon={card.icon}
          />
        </Grid>
      ))}
    </Grid>
  );
}

// Ajout du composant Skeleton pour StatCard
StatCard.Skeleton = function Skeleton() {
  return (
    <Card>
      <Stack spacing={1} sx={{ p: 3 }}>
        <Skeleton variant="text" width={100} />
        <Skeleton variant="text" width={60} />
        <Skeleton variant="circular" width={40} height={40} />
      </Stack>
    </Card>
  );
};
