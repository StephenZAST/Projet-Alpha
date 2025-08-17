import { Request, Response } from 'express';
// import legacy service supprimé
import { ArticleServicePriceService } from '../services/articleServicePrice.service';
import { handleError } from '../utils/errorHandler';
import { CreateArticleServicePriceDTO, UpdateArticleServicePriceDTO } from '../models/serviceManagement.types'; 

export class ArticleServiceController {
  // Retourne tous les couples article/serviceType disponibles avec prix
  static async getCouplesForServiceType(req: Request, res: Response): Promise<void> {
    try {
      const { serviceTypeId, serviceId } = req.query;
      if (!serviceTypeId) {
        res.status(400).json({ success: false, message: 'serviceTypeId requis' });
        return;
      }
      // Filtre par serviceTypeId et optionnellement serviceId
      const where: any = { service_type_id: serviceTypeId, is_available: true };
      if (serviceId) where.service_id = serviceId;
      const couples = await ArticleServicePriceService.getCouples(where);
      res.json({ success: true, data: couples });
    } catch (error) {
      handleError(res, error);
    }
  }
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
      const { serviceTypeId } = req.query;
      const prices = await ArticleServicePriceService.getArticlePrices(articleId);
      if (serviceTypeId) {
        // On cherche le couple exact
        const found = prices.find((p: any) => p.service_type_id === serviceTypeId);
        if (found) {
          res.json({ success: true, data: found });
        } else {
          res.status(404).json({ success: false, message: 'No price found for this article/serviceType' });
        }
      } else {
        res.json({ success: true, data: prices });
      }
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
