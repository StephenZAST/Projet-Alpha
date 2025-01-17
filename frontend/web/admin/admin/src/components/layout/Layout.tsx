import React, { useState } from 'react';
import { Header } from './Header';
import { Sidebar } from './Sidebar';
import { Menu, X } from 'react-feather';
import { colors } from '../../theme/colors';
import { mediaQueries } from '../../theme/breakpoints';

interface LayoutProps {
  children: React.ReactNode;
}

export const Layout: React.FC<LayoutProps> = ({ children }) => {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  const toggleMenu = () => setIsMobileMenuOpen(!isMobileMenuOpen);

  return (
    <div style={{
      display: 'grid',
      gridTemplateColumns: '240px 1fr',
      minHeight: '100vh',
      [`${mediaQueries.mobile}`]: {
        gridTemplateColumns: '1fr'
      }
    }}>
      {/* Mobile Menu Button */}
      <button
        onClick={toggleMenu}
        style={{
          display: 'none',
          [`${mediaQueries.mobile}`]: {
            display: 'flex',
            position: 'fixed',
            top: '12px',
            right: '12px',
            zIndex: 1000,
            padding: '8px',
            backgroundColor: colors.white,
            border: 'none',
            borderRadius: '8px',
            boxShadow: '0 2px 4px rgba(0,0,0,0.1)',
            cursor: 'pointer'
          }
        }}
      >
        {isMobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
      </button>

      {/* Sidebar */}
      <aside style={{
        [`${mediaQueries.mobile}`]: {
          position: 'fixed',
          left: isMobileMenuOpen ? '0' : '-240px',
          top: 0,
          bottom: 0,
          zIndex: 999,
          transition: 'left 0.3s ease'
        }
      }}>
        <Sidebar />
      </aside>

      {/* Main Content */}
      <main style={{
        padding: '24px',
        [`${mediaQueries.mobile}`]: {
          padding: '16px',
          paddingTop: '64px' // Space for mobile menu button
        }
      }}>
        <Header />
        {children}
      </main>

      {/* Mobile Overlay */}
      {isMobileMenuOpen && (
        <div
          onClick={() => setIsMobileMenuOpen(false)}
          style={{
            position: 'fixed',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            backgroundColor: 'rgba(0,0,0,0.5)',
            zIndex: 998
          }}
        />
      )}
    </div>
  );
};