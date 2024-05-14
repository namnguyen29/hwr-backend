// AggregateResult
// List<AggregateResult> accs = [
//   SELECT LeadSource, COUNT(Id) alias
//   FROM Lead
//   GROUP` BY LeadSource
// ];

final String cronExpression = '0 0 1 * * ?';
WarehouseSyncSchedule scheduledJob = new WarehouseSyncSchedule();
System.schedule('WarehouseSyncScheduleJob', cronExpression, scheduledJob);
