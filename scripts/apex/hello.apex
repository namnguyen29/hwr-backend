// GROUP BY trả về cái này
// AggregateResult
List<AggregateResult> accs = [
  SELECT LeadSource, COUNT(Id) alias
  FROM Lead
  GROUP BY LeadSource
];

System.debug('log accs::' + accs);
