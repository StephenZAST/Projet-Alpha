import { useQuery } from '@tanstack/react-query';

import { Card, Stack, Typography, Button } from '@mui/material';

export function AffiliateCodeCard() {
  const { data } = useQuery({
    queryKey: ['affiliateProfile'],
    queryFn: () => api.getProfile()
  });

  const handleCopy = () => {
    navigator.clipboard.writeText(data?.affiliateCode || '');
  };

  return (
    <Card sx={{ p: 3 }}>
      <Stack spacing={2}>
        <Typography variant="h6">Votre Code Affilié</Typography>
        <Typography variant="h4">{data?.affiliateCode}</Typography>
        <Button onClick={handleCopy} variant="contained">
          Copier le code
        </Button>
      </Stack>
    </Card>
  );
}
