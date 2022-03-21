/**
 * @description This class is used to call integration procedure validating groups. 
 * It is invoked from process builder 'ValidateGroupsOnQuote'
 *
 * User Story: 9139
 * 
 * @author Priyatham
 * @version 1.0
 * 
 * History
 * =======
 * v1.0 - 12-08-2021 - Initial Version
 * 
 */

global with sharing class callValidateGroupIntegrationProcedure {

    public static final String CONTEXT_ID = 'ContextId';
    public static final String QUOTEGROUP_ID = 'QuoteGroupId';
    public static final String procedureName = 'MultiService_StartValidatePriceMultipleGroups';

    @InvocableMethod(label='ValidateGroupsIP')
    global static void runIntegrationServiceInvocable(List < IntegrationProcedureInput > input) {
      
        /* Initialize variables */        
        Map <String, Object> ipInput = new Map <String, Object> ();
        Map <String, Object> ipOutput = new Map <String, Object> ();
        Map <String, Object> ipOptions = new Map <String, Object> ();
        ipInput.put(CONTEXT_ID, input[0].ContextId);
        ipInput.put(QUOTEGROUP_ID, input[0].QuoteGroupId);
        
        /* Call the IP via runIntegrationService, and save the output to ipOutput */
        ipOutput = (Map <String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureName, ipInput, ipOptions);
      
    }
    
    global class IntegrationProcedureInput
    {
        @InvocableVariable(label = 'ContextId') global String ContextId;
        @InvocableVariable(label = 'QuoteGroupId') global String QuoteGroupId;
    } 
}