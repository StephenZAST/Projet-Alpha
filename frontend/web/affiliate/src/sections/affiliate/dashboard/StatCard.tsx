import { Card, Typography, Stack } from '@mui/material';

export function StatCard({ title, value, icon }: StatCardProps) {
  return (
    <Card sx={{ p: 3 }}>
      <Stack direction="row" justifyContent="space-between">
        <Stack>
          <Typography variant="h6">{value}</Typography>
          <Typography color="text.secondary">{title}</Typography>
        </Stack>
        {icon}
      </Stack>
    </Card>
  );
}
