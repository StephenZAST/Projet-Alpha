import { useState, useMemo, useCallback } from 'react';

type FilterOperator = 'equals' | 'contains' | 'greaterThan' | 'lessThan' | 'between' | 'in';
type FilterValue = string | number | boolean | Date | Array<string | number | Date>;

interface FilterConfig<T> {
  field: keyof T;
  operator: FilterOperator;
  value: FilterValue;
}

interface SortConfig<T> {
  field: keyof T;
  direction: 'asc' | 'desc';
}

interface UseFilterOptions<T> {
  initialFilters?: FilterConfig<T>[];
  initialSort?: SortConfig<T>;
  searchFields?: (keyof T)[];
}

export const useFilter = <T extends Record<string, unknown>>(
  items: T[],
  options: UseFilterOptions<T> = {}
) => {
  const [filters, setFilters] = useState<FilterConfig<T>[]>(options.initialFilters || []);
  const [sortConfig, setSortConfig] = useState<SortConfig<T> | null>(options.initialSort || null);
  const [searchTerm, setSearchTerm] = useState('');

  const applyFilter = useCallback((item: T, filter: FilterConfig<T>): boolean => {
    const itemValue = item[filter.field];
    const filterValue = filter.value;

    switch (filter.operator) {
      case 'equals':
        return itemValue === filterValue;
      case 'contains':
        return String(itemValue).toLowerCase().includes(String(filterValue).toLowerCase());
      case 'greaterThan':
        return Number(itemValue) > Number(filterValue);
      case 'lessThan':
        return Number(itemValue) < Number(filterValue);
      case 'between':
        if (Array.isArray(filterValue) && filterValue.length === 2) {
          const value = Number(itemValue);
          const [min, max] = filterValue.map(Number);
          return value >= min && value <= max;
        }
        return false;
      case 'in':
        return Array.isArray(filterValue) && filterValue.includes(itemValue as FilterValue);
      default:
        return true;
    }
  }, []);

  const filteredItems = useMemo(() => {
    let result = [...items];

    // Apply filters
    if (filters.length > 0) {
      result = result.filter(item => 
        filters.every(filter => applyFilter(item, filter))
      );
    }

    // Apply search
    if (searchTerm && options.searchFields) {
      const searchLower = searchTerm.toLowerCase();
      result = result.filter(item =>
        options.searchFields?.some(field => 
          String(item[field]).toLowerCase().includes(searchLower)
        )
      );
    }

    // Apply sorting
    if (sortConfig) {
      result.sort((a, b) => {
        const aVal = a[sortConfig.field];
        const bVal = b[sortConfig.field];
        
        if (aVal < bVal) return sortConfig.direction === 'asc' ? -1 : 1;
        if (aVal > bVal) return sortConfig.direction === 'asc' ? 1 : -1;
        return 0;
      });
    }

    return result;
  }, [items, filters, searchTerm, sortConfig, options.searchFields, applyFilter]);

  const addFilter = (filter: FilterConfig<T>) => {
    setFilters(prev => [...prev, filter]);
  };

  const removeFilter = (field: keyof T) => {
    setFilters(prev => prev.filter(f => f.field !== field));
  };

  const updateFilter = (
    field: keyof T,
    newConfig: Partial<Omit<FilterConfig<T>, 'field'>>
  ) => {
    setFilters(prev => prev.map(f => 
      f.field === field ? { ...f, ...newConfig } : f
    ));
  };

  const clearFilters = () => {
    setFilters([]);
    setSearchTerm('');
    setSortConfig(null);
  };

  const sort = (field: keyof T, direction: 'asc' | 'desc') => {
    setSortConfig({ field, direction });
  };

  return {
    filteredItems,
    filters,
    sortConfig,
    searchTerm,
    addFilter,
    removeFilter,
    updateFilter,
    clearFilters,
    setSearchTerm,
    sort,
    totalItems: filteredItems.length
  };
};