import React from 'react';
import { Search, Filter } from 'react-feather';
import { colors } from '../../theme/colors';
import { Button } from './Button';

interface FilterOption {
  label: string;
  value: string;
  options: { label: string; value: string }[];
}

interface SearchFilterProps {
  onSearch: (value: string) => void;
  onFilter: (filters: Record<string, string>) => void;
  filterOptions: FilterOption[];
  placeholder?: string;
}

export const SearchFilter: React.FC<SearchFilterProps> = ({
  onSearch,
  onFilter,
  filterOptions,
  placeholder = 'Search...'
}) => {
  const [filters, setFilters] = React.useState<Record<string, string>>({});
  const [isFilterOpen, setIsFilterOpen] = React.useState(false);

  const handleFilterChange = (key: string, value: string) => {
    const newFilters = { ...filters, [key]: value };
    setFilters(newFilters);
    onFilter(newFilters);
  };

  return (
    <div style={{ marginBottom: '24px' }}>
      <div style={{ display: 'flex', gap: '16px', marginBottom: '16px' }}>
        <div style={{ position: 'relative', flex: 1 }}>
          <Search 
            size={18} 
            style={{
              position: 'absolute',
              left: '12px',
              top: '50%',
              transform: 'translateY(-50%)',
              color: colors.gray400
            }}
          />
          <input
            type="text"
            placeholder={placeholder}
            onChange={(e) => onSearch(e.target.value)}
            style={{
              width: '100%',
              padding: '10px 12px 10px 40px',
              borderRadius: '8px',
              border: `1px solid ${colors.gray300}`
            }}
          />
        </div>
        <Button
          variant="secondary"
          onClick={() => setIsFilterOpen(!isFilterOpen)}
        >
          <Filter size={18} />
          Filters
        </Button>
      </div>

      {isFilterOpen && (
        <div style={{
          display: 'flex',
          gap: '16px',
          padding: '16px',
          backgroundColor: colors.white,
          borderRadius: '8px',
          boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
        }}>
          {filterOptions.map(filter => (
            <div key={filter.value}>
              <label style={{ display: 'block', marginBottom: '8px' }}>
                {filter.label}
              </label>
              <select
                value={filters[filter.value] || ''}
                onChange={(e) => handleFilterChange(filter.value, e.target.value)}
                style={{
                  padding: '8px',
                  borderRadius: '4px',
                  border: `1px solid ${colors.gray300}`
                }}
              >
                <option value="">All</option>
                {filter.options.map(option => (
                  <option key={option.value} value={option.value}>
                    {option.label}
                  </option>
                ))}
              </select>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};
