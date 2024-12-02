export interface IconButtonProps {
    src: string;
    alt: string;
    onClick?: () => void;
  }
  
  export interface SearchInputProps {
    onSearch: (value: string) => void;
    placeholder?: string;
  }
  
  export interface UserAvatarProps {
    imageSrc: string;
    userName: string;
  }