import { Request, Response, NextFunction } from 'express';
import { LoyaltyService } from '../../services/loyalty';
import { AppError, errorCodes } from '../../utils/errors';
import { LoyaltyProgram } from '../../models/loyalty';

export class LoyaltyProgramController {
  private loyaltyService: LoyaltyService;

  constructor() {
    this.loyaltyService = new LoyaltyService();
  }

  async createLoyaltyProgram(req: Request<{}, {}, LoyaltyProgram>, res: Response, next: NextFunction) {
    try {
      const loyaltyProgram = await this.loyaltyService.createLoyaltyProgram(req.body);
      res.status(201).json(loyaltyProgram);
    } catch (error) {
      next(error);
    }
  }

  async getLoyaltyProgram(req: Request, res: Response, next: NextFunction) {
    try {
      const loyaltyProgram = await this.loyaltyService.getLoyaltyProgram();
      if (!loyaltyProgram) {
        throw new AppError(404, 'Loyalty program not found', errorCodes.NOT_FOUND);
      }
      res.status(200).json(loyaltyProgram);
    } catch (error) {
      next(error);
    }
  }

    async getAllLoyaltyPrograms(req: Request, res: Response, next: NextFunction) {
    try {
      const loyaltyPrograms = await this.loyaltyService.getAllLoyaltyPrograms();
      res.status(200).json(loyaltyPrograms);
    } catch (error) {
      next(error);
    }
  }

  async getLoyaltyProgramById(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const loyaltyProgram = await this.loyaltyService.getLoyaltyProgramById(id);
       if (!loyaltyProgram) {
        throw new AppError(404, 'Loyalty program not found', errorCodes.NOT_FOUND);
      }
      res.status(200).json(loyaltyProgram);
    } catch (error) {
      next(error);
    }
  }

  async updateLoyaltyProgram(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const programData = req.body;
      const updatedProgram = await this.loyaltyService.updateLoyaltyProgram(id, programData);
      res.status(200).json(updatedProgram);
    } catch (error) {
      next(error);
    }
  }

  async deleteLoyaltyProgram(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      await this.loyaltyService.deleteLoyaltyProgram(id);
      res.status(204).send();
    } catch (error) {
      next(error);
    }
  }
}
