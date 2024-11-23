import React from 'react';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  ChartData,
  ChartOptions,
} from 'chart.js';
import { Line } from 'react-chartjs-2';
import { Box, Paper, Typography, useTheme } from '@mui/material';

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend
);

interface LineChartProps {
  title?: string;
  data: ChartData<'line'>;
  height?: number;
  options?: ChartOptions<'line'>;
}

const LineChart: React.FC<LineChartProps> = ({
  title,
  data,
  height = 350,
  options,
}) => {
  const theme = useTheme();

  const defaultOptions: ChartOptions<'line'> = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        position: 'top' as const,
        labels: {
          color: theme.palette.text.primary,
        },
      },
      title: {
        display: false,
      },
    },
    scales: {
      x: {
        grid: {
          color: theme.palette.divider,
        },
        ticks: {
          color: theme.palette.text.secondary,
        },
      },
      y: {
        grid: {
          color: theme.palette.divider,
        },
        ticks: {
          color: theme.palette.text.secondary,
        },
      },
    },
  };

  return (
    <Paper
      sx={{
        p: 3,
        height: '100%',
        '&:hover': {
          boxShadow: theme.shadows[8],
          transition: 'box-shadow 0.3s ease-in-out',
        },
      }}
    >
      {title && (
        <Typography variant="h6" gutterBottom>
          {title}
        </Typography>
      )}
      <Box sx={{ height }}>
        <Line options={{ ...defaultOptions, ...options }} data={data} />
      </Box>
    </Paper>
  );
};

export default LineChart;
