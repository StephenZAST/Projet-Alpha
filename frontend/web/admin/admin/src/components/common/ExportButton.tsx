import { Button } from './Button';
import { exportToCSV, exportToPDF } from '../../utils/export';
import { Download } from 'react-feather';

type ExportData = Record<string, string | number | boolean | Date | null>;

interface ExportButtonProps<T extends ExportData> {
  data: T[];
  filename: string;
  type: 'csv' | 'pdf';
  columns?: (keyof T)[];
  label?: string;
}

export const ExportButton = <T extends ExportData>({ 
  data, 
  filename, 
  type = 'csv',
  columns,
  label = `Export ${type.toUpperCase()}`
}: ExportButtonProps<T>) => {
  const handleExport = () => {
    if (!data.length) return;

    try {
      if (type === 'csv') {
        exportToCSV(data, filename);
      } else if (type === 'pdf' && columns) {
        exportToPDF(data, filename, columns as string[]);
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
