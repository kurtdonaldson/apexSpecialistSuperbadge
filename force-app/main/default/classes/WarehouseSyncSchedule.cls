public with sharing class WarehouseSyncSchedule implements Schedulable {

    public void execute(SchedulableContext SC) {
        ID jobID = System.enqueueJob(new WarehouseCalloutService());
     }
}