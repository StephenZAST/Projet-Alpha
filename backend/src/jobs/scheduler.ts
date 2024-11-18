import { CronJob } from 'cron';
import { RecurringOrderProcessor } from './recurringOrderProcessor';
import { logger } from '../utils/logger';

export class JobScheduler {
  private recurringOrderProcessor: RecurringOrderProcessor;
  private recurringOrderJob: CronJob;

  constructor() {
    this.recurringOrderProcessor = new RecurringOrderProcessor();
    
    // Run every day at 00:00
    this.recurringOrderJob = new CronJob(
      '0 0 * * *',
      this.processRecurringOrders.bind(this),
      null,
      false,
      'UTC'
    );
  }

  private async processRecurringOrders(): Promise<void> {
    try {
      await this.recurringOrderProcessor.process();
    } catch (error) {
      logger.error('Failed to process recurring orders:', error);
    }
  }

  startJobs(): void {
    logger.info('Starting scheduled jobs');
    
    if (!this.recurringOrderJob.running) {
      this.recurringOrderJob.start();
      logger.info('Recurring order processing job scheduled');
    }
  }

  stopJobs(): void {
    logger.info('Stopping scheduled jobs');
    
    if (this.recurringOrderJob.running) {
      this.recurringOrderJob.stop();
      logger.info('Recurring order processing job stopped');
    }
  }
}
