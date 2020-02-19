/**
 * Convenience class for scheduling and unscheduling jobs
 *
 * @author Grant Adamson, Traction on Demand
 * @date 2018-03-26
 * @group TLScheduler
 */
public class TLScheduler {
    @TestVisible private static final String JOB_TYPE_SCHEDULED = '7';

    private String jobName;

    /**
     * Create a new scheduler instance with provided Job Name
     *
     * @param jobName Name that will identify the scheduled job
     */
    public TLScheduler(String jobName) {
        this.jobName = jobName;
    }

    /**
     * Schedule a job with the values provided
     *
     * @param sched An instance of the schedulable class
     * @param cronString The CRON string used to determine the schedule
     *
     * @return Id the Id of the scheduled job
     */
    public Id schedule(Schedulable sched, String cronString) {
        Id jobId = getJobIdForName(jobName);
        if(jobId == null) {
            jobId = System.schedule(jobName, cronString, sched);
        }

        return jobId;
    }

    /**
     * Unschedule a job. Uses the jobName provided to the constructor
     */
    public void unschedule() {
        Id jobId = getJobIdForName(jobName);

        if(jobId != null) {
            System.abortJob(jobId);
        }
    }

    /**
     * Determine if a job is currently scheduled. Uses the jobName provided to the constructor
     *
     * @return TRUE for scheduled, FALSE for not scheduled
     */
    public Boolean isScheduled() {
        return getJobIdForName(jobName) != null;
    }

    private static Id getJobIdForName(String jobName) {
        final List<CronTrigger> jobs = [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetailId IN
                    (SELECT Id
                    FROM CronJobDetail
                    WHERE Name = :jobName
                    AND JobType = :JOB_TYPE_SCHEDULED)
        ];

        if(jobs.isEmpty()) {
            return null;
        }

        return jobs[0].Id;
    }
}