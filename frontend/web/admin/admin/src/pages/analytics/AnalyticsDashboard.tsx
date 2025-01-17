import { useState } from 'react';
import { LineChart } from '../../components/charts/LineChart';
import { useAnalytics } from '../../hooks/useAnalytics';
import { colors } from '../../theme/colors';
import { Button } from '../../components/common/Button';
import { TimeFrame } from '../../types/analytics';

const timeframeOptions: TimeFrame[] = ['daily', 'weekly', 'monthly', 'yearly'];

export const AnalyticsDashboard = () => {
  const [timeframe, setTimeframe] = useState<TimeFrame>('monthly');
  const { data, loading, error } = useAnalytics(timeframe);

  if (loading) {
    return <div style={{ padding: '24px' }}>Loading analytics...</div>;
  }

  if (error) {
    return (
      <div style={{ padding: '24px', color: colors.error }}>
        {error}
      </div>
    );
  }

  return (
    <div style={{ padding: '24px' }}>
      <div style={{ 
        display: 'flex', 
        justifyContent: 'space-between', 
        alignItems: 'center',
        marginBottom: '24px' 
      }}>
        <h1>Analytics Dashboard</h1>
        <div style={{ 
          display: 'flex', 
          gap: '12px',
          backgroundColor: colors.white,
          padding: '8px',
          borderRadius: '8px'
        }}>
          {timeframeOptions.map(option => (
            <Button
              key={option}
              variant={timeframe === option ? 'primary' : 'secondary'}
              onClick={() => setTimeframe(option)}
            >
              {option.charAt(0).toUpperCase() + option.slice(1)}
            </Button>
          ))}
        </div>
      </div>

      <div style={{ 
        display: 'grid', 
        gridTemplateColumns: 'repeat(auto-fit, minmax(400px, 1fr))', 
        gap: '24px' 
      }}>
        <div style={{ 
          backgroundColor: colors.white, 
          padding: '24px', 
          borderRadius: '12px',
          boxShadow: '0 1px 3px rgba(0,0,0,0.1)'
        }}>
          <h3 style={{ marginBottom: '16px' }}>Revenue Trends</h3>
          <LineChart 
            data={data.map(item => ({
              date: item.date,
              value: item.revenue
            }))}
            dataKey="value"
            label="Revenue"
          />
        </div>

        <div style={{ 
          backgroundColor: colors.white, 
          padding: '24px', 
          borderRadius: '12px',
          boxShadow: '0 1px 3px rgba(0,0,0,0.1)'
        }}>
          <h3 style={{ marginBottom: '16px' }}>Orders Analytics</h3>
          <LineChart 
            data={data.map(item => ({
              date: item.date,
              value: item.orders
            }))}
            dataKey="value"
            label="Orders"
          />
        </div>
      </div>
    </div>
  );
};
