global with sharing class WarehouseSyncSchedule implements Schedulable {
  global void execute(SchedulableContext schedule) {
    WarehouseCalloutService job = new WarehouseCalloutService();
    System.enqueueJob(job);
  }
}
