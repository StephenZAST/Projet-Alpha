import { useParams, useNavigate } from 'react-router-dom';
import { useAffiliateDetails } from '../../hooks/useAffiliateDetails';
import { colors } from '../../theme/colors';
import { Button } from '../../components/common/Button';

const MetricCard: React.FC<{ title: string; value: string | number }> = ({ title, value }) => (
  <div style={{
    backgroundColor: colors.white,
    padding: '24px',
    borderRadius: '12px',
    boxShadow: '0 1px 3px rgba(0,0,0,0.1)'
  }}>
    <h3 style={{ color: colors.gray600, marginBottom: '8px' }}>{title}</h3>
    <p style={{ fontSize: '24px', fontWeight: 600 }}>{value}</p>
  </div>
);

export const AffiliateDetails = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { affiliate, metrics, loading, error, updateStatus } = useAffiliateDetails(id!);

  if (loading) {
    return <div style={{ padding: '24px' }}>Loading affiliate details...</div>;
  }

  if (error) {
    return (
      <div style={{ padding: '24px', color: colors.error }}>
        {error}
      </div>
    );
  }

  if (!affiliate || !metrics) {
    return <div style={{ padding: '24px' }}>Affiliate not found</div>;
  }

  return (
    <div style={{ padding: '24px' }}>
      <div style={{ 
        display: 'flex', 
        justifyContent: 'space-between', 
        alignItems: 'center',
        marginBottom: '24px' 
      }}>
        <div>
          <Button 
            variant="secondary" 
            onClick={() => navigate('/affiliates')}
            style={{ marginBottom: '16px' }}
          >
            Back to Affiliates
          </Button>
          <h1>{`${affiliate.firstName} ${affiliate.lastName}`}</h1>
        </div>
        <select
          value={affiliate.status}
          onChange={(e) => updateStatus(e.target.value as AffiliateStatus)}
          style={{
            padding: '8px 16px',
            borderRadius: '8px',
            border: `1px solid ${colors.gray300}`
          }}
        >
          <option value="active">Active</option>
          <option value="pending">Pending</option>
          <option value="suspended">Suspended</option>
        </select>
      </div>

      <div style={{ 
        display: 'grid', 
        gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', 
        gap: '24px',
        marginBottom: '24px' 
      }}>
        <MetricCard title="Total Referrals" value={metrics.totalReferrals} />
        <MetricCard title="Active Referrals" value={metrics.activeReferrals} />
        <MetricCard title="Conversion Rate" value={`${metrics.conversionRate}%`} />
        <MetricCard title="Total Earnings" value={`$${affiliate.earnings.toFixed(2)}`} />
      </div>

      <div style={{ 
        backgroundColor: colors.white,
        padding: '24px',
        borderRadius: '12px',
        boxShadow: '0 1px 3px rgba(0,0,0,0.1)'
      }}>
        <h2 style={{ marginBottom: '16px' }}>Monthly Performance</h2>
        {/* Add chart or detailed metrics table here */}
        <table style={{ width: '100%', borderCollapse: 'collapse' }}>
          <thead>
            <tr>
              <th style={{ textAlign: 'left', padding: '12px' }}>Month</th>
              <th style={{ textAlign: 'right', padding: '12px' }}>Earnings</th>
            </tr>
          </thead>
          <tbody>
            {metrics.monthlyEarnings.map(({ month, amount }) => (
              <tr key={month}>
                <td style={{ padding: '12px' }}>{month}</td>
                <td style={{ padding: '12px', textAlign: 'right' }}>${amount.toFixed(2)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};
