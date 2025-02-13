import { Request, Response } from 'express';
import { ArticleServicePriceService } from '../services/articleServicePrice.service';

export class ArticleServicePriceController {
  static async create(req: Request, res: Response) {
    try {
      const priceData = req.body;
      const newPrice = await ArticleServicePriceService.create(priceData);
      
      res.status(201).json({
        success: true,
        data: newPrice
      });
    } catch (error: any) {
      res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }

  static async update(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const priceData = req.body;
      const updatedPrice = await ArticleServicePriceService.update(id, priceData);

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
