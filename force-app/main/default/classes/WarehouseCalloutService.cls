public with sharing class WarehouseCalloutService implements Queueable, Database.AllowsCallouts {

       
    public void execute(QueueableContext context) {

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://th-superbadge-apex.herokuapp.com/equipment?_ga=2.163885558.837523693.1732588910-792723125.1732588619');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        if(response.getStatusCode() == 200) {
        // Deserialize the JSON string into collections of primitive data types.
            List<Object> results = (List<Object>) JSON.deserializeUntyped(response.getBody());

            List<Product2> equipUpsertList = new List<Product2>();

            for(Object equip: results){
                Map<String, Object> equipCasted = (Map<String, Object>)equip;

                Product2 newEquipment = new Product2();
                newEquipment.Name = (String)equipCasted.get('name');
                newEquipment.Replacement_Part__c = true;
                newEquipment.Cost__c = (Decimal)equipCasted.get('cost');
                newEquipment.Current_Inventory__c = (Integer)equipCasted.get('quantity');
                newEquipment.Lifespan_Months__c = (Integer)equipCasted.get('lifespan');
                newEquipment.Maintenance_Cycle__c = (Integer)equipCasted.get('maintenanceperiod');
                newEquipment.Warehouse_SKU__c = (String)equipCasted.get('sku');
                equipUpsertList.add(newEquipment);

            }

            System.debug('Equip Upsert List = ' + equipUpsertList);
            System.debug('Results= ' + results);


            if(!equipUpsertList.isEmpty()){
                try{
                    upsert equipUpsertList Warehouse_SKU__c;

                }catch(DmlException e){
                    System.debug(e.getMessage());
                }
                System.debug('equipUpsertList = ' + equipUpsertList);
            }

        }
  
    }

}