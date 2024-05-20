@IsTest
public with sharing class MaintenanceRequestHelperTest {
  @IsTest
  public static void bulkCase() {
    final Integer NUMBER_OF_CASES = 300;
    List<Case> workOrders = new List<Case>();
    List<Vehicle__c> vehicles = new List<Vehicle__c>();
    List<Product2> equipments = new List<Product2>();

    for (Integer idx = 0; idx < NUMBER_OF_CASES; idx++) {
      vehicles.add(new Vehicle__c(Name = 'Vehicle' + idx));
      equipments.add(
        new Product2(
          Name = 'My Equipment' + idx,
          Lifespan_Months__c = 8,
          Maintenance_Cycle__c = 8,
          Replacement_Part__c = true
        )
      );
    }
    insert vehicles;
    insert equipments;
    for (Integer idx = 0; idx < NUMBER_OF_CASES; idx++) {
      String workOrderType = '';
      if (idx < 150) {
        workOrderType = 'Repair';
      } else {
        workOrderType = 'Routine Maintenance';
      }
      Id vehicleId = vehicles[idx].Id;
      Id equipmentId = equipments[idx].Id;
      System.debug('read id::' + vehicleId);
      workOrders.add(createMaintenanceRequest(equipmentId, vehicleId, workOrderType));
    }
    insert workOrders;

    Test.startTest();
    for (Case workOrder : workOrders) {
      workOrder.Status = 'Closed';
    }
    update workOrders;
    Test.stopTest();

    System.assert(workOrders != null);
  }

  @IsTest
  public static void negative() {
    Vehicle__c demoVehicle = createVehicle();
    Product2 demoEquipment = createEquipment();
    insert demoVehicle;
    insert demoEquipment;
    Id vehicleId = demoVehicle.Id;
    Id equipmentId = demoEquipment.Id;
    Case workOrder = createMaintenanceRequest(equipmentId, vehicleId, 'Routine Maintenance');
    insert workOrder;

    Test.startTest();
    workOrder.Status = 'Working';
    update workOrder;
    Test.stopTest();

    Case modifyRequest = [
      SELECT Id, Subject, Status, Type, Equipment__c, Vehicle__c
      FROM Case
      LIMIT 1
    ];
    System.assert(modifyRequest != null);
    System.assertEquals('Working', modifyRequest.Status);
    System.assertEquals(vehicleId, modifyRequest.Vehicle__c);
  }

  @IsTest
  public static void positive() {
    Vehicle__c demoVehicle = createVehicle();
    Product2 demoEquipment = createEquipment();
    insert demoVehicle;
    insert demoEquipment;
    Id vehicleId = demoVehicle.Id;
    Id equipmentId = demoEquipment.Id;
    Case workOrder = createMaintenanceRequest(equipmentId, vehicleId, 'Repair');
    insert workOrder;
    Equipment_Maintenance_Item__c workPart = createWorkPart(equipmentId, workOrder.Id);
    insert workPart;

    Test.startTest();
    workOrder.Status = 'Closed';
    update workOrder;
    Test.stopTest();

    Case modifyRequest = [
      SELECT Id, Subject, Type, Equipment__c, Vehicle__c
      FROM Case
      WHERE Status = 'New'
    ];
    System.assert(modifyRequest != null);
    System.assertEquals('Routine Maintenance', modifyRequest.Subject);
    System.assertEquals(vehicleId, modifyRequest.Vehicle__c);
    System.assertEquals(equipmentId, modifyRequest.Equipment__c);
  }

  private static Vehicle__c createVehicle() {
    return new Vehicle__c(Name = 'VFX LG3');
  }

  private static Product2 createEquipment() {
    return new Product2(
      Name = 'My Equipment',
      Lifespan_Months__c = 8,
      Maintenance_Cycle__c = 8,
      Replacement_Part__c = true
    );
  }

  private static Case createMaintenanceRequest(Id equipmentId, Id vehicleId, String type) {
    return new Case(
      Type = type,
      Status = 'New',
      Origin = 'Web',
      Subject = 'Positive Subject',
      Equipment__c = equipmentId,
      Vehicle__c = vehicleId
    );
  }

  private static Equipment_Maintenance_Item__c createWorkPart(Id equipmentId, Id requestId) {
    return new Equipment_Maintenance_Item__c(
      Equipment__c = equipmentId,
      Maintenance_Request__c = requestId
    );
  }
}
