export interface MetricCardProps {
    title: string;
    value: string;
    change?: string;
    changeType?: 'positive' | 'negative' | 'neutral';
    comparison?: string;
  }
  
  export interface CustomerTableProps {
    customers: Customer[];
  }
  
  export interface Customer {
    name: string;
    company: string;
    phone: string;
    email: string;
    country: string;
    status: 'active' | 'inactive';
  }
  
  export interface PaginationProps {
    currentPage: number;
    totalPages: number;
    onPageChange: (page: number) => void;
  }
  
  export interface SidebarItemProps {
    icon: string;
    label: string;
    isActive?: boolean;
    onClick?: () => void;
  }
  
  export interface StatCardProps {
    icon: string;
    title: string;
    value: string;
    trend?: {
      value: string;
      direction: 'up' | 'down';
      text: string;
    };
  }