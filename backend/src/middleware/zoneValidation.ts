import { Request, Response, NextFunction } from 'express';
import { AppError, errorCodes } from '../utils/errors';
import { ZoneStatus } from '../models/zone';

export const validateCreateZone = (req: Request, res: Response, next: NextFunction) => {
  const { name, coordinates, isActive } = req.body;

  // Vérification des champs obligatoires
  if (!name || !coordinates || isActive === undefined) {
    throw new AppError(400, 'Tous les champs sont obligatoires', errorCodes.INVALID_ZONE_DATA);
  }

  // Vérification des coordonnées
  if (!Array.isArray(coordinates) || coordinates.length !== 2 || !coordinates.every(coord => typeof coord === 'number')) {
    throw new AppError(400, 'Coordonnées invalides', errorCodes.INVALID_COORDINATES);
  }

  // Vérification du statut actif
  if (typeof isActive !== 'boolean') {
    throw new AppError(400, 'Le statut actif est invalide', errorCodes.INVALID_ACTIVE_STATUS);
  }

  next();
};

export const validateGetAllZones = (req: Request, res: Response, next: NextFunction) => {
  const { page, limit, name, isActive, deliveryPersonId } = req.query;

  // Vérification des champs de pagination
  if (page && isNaN(Number(page))) {
    throw new AppError(400, 'Le champ "page" doit être un nombre', errorCodes.INVALID_PAGINATION);
  }

  if (limit && isNaN(Number(limit))) {
    throw new AppError(400, 'Le champ "limit" doit être un nombre', errorCodes.INVALID_PAGINATION);
  }

  // Vérification du statut actif
  if (isActive && typeof isActive !== 'string') {
    throw new AppError(400, 'Le statut actif est invalide', errorCodes.INVALID_ACTIVE_STATUS);
  }

  next();
};

export const validateGetZoneById = (req: Request, res: Response, next: NextFunction) => {
  const { zoneId } = req.params;

  // Vérification de l'ID
  if (!zoneId) {
    throw new AppError(400, 'L\'ID de la zone est requis', errorCodes.INVALID_ID);
  }

  next();
};

export const validateUpdateZone = (req: Request, res: Response, next: NextFunction) => {
  const { name, coordinates, isActive } = req.body;

  // Vérification des coordonnées
  if (coordinates && (!Array.isArray(coordinates) || coordinates.length !== 2 || !coordinates.every(coord => typeof coord === 'number'))) {
    throw new AppError(400, 'Coordonnées invalides', errorCodes.INVALID_COORDINATES);
  }

  // Vérification du statut actif
  if (isActive !== undefined && typeof isActive !== 'boolean') {
    throw new AppError(400, 'Le statut actif est invalide', errorCodes.INVALID_ACTIVE_STATUS);
  }

  next();
};

export const validateDeleteZone = (req: Request, res: Response, next: NextFunction) => {
  const { zoneId } = req.params;

  // Vérification de l'ID
  if (!zoneId) {
    throw new AppError(400, 'L\'ID de la zone est requis', errorCodes.INVALID_ID);
  }

  next();
};

export const validateAssignDeliveryPerson = (req: Request, res: Response, next: NextFunction) => {
  const { deliveryPersonId } = req.body;

  // Vérification de l'ID du livreur
  if (!deliveryPersonId) {
    throw new AppError(400, 'L\'ID du livreur est requis', errorCodes.INVALID_ID);
  }

  next();
};

export const validateGetZoneStats = (req: Request, res: Response, next: NextFunction) => {
  const { startDate, endDate } = req.query;

  // Vérification des dates
  if (startDate && isNaN(new Date(startDate as string).getTime())) {
    throw new AppError(400, 'Date de début invalide', errorCodes.INVALID_DATE);
  }

  if (endDate && isNaN(new Date(endDate as string).getTime())) {
    throw new AppError(400, 'Date de fin invalide', errorCodes.INVALID_DATE);
  }

  next();
};
