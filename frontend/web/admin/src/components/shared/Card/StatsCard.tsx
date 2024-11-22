import React from 'react';
import {
  Card,
  CardContent,
  Typography,
  Box,
  IconButton,
  useTheme,
} from '@mui/material';
import { SvgIconComponent } from '@mui/icons-material';
import TrendingUpIcon from '@mui/icons-material/TrendingUp';
import TrendingDownIcon from '@mui/icons-material/TrendingDown';

interface StatsCardProps {
  title: string;
  value: string | number;
  icon: SvgIconComponent;
  color?: 'primary' | 'secondary' | 'error' | 'warning' | 'info' | 'success';
  percentage?: number;
  subtitle?: string;
}

const StatsCard: React.FC<StatsCardProps> = ({
  title,
  value,
  icon: Icon,
  color = 'primary',
  percentage,
  subtitle,
}) => {
  const theme = useTheme();

  return (
    <Card
      sx={{
        height: '100%',
        position: 'relative',
        overflow: 'visible',
        '&:hover': {
          boxShadow: theme.shadows[8],
          transform: 'translateY(-4px)',
          transition: 'all 0.3s ease',
        },
      }}
    >
      <Box
        sx={{
          position: 'absolute',
          top: -20,
          right: 20,
          height: 60,
          width: 60,
          borderRadius: '50%',
          backgroundColor: theme.palette[color].main,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          boxShadow: theme.shadows[4],
        }}
      >
        <IconButton sx={{ color: 'white' }}>
          <Icon />
        </IconButton>
      </Box>

      <CardContent sx={{ pt: 4 }}>
        <Typography variant="h6" color="textSecondary" gutterBottom>
          {title}
        </Typography>

        <Typography variant="h4" component="div" gutterBottom>
          {value}
        </Typography>

        {percentage !== undefined && (
          <Box
            sx={{
              display: 'flex',
              alignItems: 'center',
              color:
                percentage >= 0
                  ? theme.palette.success.main
                  : theme.palette.error.main,
            }}
          >
            {percentage >= 0 ? <TrendingUpIcon /> : <TrendingDownIcon />}
            <Typography variant="body2" component="span" sx={{ ml: 0.5 }}>
              {Math.abs(percentage)}%
            </Typography>
          </Box>
        )}

        {subtitle && (
          <Typography
            variant="body2"
            color="textSecondary"
            sx={{ mt: 1 }}
          >
            {subtitle}
          </Typography>
        )}
      </CardContent>
    </Card>
  );
};

export default StatsCard;
