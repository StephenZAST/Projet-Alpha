import { NavLink } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';
import { colors } from '../../theme/colors';
import { hasPermission } from '../../types/auth';

export const Sidebar = () => {
  const { state } = useAuth();
  const role = state.user?.role;

  const menuItems = [
    { 
      path: '/dashboard', 
      label: 'Dashboard',
      roles: ['SUPER_ADMIN', 'ADMIN', 'DELIVERY']
    },
    { 
      path: '/orders', 
      label: 'Orders',
      roles: ['SUPER_ADMIN', 'ADMIN', 'DELIVERY'],
      resource: 'orders',
      action: 'read'
    },
    { 
      path: '/affiliates', 
      label: 'Affiliates',
      roles: ['SUPER_ADMIN', 'ADMIN'],
      resource: 'affiliates',
      action: 'read'
    },
    { 
      path: '/users', 
      label: 'Users',
      roles: ['SUPER_ADMIN'],
      resource: 'users',
      action: 'read'
    }
  ];

  return (
    <aside style={{
      width: '240px',
      backgroundColor: colors.white,
      borderRight: `1px solid ${colors.gray200}`,
      height: '100vh',
      padding: '24px'
    }}>
      {menuItems
        .filter(item => 
          item.roles.includes(role!) && 
          (!item.resource || !item.action || 
            hasPermission(role!, item.resource, item.action))
        )
        .map(item => (
          <NavLink
            key={item.path}
            to={item.path}
            style={({ isActive }) => ({
              display: 'block',
              padding: '12px',
              color: isActive ? colors.primary : colors.gray700,
              backgroundColor: isActive ? colors.gray50 : 'transparent',
              borderRadius: '8px',
              textDecoration: 'none',
              marginBottom: '8px'
            })}
          >
            {item.label}
          </NavLink>
        ))}
    </aside>
  );
};