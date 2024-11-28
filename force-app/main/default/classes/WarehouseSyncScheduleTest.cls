@isTest
public with sharing class WarehouseSyncScheduleTest {
   
    @isTest
    static void testWarehouseSyncService(){

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());

        WarehouseSyncSchedule wss = new WarehouseSyncSchedule();

        String CRON_EXP = '0 0 23 * * ?'; 
        
        //Schedule test job
        String jobId = System.schedule('Test Sched', CRON_EXP, wss);

        //Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronJobDetailId, State, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId LIMIT 1];

        //Verify expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);

        //Verify job has not run
        System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();


    }
}