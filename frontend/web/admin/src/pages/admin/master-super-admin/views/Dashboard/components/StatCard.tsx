import { FC } from 'react';
import { Paper, Box, Typography, SvgIcon } from '@mui/material';
import { SvgIconComponent } from '@mui/icons-material';

interface StatCardProps {
  title: string;
  value: string | number;
  icon: SvgIconComponent;
  color: string;
  trend?: {
    value: number;
    isPositive: boolean;
  };
}

const StatCard: FC<StatCardProps> = ({ title, value, icon: Icon, color, trend }) => {
  return (
    <Paper
      sx={{
        p: 3,
        display: 'flex',
        flexDirection: 'column',
        height: '100%',
        backgroundColor: 'background.paper',
        borderRadius: 2,
        boxShadow: 3,
      }}
    >
      <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2 }}>
        <Box>
          <Typography variant="h6" color="text.secondary" gutterBottom>
            {title}
          </Typography>
          <Typography variant="h4">{value}</Typography>
        </Box>
        <SvgIcon
          component={Icon}
          sx={{
            fontSize: 40,
            color: color,
            p: 1,
            borderRadius: '50%',
            backgroundColor: `${color}15`,
          }}
        />
      </Box>
      {trend && (
        <Box sx={{ display: 'flex', alignItems: 'center' }}>
          <Typography
            variant="body2"
            sx={{
              color: trend.isPositive ? 'success.main' : 'error.main',
              display: 'flex',
              alignItems: 'center',
            }}
          >
            {trend.isPositive ? '+' : '-'}{Math.abs(trend.value)}%
          </Typography>
          <Typography variant="body2" color="text.secondary" sx={{ ml: 1 }}>
            depuis le mois dernier
          </Typography>
        </Box>
      )}
    </Paper>
  );
};

export default StatCard;
