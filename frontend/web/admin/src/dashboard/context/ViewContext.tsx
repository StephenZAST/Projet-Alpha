import { createContext, useState, useMemo, ReactNode } from 'react';

export interface ViewContextType {
  currentView: string;
  setCurrentView: (view: string) => void;
}

export const ViewContext = createContext<ViewContextType | undefined>(undefined);

interface ViewProviderProps {
  children: ReactNode;
}

export const ViewProvider = ({ children }: ViewProviderProps) => {
  const [currentView, setCurrentView] = useState<string>('overview');

  const value = useMemo(() => ({
    currentView,
    setCurrentView
  }), [currentView]);

  return (
    <ViewContext.Provider value={value}>
      {children}
    </ViewContext.Provider>
  );
};
