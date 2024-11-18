import { RecurringOrderService } from '../services/recurringOrders';
import { logger } from '../utils/logger';

export class RecurringOrderProcessor {
  private recurringOrderService: RecurringOrderService;

  constructor() {
    this.recurringOrderService = new RecurringOrderService();
  }

  async process(): Promise<void> {
    try {
      logger.info('Starting recurring order processing job');
      
      await this.recurringOrderService.processRecurringOrders();
      
      logger.info('Recurring order processing job completed successfully');
    } catch (error) {
      logger.error('Error processing recurring orders:', error);
      throw error;
    }
  }
}
