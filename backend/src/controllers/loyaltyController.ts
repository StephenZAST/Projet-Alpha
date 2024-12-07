import { Request, Response, NextFunction } from 'express';
import { LoyaltyService } from '../services/loyalty';
import { AppError } from '../utils/errors';

export class LoyaltyController {
  private loyaltyService: LoyaltyService;

  constructor() {
    this.loyaltyService = new LoyaltyService();
  }

  async getAllLoyaltyPrograms(req: Request, res: Response, next: NextFunction) {
    try {
      const loyaltyPrograms = await this.loyaltyService.getAllLoyaltyPrograms();
      res.json(loyaltyPrograms);
    } catch (error) {
      next(error);
    }
  }

  async getLoyaltyProgramById(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const loyaltyProgram = await this.loyaltyService.getLoyaltyProgramById(id);
      if (!loyaltyProgram) {
        throw new AppError(404, 'Loyalty program not found');
      }
      res.json(loyaltyProgram);
    } catch (error) {
      next(error);
    }
  }

  async createLoyaltyProgram(req: Request, res: Response, next: NextFunction) {
    try {
      const loyaltyProgram = await this.loyaltyService.createLoyaltyProgram(req.body);
      res.status(201).json(loyaltyProgram);
    } catch (error) {
      next(error);
    }
  }

  async updateLoyaltyProgram(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const loyaltyProgram = await this.loyaltyService.updateLoyaltyProgram(id, req.body);
      res.json(loyaltyProgram);
    } catch (error) {
      next(error);
    }
  }

  async deleteLoyaltyProgram(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      await this.loyaltyService.deleteLoyaltyProgram(id);
      res.json({ message: 'Loyalty program deleted successfully' });
    } catch (error) {
      next(error);
    }
  }
}
