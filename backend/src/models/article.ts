import { MainService, PriceType, AdditionalService } from "./order";

export interface Article {
    articleId: string;
    articleName: string;
    articleCategory: ArticleCategory;
    prices: {
      [key in MainService]: {
        [key in PriceType]: number;
      };
    };
    availableServices: MainService[];
    availableAdditionalServices: AdditionalService[];
}

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

export { MainService, PriceType };
