import React from 'react';
import {
  Paper,
  Typography,
  List,
  ListItem,
  ListItemText,
  ListItemIcon,
  ListItemAvatar,
  Avatar,
  Chip,
  Box,
} from '@mui/material';
import {
  Person as PersonIcon,
  ShoppingCart as OrderIcon,
  LocalShipping as DeliveryIcon,
  Settings as SettingsIcon,
} from '@mui/icons-material';

interface Activity {
  id: string;
  type: 'user' | 'order' | 'delivery' | 'system';
  description: string;
  timestamp: string;
  user: string;
}

interface RecentActivitiesProps {
  activities: Activity[];
}

const RecentActivities: React.FC<RecentActivitiesProps> = ({ activities }) => {
  const getIcon = (type: Activity['type']) => {
    switch (type) {
      case 'user':
        return <PersonIcon />;
      case 'order':
        return <OrderIcon />;
      case 'delivery':
        return <DeliveryIcon />;
      case 'system':
        return <SettingsIcon />;
    }
  };

  const getColor = (type: Activity['type']) => {
    switch (type) {
      case 'user':
        return 'primary';
      case 'order':
        return 'success';
      case 'delivery':
        return 'warning';
      case 'system':
        return 'error';
    }
  };

  return (
    <Paper
      sx={{
        p: 3,
        height: '100%',
        borderRadius: 2,
        boxShadow: 3,
      }}
    >
      <Typography variant="h6" gutterBottom>
        Activités Récentes
      </Typography>

      <List>
        {activities.map((activity) => (
          <ListItem
            key={activity.id}
            sx={{
              borderBottom: '1px solid',
              borderColor: 'divider',
              '&:last-child': {
                borderBottom: 'none',
              },
            }}
          >
            <ListItemAvatar>
              <Avatar sx={{ bgcolor: `${getColor(activity.type)}.light` }}>
                {getIcon(activity.type)}
              </Avatar>
            </ListItemAvatar>
            <ListItemText
              primary={activity.description}
              secondary={
                <Box
                  sx={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: 1,
                    mt: 0.5,
                  }}
                >
                  <Typography variant="caption" color="text.secondary">
                    {new Date(activity.timestamp).toLocaleString('fr-FR')}
                  </Typography>
                  <Chip
                    label={activity.user}
                    size="small"
                    color={getColor(activity.type)}
                    variant="outlined"
                  />
                </Box>
              }
            />
          </ListItem>
        ))}
      </List>
    </Paper>
  );
};

export default RecentActivities;
