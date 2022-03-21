global with sharing class IntegrationProcedureInvocable {
 @InvocableMethod(label='BGGorillaPricingEngine_BGCheckCommotity')
 global static List < IntegrationProcedureOutput > runIntegrationServiceInvocable(List < IntegrationProcedureInput > input) {
  System.debug(LoggingLevel.Error, JSON.serialize(input));
  callIntegrationProcedure callIP = new callIntegrationProcedure();
  callIp.inputString = JSON.serialize(input);
  System.enqueueJob(callIP);
 // futureCallIP(JSON.serialize(input));
  IntegrationProcedureOutput result = new IntegrationProcedureOutput();

  return new List < IntegrationProcedureOutput >
   {
    result
   };
 }
global class IntegrationProcedureInput
 {
  @InvocableVariable(label = 'IPName') global String IPName;
  @InvocableVariable(label = 'ContextId') global String ContextId;
  @InvocableVariable(label = 'CommodityObject') global String CommodityObject;
  @InvocableVariable(label = 'SkipUpdate') global String SkipUpdate;
  @InvocableVariable(label = 'ContractId') global String ContractId;
 }
global class IntegrationProcedureOutput
 {
  @InvocableVariable(label = 'Output') global String output;
 }
 
}