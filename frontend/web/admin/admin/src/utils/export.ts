import jsPDF from 'jspdf';
import 'jspdf-autotable';
import { saveAs } from 'file-saver';
import ExcelJS from 'exceljs';

interface ExportOptions {
  filename: string;
  sheetName?: string;
  title?: string;
}

export const exportToExcel = async <T extends object>(data: T[], options: ExportOptions) => {
  const workbook = new ExcelJS.Workbook();
  const worksheet = workbook.addWorksheet(options.sheetName || 'Sheet1');

  // Add headers
  const headers = Object.keys(data[0]);
  worksheet.addRow(headers);

  // Add data
  data.forEach(item => {
    worksheet.addRow(Object.values(item));
  });

  // Generate buffer
  const buffer = await workbook.xlsx.writeBuffer();
  const blob = new Blob([buffer], { 
    type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' 
  });
  saveAs(blob, `${options.filename}.xlsx`);
};

export const exportToPDF = <T extends object>(data: T[], options: ExportOptions) => {
  const doc = new jsPDF();
  const tableColumn = Object.keys(data[0]);
  const tableRows = data.map(item => Object.values(item));

  doc.text(options.title || options.filename, 14, 15);
  doc.autoTable({
    head: [tableColumn],
    body: tableRows,
    startY: 20,
    styles: { fontSize: 8 },
    headStyles: { fillColor: [0, 69, 206] }
  });

  doc.save(`${options.filename}.pdf`);
};

export const exportToCSV = <T extends object>(data: T[], options: ExportOptions) => {
  const headers = Object.keys(data[0]);
  const csvRows = [
    headers.join(','),
    ...data.map(row =>
      headers.map(header => {
        const cell = row[header]?.toString() || '';
        return cell.includes(',') ? `"${cell}"` : cell;
      }).join(',')
    )
  ];

  const blob = new Blob([csvRows.join('\n')], { type: 'text/csv;charset=utf-8;' });
  saveAs(blob, `${options.filename}.csv`);
};
