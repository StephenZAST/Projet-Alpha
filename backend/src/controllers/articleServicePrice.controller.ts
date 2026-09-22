import { Request, Response } from 'express';
import { ArticleServicePriceService } from '../services/articleServicePrice.service';
import { AdminActivityService } from '../services/adminActivity.service';

export class ArticleServicePriceController {
  static async create(req: Request, res: Response) {
    try {
      const { article_id, service_type_id, service_id, base_price, premium_price, price_per_kg, is_available } = req.body;

      if (!article_id || !service_type_id || !base_price) {
        return res.status(400).json({
          success: false,
          error: 'Missing required fields'
        });
      }

      const newPrice = await ArticleServicePriceService.create({
        article_id,
        service_type_id,
        service_id: service_id ?? undefined,
        base_price,
        premium_price,
        price_per_kg,
        is_available: is_available ?? true
      });

      await AdminActivityService.log(req, {
        action: 'CATALOG.ARTICLE_SERVICE_CREATED',
        details: {
          entityType: 'ARTICLE_SERVICE',
          entityId: newPrice.id,
          articleId: newPrice.article_id,
          serviceTypeId: newPrice.service_type_id,
          outcome: 'SUCCESS',
        },
      });
      
      res.status(201).json({
        success: true,
        data: newPrice
      });
    } catch (error: any) {
      res.status(error.code === 'P2002' ? 409 : 400).json({
        success: false,
        error: error.message
      });
    }
  } 

  static async update(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const priceData = req.body;
      const updateDTO = {
        ...priceData,
        service_id: priceData.service_id ?? undefined
      };
      const updatedPrice = await ArticleServicePriceService.update(id, updateDTO);

      await AdminActivityService.log(req, {
        action: 'CATALOG.ARTICLE_SERVICE_UPDATED',
        details: {
          entityType: 'ARTICLE_SERVICE',
          entityId: id,
          changedFields: Object.keys(updateDTO),
          outcome: 'SUCCESS',
        },
      });

      res.json({
        success: true,
        data: updatedPrice
      });
    } catch (error: any) {
      res.status(400).json({
        success: false,
        error: error.message
      });
    }
  } 

  static async getByArticleId(req: Request, res: Response) {
    try {
      const { articleId } = req.params;
      const prices = await ArticleServicePriceService.getByArticleId(articleId);

      res.json({
        success: true,
        data: prices
      });
    } catch (error: any) {
      res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }

  static async delete(req: Request, res: Response) {
    try {
      const { id } = req.params;
      await ArticleServicePriceService.delete(id);

      await AdminActivityService.log(req, {
        action: 'CATALOG.ARTICLE_SERVICE_DELETED',
        details: {
          entityType: 'ARTICLE_SERVICE',
          entityId: id,
          outcome: 'SUCCESS',
        },
      });

      res.json({
        success: true,
        message: "Prix de service supprimé avec succès"
      });
    } catch (error: any) {
      res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }
}
