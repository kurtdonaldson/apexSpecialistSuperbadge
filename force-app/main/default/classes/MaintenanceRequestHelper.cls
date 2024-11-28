public with sharing class MaintenanceRequestHelper {

    public static void handleTrigger(List<Case> workingRecords, List<Case> oldRecords, System.TriggerOperation triggerEvent ){

        switch on triggerEvent{
            when AFTER_INSERT, AFTER_UPDATE {

                List<Case> newMaintenanceRequestsToInsert = new List<Case>();

                Set<Id> triggeredCaseIds = new Set<Id>();

                //Need to create new Equipment Maintenance items that are the same as the triggered case, and add them to the new Case
                Map<Id, List<Equipment_Maintenance_Item__c>> caseIdAndListMaintenanceItems = new Map<Id, List<Equipment_Maintenance_Item__c>>();

                for(Case triggeredCase: [SELECT Id, Type, Vehicle__c, Subject, Date_Reported__c, Status, Origin, (SELECT Id, Equipment__r.Maintenance_Cycle__c FROM Equipment_Maintenance_Items__r ORDER BY Equipment__r.Maintenance_Cycle__c ASC) FROM Case WHERE Status = 'Closed' AND (Type = 'Routine Maintenance' OR Type = 'Repair') AND Id IN :workingRecords]){
                    //Add triggered Case Ids to set
                    triggeredCaseIds.add(triggeredCase.Id);                    

                    //Calculate Case Due Date
                    Date dueDate;
                    if(triggeredCase.Equipment_Maintenance_Items__r.size() > 0){
                            if(triggeredCase.Equipment_Maintenance_Items__r[0].Equipment__r.Maintenance_Cycle__c != NULL){                      
                                Integer days = Integer.valueOf(triggeredCase.Equipment_Maintenance_Items__r[0].Equipment__r.Maintenance_Cycle__c);
                                dueDate = Date.today().addDays(days);
                            }      
                    }


                    Case newCase = new Case();
                    newCase.Type = 'Routine Maintenance';
                    newCase.Vehicle__c = triggeredCase.Vehicle__c;
                    newCase.Subject = 'New Maintenance request';
                    newCase.Date_Reported__c = Date.today();
                    newCase.Status = 'New';
                    newCase.Origin = 'Web';
                    newCase.Date_Due__c = dueDate ?? NULL;
                    newCase.Previous_Maintenance_Request__c = triggeredCase.Id;

                    newMaintenanceRequestsToInsert.add(newCase);
                } 

                List<Equipment_Maintenance_Item__c> equipItemsToInsert = new List<Equipment_Maintenance_Item__c>();

                //Logic to get all Equipment Maintenance Items
                for(Equipment_Maintenance_Item__c equipItem: [SELECT Id, Maintenance_Request__c, Equipment__c FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c IN :triggeredCaseIds] ){
                    Equipment_Maintenance_Item__c clonedEquipItem = equipItem.clone();
                    equipItemsToInsert.add(clonedEquipItem);
                }

                //Insert logic
                if(!newMaintenanceRequestsToInsert.isEmpty()){

                    insert newMaintenanceRequestsToInsert;

                    Map<Id, Id> previousCaseAndNewCaseId = new Map<Id, Id>();

                    for(Case singleCase: newMaintenanceRequestsToInsert){
                        previousCaseAndNewCaseId.put(singleCase.Previous_Maintenance_Request__c, singleCase.Id);
                    }
                    
                    //Insert Equipment Maintenance Items
                    if(!equipItemsToInsert.isEmpty()){
                        for(Equipment_Maintenance_Item__c equipItem: equipItemsToInsert){
                            equipItem.Maintenance_Request__c = previousCaseAndNewCaseId.get(equipItem.Maintenance_Request__c);
                        }
                        
                        insert equipItemsToInsert;
                    }
                }


                

            }
            when BEFORE_INSERT {
                //set value on record create
            }
            when AFTER_DELETE {
                //prevent deletion of sensitive data
            }
            when else {
                //do nothing for AFTER_UNDELETE, BEFORE_DELETE, or BEFORE_UPDATE
            }
        }

    }
}