import { useNavigate } from 'react-router-dom';
import { useAffiliates } from '../../hooks/useAffiliates';
import { Button } from '../../components/common/Button';
import { colors } from '../../theme/colors';
import { AffiliateStatus } from '../../types/affiliate';

const getStatusColor = (status: AffiliateStatus) => {
  const statusColors = {
    'active': colors.success,
    'pending': colors.warning,
    'suspended': colors.error
  };
  return statusColors[status];
};

export const AffiliatesList = () => {
  const navigate = useNavigate();
  const { affiliates, loading, error, updateAffiliateStatus } = useAffiliates();

  if (loading) {
    return <div style={{ padding: '24px' }}>Loading affiliates...</div>;
  }

  if (error) {
    return (
      <div style={{ padding: '24px', color: colors.error }}>
        {error}
      </div>
    );
  }

  return (
    <div style={{ padding: '24px' }}>
      <h1 style={{ marginBottom: '24px' }}>Affiliate Management</h1>
      <div style={{ 
        backgroundColor: colors.white, 
        padding: '24px', 
        borderRadius: '12px',
        boxShadow: '0 1px 3px rgba(0,0,0,0.1)'
      }}>
        <table style={{ width: '100%', borderCollapse: 'collapse' }}>
          <thead>
            <tr>
              {['Name', 'Email', 'Status', 'Earnings', 'Referral Code', 'Actions'].map(header => (
                <th key={header} style={{
                  textAlign: 'left',
                  padding: '12px',
                  borderBottom: `1px solid ${colors.gray200}`,
                  color: colors.gray600
                }}>
                  {header}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {affiliates.map(affiliate => (
              <tr key={affiliate.id}>
                <td style={{ padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>
                  {`${affiliate.firstName} ${affiliate.lastName}`}
                </td>
                <td style={{ padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>
                  {affiliate.email}
                </td>
                <td style={{ padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>
                  <select
                    value={affiliate.status}
                    onChange={(e) => updateAffiliateStatus(
                      affiliate.id, 
                      e.target.value as AffiliateStatus
                    )}
                    style={{
                      padding: '4px 8px',
                      borderRadius: '4px',
                      border: `1px solid ${colors.gray300}`,
                      color: getStatusColor(affiliate.status)
                    }}
                  >
                    <option value="active">Active</option>
                    <option value="pending">Pending</option>
                    <option value="suspended">Suspended</option>
                  </select>
                </td>
                <td style={{ padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>
                  ${affiliate.earnings.toFixed(2)}
                </td>
                <td style={{ padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>
                  {affiliate.referralCode}
                </td>
                <td style={{ padding: '12px', borderBottom: `1px solid ${colors.gray200}` }}>
                  <Button 
                    variant="secondary"
                    onClick={() => navigate(`/affiliates/${affiliate.id}`)}
                  >
                    View Details
                  </Button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};
