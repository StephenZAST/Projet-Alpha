export const debounce = <T extends (...args: any[]) => any>(
  func: T,
  wait: number
): ((...args: Parameters<T>) => void) => {
  let timeout: NodeJS.Timeout;

  return (...args: Parameters<T>) => {
    clearTimeout(timeout);
    timeout = setTimeout(() => func(...args), wait);
  };
};

export const sortData = <T>(
  data: T[],
  key: keyof T,
  direction: 'asc' | 'desc'
): T[] => {
  return [...data].sort((a, b) => {
    if (a[key] < b[key]) return direction === 'asc' ? -1 : 1;
    if (a[key] > b[key]) return direction === 'asc' ? 1 : -1;
    return 0;
  });
};

export const filterData = <T>(
  data: T[],
  searchTerm: string,
  fields: (keyof T)[]
): T[] => {
  if (!searchTerm) return data;
  
  const lowercasedTerm = searchTerm.toLowerCase();
  
  return data.filter(item =>
    fields.some(field => 
      String(item[field]).toLowerCase().includes(lowercasedTerm)
    )
  );
};