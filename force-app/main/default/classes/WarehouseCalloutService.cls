public with sharing class WarehouseCalloutService implements Queueable {
  private static final String baseApiUrl = 'https://th-superbadge-apex.herokuapp.com';

  @future(callout=true)
  public static void getExternalEquipments() {
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint(baseApiUrl + '/equipment');
    request.setMethod('GET');
    HttpResponse response = http.send(request);

    if (response.getStatusCode() == 200) {
      List<Product2> updatedEquipments = new List<Product2>();
      List<Object> results = (List<Object>) JSON.deserializeUntyped(response.getBody());

      for (Object result : results) {
        Map<String, Object> equipmentMap = (Map<String, Object>) result;
        Product2 product = new Product2(
          Replacement_Part__c = (Boolean) equipmentMap.get('replacement'),
          Cost__c = (Decimal) equipmentMap.get('cost'),
          Name = (String) equipmentMap.get('name'),
          Current_Inventory__c = (Decimal) equipmentMap.get('quantity'),
          Lifespan_Months__c = (Integer) equipmentMap.get('lifespan'),
          Maintenance_Cycle__c = (Integer) equipmentMap.get('maintenanceperiod'),
          Warehouse_SKU__c = (String) equipmentMap.get('sku'),
          ProductCode = (String) equipmentMap.get('_id')
        );
        updatedEquipments.add(product);
      }

      if (updatedEquipments.size() > 0) {
        upsert updatedEquipments;
      }
    }
  }

  public void execute(QueueableContext context) {
    getExternalEquipments();
  }
}
