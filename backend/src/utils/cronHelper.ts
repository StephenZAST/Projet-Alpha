import { CronJob } from 'cron';

const jobs: CronJob[] = [];

export const scheduleCronJob = (cronTime: string, onTick: () => void) => {
  if (process.env.NODE_ENV !== 'test') {
    const job = new CronJob(cronTime, onTick);
    jobs.push(job);
    job.start();
  }
};

export const stopAllJobs = () => {
  jobs.forEach(job => job.stop());
  jobs.length = 0;
};
