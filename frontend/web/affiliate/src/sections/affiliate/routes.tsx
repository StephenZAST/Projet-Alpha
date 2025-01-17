import { lazy, Suspense } from 'react';
import { CircularProgress } from '@mui/material';
import AffiliateLayout from './layout/AffiliateLayout';
import AffiliateGuard from './guards/AffiliateGuard';

const Loadable = (Component: React.ComponentType) => (props: any) => (
  <Suspense fallback={<CircularProgress />}>
    <Component {...props} />
  </Suspense>
);

const Dashboard = Loadable(lazy(() => import('./dashboard')));
const Profile = Loadable(lazy(() => import('./profile')));
const Commissions = Loadable(lazy(() => import('./commissions')));
const Referrals = Loadable(lazy(() => import('./referrals')));
const Payouts = Loadable(lazy(() => import('./payouts')));

export const affiliateRoutes = {
  path: 'affiliate',
  element: (
    <AffiliateGuard>
      <AffiliateLayout />
    </AffiliateGuard>
  ),
  children: [
    { path: '', element: <Dashboard /> },
    { path: 'profile', element: <Profile /> },
    { path: 'commissions', element: <Commissions /> },
    { path: 'referrals', element: <Referrals /> },
    { path: 'payouts', element: <Payouts /> }
  ]
};
