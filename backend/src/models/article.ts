import { AppError, errorCodes } from '../utils/errors';

export enum ArticleCategory {
  CHEMISIER = 'Chemisier',
  PANTALON = 'Pantalon',
  JUPE = 'Jupe',
  COSTUME = 'Costume',
  BAZIN_COMPLET = 'Bazin/Complet',
  TRADITIONNEL = 'Traditionnel',
  ENFANTS = 'Enfants',
  SPORT = 'Sport',
  LINGE_MAISON = 'Linge de maison',
  ACCESSOIRES = 'Accessoires / autres'
}

export enum ArticleStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
}

export enum ArticleType {
  SIMPLE = 'SIMPLE',
  VARIABLE = 'VARIABLE',
}

export interface Article {
  articleId: string;
  articleName: string;
  articleCategory: ArticleCategory;
  prices: {
    [key in string]: {
      [key in string]: number;
    };
  };
  availableServices: string[];
  availableAdditionalServices: string[];
  status: ArticleStatus;
  type: ArticleType;
  createdAt?: string;
  updatedAt?: string;
}
