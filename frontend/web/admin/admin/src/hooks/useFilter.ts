
import { useState, useMemo } from 'react';

interface FilterConfig<T> {
  key: keyof T;
  value: any;
}

export const useFilter = <T>(items: T[], filterConfig: FilterConfig<T>[]) => {
  const [filters, setFilters] = useState<FilterConfig<T>[]>(filterConfig);

  const filteredItems = useMemo(() => {
    return items.filter(item => {
      return filters.every(filter => {
        return item[filter.key] === filter.value;
      });
    });
  }, [items, filters]);

  const updateFilter = (key: keyof T, value: any) => {
    setFilters(prevFilters => {
      const newFilters = prevFilters.map(filter => {
        if (filter.key === key) {
          return { ...filter, value };
        }
        return filter;
      });
      return newFilters;
    });
  };

  return { filteredItems, updateFilter };
};