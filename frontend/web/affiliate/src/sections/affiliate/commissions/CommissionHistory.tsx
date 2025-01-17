import {
  Card,
  Table,
  TableRow,
  TableBody,
  TableCell,
  TableHead,
  TableContainer,
  Chip,
  Pagination,
  Box
} from '@mui/material';
import { useQuery } from '@tanstack/react-query';
import { AffiliateApi } from '../api/affiliate.api';

export function CommissionHistory() {
  const [page, setPage] = useState(1);
  const rowsPerPage = 10;

  const { data, isLoading } = useQuery({
    queryKey: ['commissions', page],    
    queryFn: () => AffiliateApi.getCommissions(page, rowsPerPage)
  });

  if (isLoading) return <LoadingScreen />;

  return (
    <Card>
      <TableContainer>
        // ...existing code...
      </TableContainer>
      <Box sx={{ p: 2, display: 'flex', justifyContent: 'center' }}>
        <Pagination 
          count={Math.ceil((data?.total || 0) / rowsPerPage)}
          page={page}
          onChange={(_, newPage) => setPage(newPage)}
        />
      </Box>
    </Card>
  );
}
