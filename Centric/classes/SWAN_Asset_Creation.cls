public without sharing class SWAN_Asset_Creation {
    @InvocableMethod
    public static void createAsset(List<Contract> contractIds)
    {
		List<ID> conIds = new List<ID>();
		for(Contract con : contractIds){
			conIds.add(con.Id);
		}
        List<vlocity_cmt__ContractLineItem__c> all_parent_CLI =[Select id,Name,vlocity_cmt__ContractId__c,vlocity_cmt__ContractId__r.AccountId,SWAN_Service_Point__r.vlocity_cmt__PremisesId__c,vlocity_cmt__LineStatus__c,SWAN_Quote__c,
                                                        SWAN_Service_Point__c,
                                                        SWAN_Service_Point__r.Name,
                                                        vlocity_cmt__EffectiveStartDate__c,
                                                        vlocity_cmt__EffectiveEndDate__c 
                                                            from vlocity_cmt__ContractLineItem__c
                                                            where vlocity_cmt__ContractId__c in :conIds
                                                            AND vlocity_cmt__ContractId__r.Status = 'Contract Signed'
                                                            AND (SWAN_Service_Point__c != null OR SWAN_Service_Point__c != '')
                                                            ];
        System.debug('all_parent_CLI '+all_parent_CLI );
   
        List<Asset> new_Assets_Insertion_List = new List<Asset>();
       for(vlocity_cmt__ContractLineItem__c parent_CLI : all_parent_CLI)
       {
            DateTime startDate = parent_CLI.vlocity_cmt__EffectiveStartDate__c;
            Date activationDate = date.newinstance(startDate.year(), startDate.month(), startDate.day());
            DateTime enddate = parent_CLI.vlocity_cmt__EffectiveEndDate__c;
            Date usageEndDate = date.newinstance(enddate.year(), enddate.month(), enddate.day());
            Asset newAsset = new Asset();
            newAsset.Name = parent_CLI.Name;
            newAsset.AccountId = parent_CLI.vlocity_cmt__ContractId__r.AccountId;
            newAsset.vlocity_cmt__ContractId__c = parent_CLI.vlocity_cmt__ContractId__c;
            newAsset.vlocity_cmt__ServicePointId__c = parent_CLI.SWAN_Service_Point__c;
            newAsset.vlocity_cmt__ActivationDate__c = activationDate;
            newAsset.UsageEndDate = usageEndDate;
            newAsset.SWAN_Contract_Line__c = parent_CLI.Id;
            newAsset.vlocity_cmt__PremisesId__c = parent_CLI.SWAN_Service_Point__r.vlocity_cmt__PremisesId__c;
            newAsset.SWAN_Quote__c = parent_CLI.SWAN_Quote__c;
            System.debug('newAsset created values'+newAsset);
            new_Assets_Insertion_List.add(newAsset);
            
       }
       System.debug('new_Assets_Insertion_List'+new_Assets_Insertion_List);
        try
        {
            insert new_Assets_Insertion_List;
        }
        catch(Exception e)
        {
            System.debug('Exception Occurred'+e.getMessage());
        }
        /*
        System.debug('Contractids'+contractIds);
        String procedureName = 'AssetCreation_CLI';
        Map <String, Object> ipInput = new Map <String, Object> ();
        Map <String, Object> ipOutput = new Map <String, Object> ();
        Map <String, Object> ipOptions = new Map <String, Object> ();
        for (Contract conId :contractIds)
        {
            System.debug('ConID'+conId .Id);
            ipInput.put('contractId',conId.Id);
        }
        ipOutput = (Map <String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureName, ipInput, ipOptions);

        System.debug('IP Output: ' + ipOutput);*/
    }
}