import { MainService, PriceType, AdditionalService } from "./order";

export interface Article {
    articleId: string;
    articleName: string;
    articleCategory: string;
    prices: {
      [key in MainService]: {
        [key in PriceType]: number;
      };
    };
    availableServices: MainService[];
    availableAdditionalServices: AdditionalService[];
  }
  