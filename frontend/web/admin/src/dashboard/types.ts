export interface MetricCardProps {
  title: string;
  value: string;
  change?: {
    value: string;
    type: 'positive' | 'negative' | 'neutral';
    baseline?: string;
  };
  comparison?: string;
}

export interface CustomerTableProps {
  customers: Customer[];
  headers: string[];
  onSearch?: (value: string) => void;
  onSort?: (field: string) => void;
  title?: string;
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
