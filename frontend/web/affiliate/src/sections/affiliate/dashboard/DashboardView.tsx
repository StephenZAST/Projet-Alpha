import { Container, Grid } from '@mui/material';
import { AffiliateCodeCard } from './AffiliateCodeCard';
import { EarningsSummary } from './EarningsSummary';
import { RecentReferrals } from './RecentReferrals';

export default function DashboardView() {
  return (
    <Container>
      <Grid container spacing={3}>
        <Grid item xs={12}>
          <AffiliateCodeCard />
        </Grid>
        <Grid item xs={12}>
          <EarningsSummary />
        </Grid>
        <Grid item xs={12}>
          <RecentReferrals />
        </Grid>
      </Grid>
    </Container>
  );
}
