import { useEffect, useState } from 'react';
import { Search } from 'react-feather';
import { colors } from '../../theme/colors';
import { debounce } from '../../utils/helpers';

interface SearchBarProps {
  onSearch: (value: string) => void;
  placeholder?: string;
  delay?: number;
}

export const SearchBar = ({ onSearch, placeholder = 'Search...', delay = 300 }: SearchBarProps) => {
  const [value, setValue] = useState('');

  const debouncedSearch = debounce((searchTerm: string) => {
    onSearch(searchTerm);
  }, delay);

  useEffect(() => {
    debouncedSearch(value);
  }, [value]);

  return (
    <div style={{
      position: 'relative',
      width: '100%',
      maxWidth: '400px'
    }}>
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
        value={value}
        onChange={(e) => setValue(e.target.value)}
        placeholder={placeholder}
        style={{
          width: '100%',
          padding: '10px 12px 10px 40px',
          borderRadius: '8px',
          border: `1px solid ${colors.gray300}`,
          fontSize: '14px',
          outline: 'none',
          transition: 'border-color 0.2s',
        }}
      />
    </div>
  );
};
