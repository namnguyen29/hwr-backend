public with sharing class MaintenanceRequestHelper {
  public static void updateworkOrders(List<Case> updateWO, Map<Id, Case> nonUpdatedCasesMap) {
    Set<Id> validCaseIds = new Set<Id>();
    for (Case c : updateWO) {
      if (
        (nonUpdatedCasesMap.get(c.Id).Status != 'Closed' && c.Status == 'Closed') &&
        (c.Type == 'Repair' ||
        c.Type == 'Routine Maintenance')
      ) {
        validCaseIds.add(c.Id);
      }
    }

    /*
     * New maintenance request is tied to the same Vehicle and Equipment Records as the original closed request,
     * All equipment has maintenance cycles.
     */
    if (!validCaseIds.isEmpty()) {
      List<Case> newlistCases = new List<Case>();
      Map<Id, Decimal> caseMaintenance = new Map<ID, Decimal>();
      Map<Id, Case> closedCasesMap = new Map<Id, Case>(
        [
          SELECT
            Id,
            Vehicle__c,
            Equipment__c,
            Equipment__r.Maintenance_Cycle__c,
            (SELECT Id, Equipment__c, Quantity__c FROM Equipment_Maintenance_Items__r)
          FROM Case
          WHERE Id IN :validCaseIds
        ]
      );

      /**
       * Get the maintenance cycle
       */
      AggregateResult[] results = [
        SELECT Maintenance_Request__c, MIN(Equipment__r.Maintenance_Cycle__c) cycle
        FROM Equipment_Maintenance_Item__c
        WHERE Maintenance_Request__c IN :validCaseIds
        GROUP BY Maintenance_Request__c
      ];

      for (AggregateResult ar : results) {
        Id maintenanceRequestId = (Id) ar.get('Maintenance_Request__c');
        Decimal cycle = (Decimal) ar.get('cycle');
        caseMaintenance.put(maintenanceRequestId, cycle);
      }

      for (Case cc : closedCasesMap.values()) {
        Case newCase = new Case(
          ParentId = cc.Id,
          Status = 'New',
          Subject = 'Routine Maintenance',
          Type = 'Routine Maintenance',
          Vehicle__c = cc.Vehicle__c,
          Equipment__c = cc.Equipment__c,
          Origin = 'Web',
          Date_Reported__c = Date.Today()
        );
        if (caseMaintenance.containskey(cc.Id)) {
          newCase.Date_Due__c = Date.today().addDays((Integer) caseMaintenance.get(cc.Id));
        }
        newlistCases.add(newCase);
      }
      insert newlistCases;

      /**
       * Assigned the new EMIs to new opened request
       */
      List<Equipment_Maintenance_Item__c> clonedEMIs = new List<Equipment_Maintenance_Item__c>();
      for (Case nc : newlistCases) {
        for (
          Equipment_Maintenance_Item__c emi : closedCasesMap.get(nc.ParentId)
            .Equipment_Maintenance_Items__r
        ) {
          Equipment_Maintenance_Item__c emiClone = emi.clone();
          emiClone.Maintenance_Request__c = nc.Id;
          clonedEMIs.add(emiClone);
        }
      }
      insert clonedEMIs;
    }
  }
}
