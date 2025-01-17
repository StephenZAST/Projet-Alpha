import { Navigate } from 'react-router-dom';
import { usePermissions } from '../../hooks/usePermissions';
import { UserRole } from '../../types/auth';

interface RoleGuardProps {
  children: React.ReactNode;
  allowedRoles: UserRole[];
  resource?: string;
  action?: string;
}

export const RoleGuard: React.FC<RoleGuardProps> = ({ 
  children, 
  allowedRoles,
  resource,
  action 
}) => {
  const { checkRole, hasPermission } = usePermissions();
  
  if (!checkRole(allowedRoles)) {
    return <Navigate to="/unauthorized" />;
  }

  if (resource && action && !hasPermission(resource, action)) {
    return <Navigate to="/unauthorized" />;
  }

  return <>{children}</>;
};
