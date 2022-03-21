global with sharing class SWAN_ExtractContractLineItems implements vlocity_cmt.VlocityOpenInterface {

 /**
     * Top level call by a Vlocity Remote Action
     *
     * @param inputMap  - The input provided to the Remote Action
     * @param outputMap - Any output to be provided back to the Remote Action
     * @param options   - Any options to aid in the execution of this class
     *
     * @returns true if the method completes successfully, false otherwise
     */ 
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {

        Boolean result = true;
        try
        {
            if (methodName.equals('getContractLineItemsInfo'))
            {
                getContractLineItemsInfo(inputMap,outputMap,options);
            }
            else 
            {
                result = false;
            }   
        } 
        catch(Exception e)
        {System.debug('SWAN_ExtractSubQuoteCount:invokeMethod -> exception: '+e);
            result = false;}
        
        return result;
    
    }
    
    global Boolean getContractLineItemsInfo(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        List<Object> parentCLI= new List<Object>();
        String contractID = String.ValueOf(inputMap.get('ContextId'));
        for(vlocity_cmt__ContractLineItem__c cli : [SELECT id,vlocity_cmt__LineStatus__c,SWAN_Service_Point_Start_Date__c,SWAN_Service_Point_End_Date__c, 
                                                    vlocity_cmt__EffectiveEndDate__c,vlocity_cmt__ContractId__r.vlocity_cmt__OpportunityId__r.Recordtype.Name,SWAN_Quote__r.vlocity_cmt__ParentQuoteId__c,
                                                    SWAN_Quote__r.SWAN_Site_Addition_Parent__c,SWAN_Service_Point__r.vlocity_cmt__ServicePointNumber__c,
                                                    vlocity_cmt__EffectiveStartDate__c,SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Site_Addition_Parent__c,  
                                                    (select id,SWAN_UnitRate__c,vlocity_cmt__RecurringCharge__c from vlocity_cmt__Contract_Line_Items__r) 
                                                    from vlocity_cmt__ContractLineItem__c 
                                                    where vlocity_cmt__ContractId__c =:contractID AND SWAN_Service_Point__c != null])
        {
            system.debug('cli'+cli);
            Map<String, Object> eachRec = pushEachRecord(cli);
            parentCLI.add(eachRec);
            System.debug('Size Parent cli'+parentCLI.size());
        }   
        if(parentCLI.size()>0)
        {
            outputMap.put('ParentCLI',parentCLI);
            system.debug('outputMapNinad'+outputMap);
        }
        return true;
        }
        
        public Map<String, Object> pushEachRecord(vlocity_cmt__ContractLineItem__c cli)
        {
            Map<String, Object> eachRec = new Map<String, Object>();
            for(vlocity_cmt__ContractLineItem__c  childcli : cli.vlocity_cmt__Contract_Line_Items__r){
                if(childcli.SWAN_UnitRate__c != null)
                {   
                    String unitrate;
                    if(childcli.SWAN_UnitRate__c == 0)
                    {unitrate = '0';}
                    else
                    {unitrate = String.valueOf(childcli.SWAN_UnitRate__c);}
                    if(unitrate.indexOf('.') == -1)
                    {unitrate += '.000  p/kWh';}////SUBSTRING(unitrate+"000",0,STRINGINDEXOF(unitrate+"000",".")+4)
                    else{
                        String unitratedef = unitrate + '000';
                        Integer num = (unitratedef.indexOf('.')+4);
                        unitrate = unitratedef.substring(0,num)+' p/kWh';
                    }   
                    eachRec.put('UnitRate',unitrate);
                }
                if(childcli.vlocity_cmt__RecurringCharge__c != null)
                {
                    String standing_charge;
                    if(childcli.vlocity_cmt__RecurringCharge__c == 0)
                    {standing_charge = '0';}
                    else
                    {standing_charge = String.valueOf(childcli.vlocity_cmt__RecurringCharge__c);}
                    if(standing_charge.indexOf('.') == -1)
                    {standing_charge += '.000  p/day';}////SUBSTRING(standing_charge+"000",0,STRINGINDEXOF(standing_charge+"000",".")+4)
                    else{
                        String standing_charge_def = String.valueOf(standing_charge) + '000';
                        Integer num = (standing_charge_def.indexOf('.')+4);
                        standing_charge = standing_charge_def.substring(0,num)+' p/day';
                    }   
                    eachRec.put('StandingCharge',standing_charge);
                }   
            }
            if(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Site_Addition_Parent__c == null)
            {
                eachRec.put('DealType', cli.vlocity_cmt__ContractId__r.vlocity_cmt__OpportunityId__r.Recordtype.Name);
            }
            else
            {
                String site_Addition = 'Site Addition';
                eachRec.put('DealType',(Object)site_Addition);
            }   
            eachRec.put('Id', cli.Id);
            eachRec.put('EffectiveToDate', Date.valueOf(cli.vlocity_cmt__EffectiveEndDate__c));
            eachRec.put('EffectiveFromDate', cli.vlocity_cmt__EffectiveStartDate__c);
            eachRec.put('Status', cli.vlocity_cmt__LineStatus__c);
            eachRec.put('ServicePointStartDate', cli.SWAN_Service_Point_Start_Date__c);
            eachRec.put('ServicePointNumber', cli.SWAN_Service_Point__r.vlocity_cmt__ServicePointNumber__c);
            return eachRec;
        }
}