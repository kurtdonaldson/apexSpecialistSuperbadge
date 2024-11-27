trigger MaintenanceRequest on Case (before insert, after insert, before update, after update, before delete, after delete, after undelete) {

    MaintenanceRequestHelper.handleTrigger(Trigger.new, Trigger.old, Trigger.operationType);

}