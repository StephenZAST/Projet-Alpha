import { FC, useEffect, useState } from 'react';
import {
  Box,
  Typography,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  TablePagination,
  Chip,
  TextField,
  InputAdornment,
} from '@mui/material';
import {
  Search as SearchIcon,
  Error as ErrorIcon,
  Info as InfoIcon,
  Warning as WarningIcon,
} from '@mui/icons-material';
import { useSnackbar } from 'notistack';

interface Log {
  id: string;
  timestamp: string;
  level: 'INFO' | 'WARNING' | 'ERROR';
  message: string;
  source: string;
  user?: string;
}

const SystemLogs: FC = () => {
  const [logs, setLogs] = useState<Log[]>([]);
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [searchTerm, setSearchTerm] = useState('');
  const [totalLogs, setTotalLogs] = useState(0);
  const { enqueueSnackbar } = useSnackbar();

  const loadLogs = async () => {
    try {
      const response = await fetch(`/api/admin/logs?page=${page}&limit=${rowsPerPage}&search=${searchTerm}`);
      const data = await response.json();
      
      if (!response.ok) {
        throw new Error(data.message || 'Erreur lors du chargement des logs');
      }

      setLogs(data.logs);
      setTotalLogs(data.total);
    } catch (error) {
      enqueueSnackbar(error instanceof Error ? error.message : 'Erreur lors du chargement des logs', { 
        variant: 'error' 
      });
    }
  };

  useEffect(() => {
    loadLogs();
  }, [page, rowsPerPage, searchTerm]);

  const handleChangePage = (_: unknown, newPage: number) => {
    setPage(newPage);
  };

  const handleChangeRowsPerPage = (event: React.ChangeEvent<HTMLInputElement>) => {
    setRowsPerPage(parseInt(event.target.value, 10));
    setPage(0);
  };

  const getLevelIcon = (level: string) => {
    switch (level) {
      case 'ERROR':
        return <ErrorIcon color="error" />;
      case 'WARNING':
        return <WarningIcon color="warning" />;
      default:
        return <InfoIcon color="info" />;
    }
  };

  const getLevelColor = (level: string): 'error' | 'warning' | 'info' => {
    switch (level) {
      case 'ERROR':
        return 'error';
      case 'WARNING':
        return 'warning';
      default:
        return 'info';
    }
  };

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        Logs Système
      </Typography>

      <Box sx={{ mb: 3 }}>
        <TextField
          fullWidth
          variant="outlined"
          placeholder="Rechercher dans les logs..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          InputProps={{
            startAdornment: (
              <InputAdornment position="start">
                <SearchIcon />
              </InputAdornment>
            ),
          }}
        />
      </Box>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Niveau</TableCell>
              <TableCell>Date</TableCell>
              <TableCell>Message</TableCell>
              <TableCell>Source</TableCell>
              <TableCell>Utilisateur</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {logs.map((log) => (
              <TableRow key={log.id}>
                <TableCell>
                  <Chip
                    icon={getLevelIcon(log.level)}
                    label={log.level}
                    color={getLevelColor(log.level)}
                    size="small"
                  />
                </TableCell>
                <TableCell>
                  {new Date(log.timestamp).toLocaleString('fr-FR')}
                </TableCell>
                <TableCell>{log.message}</TableCell>
                <TableCell>{log.source}</TableCell>
                <TableCell>{log.user || '-'}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      <TablePagination
        component="div"
        count={totalLogs}
        page={page}
        onPageChange={handleChangePage}
        rowsPerPage={rowsPerPage}
        onRowsPerPageChange={handleChangeRowsPerPage}
        rowsPerPageOptions={[10, 25, 50, 100]}
        labelRowsPerPage="Lignes par page"
        labelDisplayedRows={({ from, to, count }) => 
          `${from}-${to} sur ${count !== -1 ? count : `plus de ${to}`}`
        }
      />
    </Box>
  );
};

export default SystemLogs;
