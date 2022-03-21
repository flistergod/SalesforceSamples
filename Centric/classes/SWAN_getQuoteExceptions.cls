global with sharing class SWAN_getQuoteExceptions implements vlocity_cmt.VlocityOpenInterface {

 /**
     * Top level call by a Vlocity Remote Action
     *
     * @param inputMap  - The input provided to the Remote Action
     * @param outputMap - Any output to be provided back to the Remote Action
     * @param options   - Any options to aid in the execution of this class
     *
     * @returns true if the method completes successfully, false otherwise
     */ 
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) 
    {
        if (methodName == 'extractQuoteExceptions') return extractQuoteExceptions(inputMap, outputMap, options);  
        
        return false;
    }
    
    Map<String, Object> eachRec = new Map<String, Object>();
    public Boolean extractQuoteExceptions(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options)
    {
        //List<Object> ServicePointList = new List<Object>();
        Map<String, Object> ServicePointMap = new Map<String, Object>();
        String masterQuoteId = (string)inputMap.get('ContextId');
        getQuoteDetails(masterQuoteId);
        getAQValidationIssue(masterQuoteId);
        getSupplyCapacityIssue(masterQuoteId);
        getPriority1Issue(masterQuoteId);
        getECOESIssue(masterQuoteId);
        getMDDValidationIssue(masterQuoteId);
        getConsumptionIssue(masterQuoteId);
        getOverlapSP(masterQuoteId);
        
        //ServicePointList.add(eachRec);
        outputMap.put('ServicePointList',eachRec);
        return true;
    }
    
    public void getQuoteDetails(String masterQuoteId)
    {
        List<Quote> quoteDetails = [Select id, SWAN_Quote_for_Fuel_Type__c from Quote where Id=:masterQuoteId];
        if(quoteDetails != null && quoteDetails[0].SWAN_Quote_for_Fuel_Type__c == 'Gas')
            eachRec.put('isGas','true');
        else
            eachRec.put('isGas','false');
    }
    
    public void getAQValidationIssue(String masterQuoteId)
    {

        /*
        List<Quote> aqValIssue = [Select Id from Quote where RecordType.Name='Sub Quote' 
        and (vlocity_cmt__DefaultServicePointId__r.SWAN_AQ_Validation_Issue__c=true or vlocity_cmt__DefaultServicePointId__r.SWAN_Priority_1_Issue__c=true)
        and vlocity_cmt__ParentQuoteId__c=:masterQuoteId Limit 1];
        if(aqValIssue != null && aqValIssue.size() > 0)
            eachRec.put('AQValidationIssueResult','false');
        else
            eachRec.put('AQValidationIssueResult','true');

            */
      

        
            //get each subquote and its sp
        List<Quote> aqValIssue = [Select Id, vlocity_cmt__DefaultServicePointId__c, OpportunityId
        from Quote where RecordType.Name='Sub Quote' 
        and (vlocity_cmt__DefaultServicePointId__r.SWAN_AQ_Validation_Issue__c=true
        and vlocity_cmt__ParentQuoteId__c=:masterQuoteId)];

        List<Id> OppIds = new List<Id>();
        List<Id> SpsIds = new List<Id>(); 

          //if any aq issue
        if(aqValIssue != null && aqValIssue.size() > 0) {

            for(Quote q:aqValIssue){

                OppIds.add(q.OpportunityId);
                SpsIds.add(Q.vlocity_cmt__DefaultServicePointId__c);
            }


            //get oli for and sp
            List<OpportunityLineItem> olis= [
                Select Id, SWAN_IsActive__c, vlocity_cmt__ServicePointId__c, OpportunityId, vlocity_cmt__JSONAttribute__c 
                from OpportunityLineItem
                where OpportunityId in :OppIds
                and(SWAN_IsActive__c=true and vlocity_cmt__ServicePointId__c in :SpsIds)
                ];




            if(olis == null || olis.size() == 0){
            
                eachRec.put('AQValidationIssueResult','false');
                return;

            
            }else{

                //find wich sp went on set customer aq
                Integer validAQCustomer=0;


                for(Integer i=0;i<olis.size();i++){

                OpportunityLineItem olii= olis[i];
               
                if(olii!=null){

                Map<String, Object> olii_jsonAtribute =(Map<String, Object>) Json.deserializeUntyped(olii.vlocity_cmt__JSONAttribute__c);

                if(olii_jsonAtribute!=null){

                    List<Object>  swan_SP= (List<Object>) olii_jsonAtribute.get('SWAN_SP_ATT_CAT');

                    if(swan_SP!=null && swan_SP.size()>0){

                        Map<String, Object> firstOli = (Map<String, Object>) swan_SP[0];

                        try {
                    
                            String AQ_Customer=(String) firstOli.get('attributeuniquecode__c');
        
                            if(AQ_Customer.equals('SWAN_ATT_CUST_AQ')==false){
                                //one of the sp didnt went on the set customer aq
                                eachRec.put('AQValidationIssueResult','false');
                                return;
        
                            }
                            else{validAQCustomer++;}
                            
        
                        } catch(Exception e) {
                            System.debug(e.getMessage());
                            eachRec.put('AQValidationIssueResult','false');
                            return;
                        }

                        }
                        else{
                            eachRec.put('AQValidationIssueResult','false');
                            return;
                        }
                    }

                    else{
                        eachRec.put('AQValidationIssueResult','false');
                        return;
                    }
                
                }

                }


                if(validAQCustomer==aqValIssue.size()){
                    
                    eachRec.put('AQValidationIssueResult','true');
                    return;

                }
                else{

                    eachRec.put('AQValidationIssueResult','false');
                    return;
                }
            }
        
        }
        //no aq issues found on any sp
        else
            eachRec.put('AQValidationIssueResult','true');
    }
    
    public void getSupplyCapacityIssue(String masterQuoteId)
    {
        List<Quote> supplyCapIssue = [Select id from Quote where RecordType.Name='Sub Quote' and vlocity_cmt__DefaultServicePointId__r.SWAN_Supply_Capacity_Issue__c=true and vlocity_cmt__ParentQuoteId__c=:masterQuoteId Limit 1];
        if(supplyCapIssue != null && supplyCapIssue.size() > 0)
            eachRec.put('SupplyCapacityIssueResult','false');
        else
            eachRec.put('SupplyCapacityIssueResult','true');
    }
    
    public void getPriority1Issue(String masterQuoteId)
    {
        List<Quote> priorityIssue = [Select id from Quote where RecordType.Name='Sub Quote' and vlocity_cmt__DefaultServicePointId__r.SWAN_Priority_1_Issue__c=true and vlocity_cmt__ParentQuoteId__c=:masterQuoteId Limit 1];
        if(priorityIssue != null && priorityIssue.size() > 0)
            eachRec.put('Priority1IssueResult','false');
        else
            eachRec.put('Priority1IssueResult','true');
    }
    
    public void getECOESIssue(String masterQuoteId)
    {
        List<Quote> ecoesIssue = [Select id from Quote where RecordType.Name='Sub Quote' and vlocity_cmt__DefaultServicePointId__r.SWAN_ECOES_Issue__c=true and vlocity_cmt__ParentQuoteId__c=:masterQuoteId Limit 1];
        if(ecoesIssue != null && ecoesIssue.size() > 0)
            eachRec.put('ECOESIssueResult','false');
        else
            eachRec.put('ECOESIssueResult','true');
    }
    
    public void getMDDValidationIssue(String masterQuoteId)
    {
        List<Quote> MDDIssue = [Select id from Quote where RecordType.Name='Sub Quote' and vlocity_cmt__DefaultServicePointId__r.SWAN_MDD_Combination_Supported__c=false and vlocity_cmt__ParentQuoteId__c=:masterQuoteId and vlocity_cmt__DefaultServicePointId__c != null Limit 1];
        if(MDDIssue != null && MDDIssue.size() > 0)
            eachRec.put('MDDValidationIssueResult','false');
        else
            eachRec.put('MDDValidationIssueResult','true');
    }
    
    public void getConsumptionIssue(String masterQuoteId)
    {
        List<Quote> consumptionIssue = [Select id from Quote where RecordType.Name='Sub Quote' and vlocity_cmt__DefaultServicePointId__r.SWAN_Electralink_Retrieval_Status__c='Error' and vlocity_cmt__ParentQuoteId__c=:masterQuoteId Limit 1];
        if(consumptionIssue != null && consumptionIssue.size() > 0)
            eachRec.put('ConsumptionIssueResult','false');
        else
            eachRec.put('ConsumptionIssueResult','true');
    }
    
    public void getOverlapSP(String masterQuoteId)
    {
        SWAN_OverlapSP overlapSpCls = new SWAN_OverlapSP();
        Map<String, Object> inputMapOverlap=new Map<String, Object>();
        Map<String, Object> outputMapOverlap=new Map<String, Object>();
        Map<String, Object> optionsOverlap=new Map<String, Object>();
        
        inputMapOverlap.put('ContextId',masterQuoteId);
        inputMapOverlap.put('isQuote',true);
        
        overlapSpCls.calculateOverlap(inputMapOverlap, outputMapOverlap, optionsOverlap);
        Integer OverlapSize = (outputMapOverlap.containsKey('OverlapSize')?(integer)outputMapOverlap.get('OverlapSize'):0);
        if((OverlapSize)>0)
            eachRec.put('OverlapSupplyPointsResults','false');
        else
            eachRec.put('OverlapSupplyPointsResults','true');
    }
}