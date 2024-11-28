@isTest
public with sharing class MaintenanceRequestHelperTest {

    @TestSetup
    static void makeData(){

        Vehicle__c testVehicle = new Vehicle__c(Name = 'Test Vehicle');
        insert testVehicle;

        Product2 testEquipment = new Product2(Name = 'Generator 1000 kW', IsActive = true, Maintenance_Cycle__c = 5, Cost__c = 10.00, Replacement_Part__c = true);
        insert testEquipment;

        Case testCase = new Case(Subject = 'Test Case',Type = 'Repair', Status = 'New', Origin = 'Web', Vehicle__c = testVehicle.Id);
        insert testCase;

        Equipment_Maintenance_Item__c testMaintenanceItem = new Equipment_Maintenance_Item__c(Maintenance_Request__c = testCase.Id, Equipment__c = testEquipment.Id, Quantity__c = 1);
        insert testMaintenanceItem;

    }

    
    @isTest
    static void testMaintenanceTrigger(){

        Case testCase = [SELECT Id, Subject, Vehicle__c, Status FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        testCase.Status = 'Closed';
        upsert testCase;

        System.debug('Test case after upsert' + testCase);


        List<Case> closedCaseResult = [SELECT Id, Subject, Vehicle__c, Status FROM Case WHERE Subject = 'Test Case' AND Status = 'Closed'];
        List<Case> openCaseResult = [SELECT Id, Subject, Vehicle__c, Status FROM Case WHERE Subject = 'New Maintenance request' AND Status = 'New'];  

        Assert.areEqual(1, closedCaseResult.size(), 'Should be a Case with subject Test Case');
        Assert.areEqual(1, openCaseResult.size(), 'Should be a Case with subject New Maintenance request');


    }
}