/**
 * Tests for TLScheduler
 *
 * @author Grant Adamson, Traction on Demand
 * @date 2018-03-26
 * @group TLScheduler
 */
@IsTest
public class TLSchedulerTest {
    private static final String CRON_STRING = '00 00 22 ? * FRI'; // 10:00PM every Friday
    private static final String JOB_NAME = 'TLSchedulerTest Job';

    private static TLScheduler sched;

    static {
        sched = new TLScheduler(JOB_NAME);
    }

    @IsTest
    private static void schedule() {
        Test.startTest();

        final Id jobId = sched.schedule(new SchedulableTester(), CRON_STRING);

        Test.stopTest();


        CronTrigger ct = [
                SELECT NextFireTime
                FROM CronTrigger
                WHERE Id = :jobId
        ];

        final Date nextRunDate = Date.today().toStartOfWeek().addDays(5); // Friday
        final Time nextRunTime = Time.newInstance(22, 00, 00, 00);
        Datetime nextRunDateTime = Datetime.newInstance(nextRunDate, nextRunTime);

        if(nextRunDateTime <= Datetime.now()) {
            nextRunDateTime = nextRunDateTime.addDays(7);
        }

        System.assertEquals(nextRunDateTime, ct.NextFireTime, 'The next fire time should be next Friday at 10:00 PM');
    }

    @IsTest
    private static void isScheduled() {
        System.assertEquals(false, sched.isScheduled(), 'is Scheduled should return false');

        sched.schedule(new SchedulableTester(), CRON_STRING);

        System.assertEquals(true, sched.isScheduled(), 'is Scheduled should return true');
    }

    @IsTest
    private static void unschedule() {
        sched.schedule(new SchedulableTester(), CRON_STRING);


        Test.startTest();

        sched.unschedule();

        Test.stopTest();


        final List<CronTrigger> jobs = [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetailId IN
                (SELECT Id
                FROM CronJobDetail
                WHERE Name = :JOB_NAME
                AND JobType = :TLScheduler.JOB_TYPE_SCHEDULED)
        ];
        System.assertEquals(0, jobs.size(), 'All scheduled jobs should be removed');
    }

    public class SchedulableTester implements Schedulable {
        public void execute(SchedulableContext sc) {}
    }
}