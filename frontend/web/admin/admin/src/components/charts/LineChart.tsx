import { 
  ResponsiveContainer, 
  LineChart as ReChart, 
  Line, 
  XAxis, 
  YAxis, 
  Tooltip, 
  CartesianGrid,
  Legend
} from 'recharts';
import { colors } from '../../theme/colors';

interface LineChartProps {
  data: Array<{ date: string; value: number }>;
  dataKey: string;
  label: string;
  height?: number;
}

export const LineChart: React.FC<LineChartProps> = ({ 
  data, 
  dataKey, 
  label,
  height = 300 
}) => {
  return (
    <ResponsiveContainer width="100%" height={height}>
      <ReChart data={data} margin={{ top: 10, right: 30, left: 0, bottom: 0 }}>
        <CartesianGrid 
          strokeDasharray="3 3" 
          stroke={colors.gray200} 
          vertical={false}
        />
        <XAxis 
          dataKey="date" 
          stroke={colors.gray600}
          tick={{ fontSize: 12 }}
        />
        <YAxis 
          stroke={colors.gray600}
          tick={{ fontSize: 12 }}
        />
        <Tooltip
          contentStyle={{
            backgroundColor: colors.white,
            border: `1px solid ${colors.gray200}`,
            borderRadius: '8px',
            padding: '12px'
          }}
          labelStyle={{ color: colors.gray700 }}
        />
        <Legend />
        <Line
          type="monotone"
          dataKey={dataKey}
          name={label}
          stroke={colors.primary}
          strokeWidth={2}
          dot={{ fill: colors.primary }}
          activeDot={{ r: 6, fill: colors.primary }}
        />
      </ReChart>
    </ResponsiveContainer>
  );
};
