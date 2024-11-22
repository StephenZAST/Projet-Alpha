import { FC, useEffect, useState } from 'react';
import { Box, Grid, Typography } from '@mui/material';
import {
  People as PeopleIcon,
  LocalLaundryService as LaundryIcon,
  AttachMoney as MoneyIcon,
  Assignment as AssignmentIcon,
} from '@mui/icons-material';
import StatCard from './components/StatCard';
import ActivityChart from './components/ActivityChart';
import RecentActivities from './components/RecentActivities';
import adminService from '../../../../../services/admin.service';
import logsService from '../../../../../services/logs.service';

interface DashboardStats {
  totalAdmins: number;
  activeOrders: number;
  monthlyRevenue: number;
  totalLogs: number;
  adminTrend: number;
  ordersTrend: number;
  revenueTrend: number;
}

interface Activity {
  id: string;
  type: 'user' | 'order' | 'delivery' | 'system';
  description: string;
  timestamp: string;
  user: string;
}

const Dashboard: FC = () => {
  const [stats, setStats] = useState<DashboardStats>({
    totalAdmins: 0,
    activeOrders: 0,
    monthlyRevenue: 0,
    totalLogs: 0,
    adminTrend: 0,
    ordersTrend: 0,
    revenueTrend: 0,
  });

  const [activities, setActivities] = useState<Activity[]>([]);

  const [activityData, setActivityData] = useState({
    labels: [],
    datasets: [
      {
        label: 'Activité Système',
        data: [],
        borderColor: 'rgb(75, 192, 192)',
        backgroundColor: 'rgba(75, 192, 192, 0.5)',
      },
    ],
  });

  const loadDashboardData = async () => {
    try {
      // Charger les statistiques des administrateurs
      const adminStats = await adminService.getAdminStats();
      
      // Charger les logs récents
      const recentLogs = await logsService.getRecentLogs();
      
      // Mettre à jour les statistiques
      setStats({
        totalAdmins: adminStats.data.totalAdmins,
        activeOrders: adminStats.data.activeOrders,
        monthlyRevenue: adminStats.data.monthlyRevenue,
        totalLogs: recentLogs.data.length,
        adminTrend: adminStats.data.adminTrend,
        ordersTrend: adminStats.data.ordersTrend,
        revenueTrend: adminStats.data.revenueTrend,
      });

      // Transformer les logs en activités
      const transformedActivities = recentLogs.data.map((log: any) => ({
        id: log.id,
        type: log.type,
        description: log.message,
        timestamp: log.timestamp,
        user: log.user,
      }));
      setActivities(transformedActivities);

      // Préparer les données pour le graphique d'activité
      const labels = recentLogs.data.map((log: any) => 
        new Date(log.timestamp).toLocaleDateString()
      );
      const data = recentLogs.data.map((_: any, index: number) => 
        Math.floor(Math.random() * 100)
      );

      setActivityData({
        labels,
        datasets: [
          {
            label: 'Activité Système',
            data,
            borderColor: 'rgb(75, 192, 192)',
            backgroundColor: 'rgba(75, 192, 192, 0.5)',
          },
        ],
      });
    } catch (error) {
      console.error('Erreur lors du chargement des données du tableau de bord:', error);
    }
  };

  useEffect(() => {
    loadDashboardData();
    // Rafraîchir les données toutes les 5 minutes
    const interval = setInterval(loadDashboardData, 5 * 60 * 1000);
    return () => clearInterval(interval);
  }, []);

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        Tableau de Bord
      </Typography>

      <Grid container spacing={3}>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Administrateurs"
            value={stats.totalAdmins}
            icon={PeopleIcon}
            color="#1976d2"
            trend={{ value: stats.adminTrend, isPositive: stats.adminTrend > 0 }}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Commandes Actives"
            value={stats.activeOrders}
            icon={LaundryIcon}
            color="#2e7d32"
            trend={{ value: stats.ordersTrend, isPositive: stats.ordersTrend > 0 }}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Revenu Mensuel"
            value={`${stats.monthlyRevenue.toLocaleString()} FCFA`}
            icon={MoneyIcon}
            color="#ed6c02"
            trend={{ value: stats.revenueTrend, isPositive: stats.revenueTrend > 0 }}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Logs Système"
            value={stats.totalLogs}
            icon={AssignmentIcon}
            color="#9c27b0"
          />
        </Grid>

        <Grid item xs={12} md={8}>
          <ActivityChart data={activityData} />
        </Grid>

        <Grid item xs={12} md={4}>
          <RecentActivities activities={activities} />
        </Grid>
      </Grid>
    </Box>
  );
};

export default Dashboard;
