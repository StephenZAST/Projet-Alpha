import { Container, Grid } from '@mui/material';
import { motion } from 'framer-motion';
import {
  AnalyticsSummary,
  CommissionChart,
  WithdrawalForm,
  CommissionHistory,
  AffiliateCodeDisplay
} from 'src/sections/affiliate';

export default function AffiliateDashboard() {
  return (
    <Container maxWidth="xl" sx={{ py: 3 }}>
      <Grid container spacing={3}>
        <Grid item xs={12}>
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.3 }}
          >
            <AffiliateCodeDisplay />
          </motion.div>
        </Grid>
        <Grid item xs={12}>
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.3 }}
          >
            <AnalyticsSummary />
          </motion.div>
        </Grid>
        <Grid item xs={12}>
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.3 }}
          >
            <CommissionHistory />
          </motion.div>
        </Grid>
      </Grid>
    </Container>
  );
}
