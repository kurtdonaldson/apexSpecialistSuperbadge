public with sharing class ScheduleApexJobs implements Schedulable {

    public void execute(SchedulableContext SC) {
        ID jobID = System.enqueueJob(new WarehouseCalloutService());
        System.debug('Job Id = ' + jobID);
     }
}