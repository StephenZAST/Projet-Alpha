import React from 'react';
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer
} from 'recharts';
import styles from './Chart.module.css';

interface ChartProps {
  data: any[];
  title?: string;
  dataKey: string;
  className?: string;
  height?: number;
  showGrid?: boolean;
  gradient?: {
    from: string;
    to: string;
  };
}

export const Chart: React.FC<ChartProps> = ({
  data,
  title,
  dataKey,
  className = '',
  height = 200,
  showGrid = true,
  gradient = { from: '#6366F1', to: '#8B5CF6' }
}) => {
  return (
    <div className={`${styles.chartWrapper} ${className}`}>
      {title && <h3 className={styles.title}>{title}</h3>}
      <div className={styles.chart} style={{ height }}>
        <ResponsiveContainer width="100%" height="100%">
          <AreaChart
            data={data}
            margin={{
              top: 5,
              right: 0,
              left: 0,
              bottom: 5,
            }}
          >
            <defs>
              <linearGradient id="colorGradient" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor={gradient.from} stopOpacity={0.2}/>
                <stop offset="95%" stopColor={gradient.to} stopOpacity={0}/>
              </linearGradient>
            </defs>
            {showGrid && (
              <CartesianGrid
                strokeDasharray="3 3"
                vertical={false}
                stroke="var(--theme-border-color)"
              />
            )}
            <XAxis
              dataKey="name"
              axisLine={false}
              tickLine={false}
              tick={{ fill: 'var(--theme-text-color)', fontSize: 12 }}
            />
            <YAxis
              axisLine={false}
              tickLine={false}
              tick={{ fill: 'var(--theme-text-color)', fontSize: 12 }}
            />
            <Tooltip
              contentStyle={{
                background: 'var(--theme-card-bg)',
                border: '1px solid var(--theme-border-color)',
                borderRadius: '8px',
              }}
            />
            <Area
              type="monotone"
              dataKey={dataKey}
              stroke={gradient.from}
              fill="url(#colorGradient)"
              strokeWidth={2}
            />
          </AreaChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
};
