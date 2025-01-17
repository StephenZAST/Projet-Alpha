import React from 'react';
import { colors } from '../../theme/colors';
import { Button } from '../common/Button';

interface Props {
  children: React.ReactNode;
  fallback?: React.ReactNode;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

export class ErrorBoundary extends React.Component<Props, State> {
  state: State = { hasError: false, error: null };

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
  }

  handleReset = () => {
    this.setState({ hasError: false, error: null });
  };

  render() {
    if (this.state.hasError) {
      return this.props.fallback || (
        <div style={{ 
          padding: '24px', 
          textAlign: 'center',
          maxWidth: '500px',
          margin: '48px auto'
        }}>
          <h2 style={{ color: colors.error, marginBottom: '16px' }}>
            Something went wrong
          </h2>
          <p style={{ 
            color: colors.gray600, 
            marginBottom: '24px' 
          }}>
            {this.state.error?.message}
          </p>
          <Button onClick={this.handleReset}>
            Try Again
          </Button>
        </div>
      );
    }

    return this.props.children;
  }
}
