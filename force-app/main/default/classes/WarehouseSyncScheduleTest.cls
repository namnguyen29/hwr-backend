@IsTest
public with sharing class WarehouseSyncScheduleTest {
  @IsTest
  public static void testScheduleWarehouseJob() {
    Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());

    Test.startTest();
    System.enqueueJob(new WarehouseCalloutService());
    System.schedule('WarehouseSyncScheduleJob', '0 0 1 * * ?', new WarehouseSyncSchedule());
    Test.stopTest();

    List<Product2> updatedWorkOrders = [SELECT Id, Lifespan_Months__c, ProductCode FROM Product2];
    System.assert(updatedWorkOrders != null);
    System.assertEquals(0, updatedWorkOrders.size());
  }
}
