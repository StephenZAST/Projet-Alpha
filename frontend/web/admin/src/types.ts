export interface MetricCardProps {
    title: string;
    value: string | number;
    change?: {
      value: string;
      type: 'increase' | 'decrease' | 'neutral';
      baseline?: string;
    };
  }
  
  export interface TableRowProps {
    customerName: string;
    company: string;
    phoneNumber: string;
    email: string;
    country: string;
    status: 'active' | 'inactive';
  }
  
  export interface SidebarItemProps {
    icon: string;
    label: string;
    isActive?: boolean;
    onClick?: () => void;
  }
  
  export interface SearchBarProps {
    placeholder?: string;
    onSearch: (value: string) => void;
  }