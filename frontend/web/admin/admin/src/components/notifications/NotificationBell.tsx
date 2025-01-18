import { useState } from 'react';
import { useNotifications } from '../../hooks/useNotifications';
import { colors } from '../../theme/colors';
import { Bell, Check } from 'react-feather';

export const NotificationBell = () => {
  const { notifications, unreadCount, markAsRead } = useNotifications();
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div style={{ position: 'relative' }}>
      <button
        onClick={() => setIsOpen(!isOpen)}
        style={{
          position: 'relative',
          padding: '8px',
          background: 'none',
          border: 'none',
          cursor: 'pointer'
        }}
      >
        <Bell size={20} color={colors.gray700} />
        {unreadCount > 0 && (
          <span style={{
            position: 'absolute',
            top: 0,
            right: 0,
            backgroundColor: colors.error,
            color: colors.white,
            borderRadius: '50%',
            padding: '2px 6px',
            fontSize: '12px',
            minWidth: '18px'
          }}>
            {unreadCount}
          </span>
        )}
      </button>

      {isOpen && (
        <div style={{
          position: 'absolute',
          right: 0,
          top: '100%',
          width: '320px',
          backgroundColor: colors.white,
          borderRadius: '12px',
          boxShadow: '0 4px 12px rgba(0,0,0,0.1)',
          marginTop: '8px',
          maxHeight: '400px',
          overflowY: 'auto',
          zIndex: 1000
        }}>
          {notifications.length === 0 ? (
            <div style={{ padding: '16px', textAlign: 'center', color: colors.gray500 }}>
              No notifications
            </div>
          ) : (
            notifications.map(notification => (
              <div
                key={notification.id}
                style={{
                  padding: '16px',
                  borderBottom: `1px solid ${colors.gray200}`,
                  backgroundColor: notification.read ? colors.white : colors.gray50,
                  cursor: 'pointer'
                }}
                onClick={() => markAsRead(notification.id)}
              >
                <div style={{ 
                  display: 'flex', 
                  justifyContent: 'space-between', 
                  alignItems: 'flex-start' 
                }}>
                  <p style={{ 
                    margin: 0,
                    color: colors.gray800,
                    fontSize: '14px'
                  }}>
                    {notification.message}
                  </p>
                  {notification.read && (
                    <Check size={16} color={colors.success} />
                  )}
                </div>
                <small style={{ 
                  color: colors.gray500,
                  fontSize: '12px'
                }}>
                  {new Date(notification.createdAt).toLocaleString()}
                </small>
              </div>
            ))
          )}
        </div>
      )}
    </div>
  );
};
