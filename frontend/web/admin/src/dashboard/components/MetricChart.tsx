import React from 'react';
import { Area, AreaChart, ResponsiveContainer, Tooltip, XAxis, TooltipProps } from 'recharts';
import styles from './styles/MetricChart.module.css';

interface MetricChartProps {
  data: { name: string; value: number }[];
  color: string;
}

const mockData = [
  { name: 'Jan', value: 100 },
  { name: 'Feb', value: 120 },
  { name: 'Mar', value: 140 },
  { name: 'Apr', value: 160 },
  { name: 'May', value: 180 },
  { name: 'Jun', value: 200 },
];

export const MetricChart: React.FC<MetricChartProps> = ({ 
  data = mockData, 
  color 
}) => {
  return (
    <div className={styles.chartContainer}>
      <ResponsiveContainer width="100%" height={120}>
        <AreaChart data={data}>
          <defs>
            <linearGradient id={`gradient-${color}`} x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stopColor={color} stopOpacity={0.4} />
              <stop offset="100%" stopColor={color} stopOpacity={0} />
            </linearGradient>
          </defs>
          <XAxis 
            dataKey="name" 
            hide 
            axisLine={false}
            tickLine={false}
          />
          <Tooltip 
            content={({ active, payload }: TooltipProps<number, string>) => {
              if (active && payload && payload.length) {
                return (
                  <div className={styles.tooltip}>
                    <p className={styles.tooltipValue}>
                      {payload[0].value}
                    </p>
                    <p className={styles.tooltipLabel}>
                      {payload[0].payload.name}
                    </p>
                  </div>
                );
              }
              return null;
            }}
          />
          <Area
            type="monotone"
            dataKey="value"
            stroke={color}
            fill={`url(#gradient-${color})`}
            strokeWidth={2}
          />
        </AreaChart>
      </ResponsiveContainer>
    </div>
  );
};
