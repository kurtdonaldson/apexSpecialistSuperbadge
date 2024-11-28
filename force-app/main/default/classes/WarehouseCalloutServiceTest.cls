@isTest
public with sharing class WarehouseCalloutServiceTest {

    @isTest
    static void testWarehouseCalloutService(){

        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());

        WarehouseCalloutService ws = new WarehouseCalloutService();

        Test.startTest();

        System.enqueueJob(ws);

        Test.stopTest();

        List<Product2> listEquipment = [SELECT Id, Name FROM Product2];

        Assert.areEqual('Generator 1000 kW', listEquipment[0].Name, 'Name should equal \'Generator 1000 kW\'');

    }

}