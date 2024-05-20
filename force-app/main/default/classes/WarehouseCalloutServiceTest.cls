@IsTest
public class WarehouseCalloutServiceTest {
  @IsTest
  public static void testWarehouseService() {
    Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
    Test.startTest();
    WarehouseCalloutService.getExternalEquipments();
    Test.stopTest();

    List<Product2> updatedEquipments = [
      SELECT Name, Lifespan_Months__c, Cost__c, ProductCode, Current_Inventory__c
      FROM Product2
    ];
    System.assertEquals(22, updatedEquipments.size());
    System.assertEquals(0, updatedEquipments[1].Lifespan_Months__c);
  }
}
