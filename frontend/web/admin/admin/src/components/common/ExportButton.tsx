import { Button } from './Button';
import { exportToCSV, exportToPDF } from '../../utils/export';
import { Download } from 'react-feather';

interface ExportButtonProps {
  data: any[];
  filename: string;
  type: 'csv' | 'pdf';
  columns?: string[];
  label?: string;
}

export const ExportButton: React.FC<ExportButtonProps> = ({ 
  data, 
  filename, 
  type = 'csv',
  columns,
  label = `Export ${type.toUpperCase()}`
}) => {
  const handleExport = () => {
    if (!data.length) return;

    try {
      if (type === 'csv') {
        exportToCSV(data, filename);
      } else if (type === 'pdf' && columns) {
        exportToPDF(data, filename, columns);
      }
    } catch (error) {
      console.error('Export failed:', error);
    }
  };

  return (
    <Button
      onClick={handleExport}
      variant="secondary"
      disabled={!data.length}
    >
      <Download size={16} style={{ marginRight: '8px' }} />
      {label}
    </Button>
  );
};
