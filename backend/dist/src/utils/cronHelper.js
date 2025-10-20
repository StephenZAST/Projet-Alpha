"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.stopAllJobs = exports.scheduleCronJob = void 0;
const cron_1 = require("cron");
const jobs = [];
const scheduleCronJob = (cronTime, onTick) => {
    if (process.env.NODE_ENV !== 'test') {
        const job = new cron_1.CronJob(cronTime, onTick);
        jobs.push(job);
        job.start();
    }
};
exports.scheduleCronJob = scheduleCronJob;
const stopAllJobs = () => {
    jobs.forEach(job => job.stop());
    jobs.length = 0;
};
exports.stopAllJobs = stopAllJobs;
