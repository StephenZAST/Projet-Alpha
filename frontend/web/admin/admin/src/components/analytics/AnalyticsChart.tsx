import { Line, Bar } from 'react-chartjs-2';
import { colors } from '../../theme/colors';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  Title,
  Tooltip,
  Legend,
  ChartOptions
} from 'chart.js';

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  Title,
  Tooltip,
  Legend
);

interface AnalyticsChartProps {
  data: {
    labels: string[];
    datasets: {
      label: string;
      data: number[];
      borderColor?: string;
      backgroundColor?: string;
    }[];
  };
  type?: 'line' | 'bar';
  title?: string;
  height?: number;
}

export const AnalyticsChart = ({ data, type = 'line', title, height = 300 }: AnalyticsChartProps) => {
  const options: ChartOptions<'line' | 'bar'> = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        position: 'top' as const,
      },
      title: {
        display: !!title,
        text: title || ''
      }
    },
    scales: {
      y: {
        beginAtZero: true,
        grid: {
          color: colors.gray200
        }
      },
      x: {
        grid: {
          display: false
        }
      }
    }
  };

  const ChartComponent = type === 'line' ? Line : Bar;

  return (
    <div style={{ height }}>
      <ChartComponent options={options} data={data} />
    </div>
  );
};
