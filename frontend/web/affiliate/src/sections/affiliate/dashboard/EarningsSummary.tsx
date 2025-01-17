import { Card, Stack, Typography } from '@mui/material';
import { useQuery } from '@tanstack/react-query';

export function EarningsSummary() {
  const { data } = useQuery({
    queryKey: ['affiliateStats'],
    queryFn: () => api.getDashboardStats()
  });

  return (
    <Card sx={{ p: 3 }}>
      <Stack spacing={2}>
        <Typography variant="h6">Gains</Typography>
        <Typography variant="h3">
          {data?.totalEarned.toFixed(2)} €
        </Typography>
        <Typography variant="body2" color="text.secondary">
          Ce mois: {data?.monthlyEarnings.toFixed(2)} €
        </Typography>
      </Stack>
    </Card>
  );
}
