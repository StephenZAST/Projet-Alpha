import { Request, Response } from 'express';
// import legacy service supprimé
import { ArticleServicePriceService } from '../services/articleServicePrice.service';
import { handleError } from '../utils/errorHandler';
import { CreateArticleServicePriceDTO, UpdateArticleServicePriceDTO } from '../models/serviceManagement.types'; 

export class ArticleServiceController {
  // Méthodes legacy supprimées : toute la logique doit passer par ArticleServicePriceService

  static async getAllPrices(req: Request, res: Response): Promise<void> {
    try {
      
      const prices = await ArticleServicePriceService.getAllPrices();
      res.json({
        success: true,
        data: prices
      });
    } catch (error) {
      handleError(res, error);
    }
  }

  static async getArticlePrices(req: Request, res: Response): Promise<void> {
    try {
      const { articleId } = req.params;
      const prices = await ArticleServicePriceService.getArticlePrices(articleId);
      res.json({
        success: true,
        data: prices
      });
    } catch (error) {
      handleError(res, error);
    }
  }

  static async createPrice(req: Request, res: Response): Promise<void> {
    try {
      const priceData = {
        article_id: req.body.article_id,
        service_type_id: req.body.service_type_id,
        base_price: req.body.base_price,
        premium_price: req.body.premium_price,
        price_per_kg: req.body.price_per_kg,
        is_available: true
      };

      const newPrice = await ArticleServicePriceService.create(priceData);
      
      res.status(201).json({
        success: true,
        data: newPrice
      });
    } catch (error: any) {
      handleError(res, error);
    }
  }

  static async updatePrice(req: Request, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const priceData = req.body;
      const updateDTO: UpdateArticleServicePriceDTO = {
        base_price: priceData.basePrice,
        premium_price: priceData.premiumPrice,
        price_per_kg: priceData.pricePerKg,
        is_available: priceData.isAvailable
      };

      const updatedPrice = await ArticleServicePriceService.update(id, updateDTO);
      res.json({
        success: true,
        data: updatedPrice
      });
    } catch (error) {
      handleError(res, error);
    }
  }
}
