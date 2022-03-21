global with sharing class SWAN_getQuoteRelatedData implements vlocity_cmt.VlocityOpenInterface {

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

        if (methodName == 'extractQuote') return extractQuote(inputMap, outputMap, options);
        if (methodName == 'extractQuote_Elec') return extractQuote_Elec(inputMap, outputMap, options);
        if (methodName == 'resetQLI') return resetQLI(inputMap, outputMap, options);
        if (methodName == 'setQLI') return setQLI(inputMap, outputMap, options);
        if (methodName == 'invokeClearPricingBatch') return invokeClearPricingBatch(inputMap, outputMap, options);
        if (methodName == 'getOLIs') return getOLIs(inputMap, outputMap, options);
        if (methodName == 'getQLIAttr') return getQLIAttr(inputMap, outputMap, options);
        if (methodName == 'setChildQuoteEAC') return setChildQuoteEAC(inputMap, outputMap, options);
        if (methodName == 'resetChildQuoteEAC') return resetChildQuoteEAC(inputMap, outputMap, options);
        if (methodName == 'getQuoteAttr') return getQuoteAttr(inputMap, outputMap, options);
        if (methodName == 'BG_UpdateQuoteWebhook')return BG_UpdateQuoteWebhook(inputMap, outputMap, options);
        if (methodName == 'checkConsumptionIssueforCustEAC') return checkConsumptionIssueforCustEAC(inputMap, outputMap, options);
        if (methodName == 'PopulatePicklist') return PopulatePicklist(inputMap, outputMap, options);
        if (methodName == 'fixedCostPeriodDefault') return fixedCostPeriodDefault(inputMap, outputMap, options);
        if (methodName == 'resetBA_QLI') return resetBA_QLI(inputMap, outputMap, options);
        if (methodName == 'getBusinessAccSubQuoteQLI') return getBusinessAccSubQuoteQLI(inputMap, outputMap, options);
        return false;
    }
    
    
    public Boolean extractQuote (Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options){
                
                String masterQuoteId = (string)inputMap.get('QuoteId'); 
                String quoteNumber = [Select Id, QuoteNumber From Quote where id=:masterQuoteId].QuoteNumber;
                Set<Id> spSet = new Set<ID>();
                Boolean priority1Issue = false;
                
                spSet = getSPsRelToChildQuote(masterQuoteId,true);
                QuoteLineItem qliObj = getProductId(masterQuoteId);
                List<AggregateResult> results = [select count(id) from vlocity_cmt__ServicePoint__c where id in : spSet AND SWAN_Priority_1_Issue__c  = true];
                Integer count = Integer.valueOf(results[0].get('expr0'));
                if(count > 0)
                {
                    priority1Issue = true;
                }
                
                List<Case> csList = [Select SWAN_Experian_Score__c from Case where IsClosed=true and SWAN_Opportunity__c=:qliObj.Quote.OpportunityId ORDER BY LastModifiedDate DESC Limit 1];
                if(csList != null && csList.size() > 0)
                    outputMap.put('CreditScore',csList[0].SWAN_Experian_Score__c);  
                outputMap.put('QuoteNumber',quoteNumber);                  
                outputMap.put('BaseProductId',qliObj.product2Id);
                outputMap.put('OpportunityId',qliObj.Quote.OpportunityId);
                outputMap.put('priority1Issue',priority1Issue);
                outputMap.put('ChildQuotesSize',spSet.size());
                outputMap.put('QuoteType',qliObj.Quote.Swan_Quote_Type__c);
        return true;
    }
    
    public Boolean extractQuote_Elec (Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options){
                
                String masterQuoteId = (string)inputMap.get('QuoteId'); 
                List<Quote> parentqList = [Select Id, QuoteNumber, SWAN_Passthrough_Option__c From Quote where id=:masterQuoteId];
                String quoteNumber = parentqList[0].QuoteNumber;
                Set<Id> spSet = new Set<ID>();
                Boolean ecoesIssue = false;
                Boolean mddvalIssue = false;
                Boolean supplycapacityIssue = false;
                Boolean consumptionIssue = false;
                Boolean NHH_Issue = false;
                
                spSet = getSPsRelToChildQuote(masterQuoteId,true);
                system.debug('spSet'+spSet);
                QuoteLineItem qliObj = getProductId(masterQuoteId);
                system.debug('qliObj'+qliObj);
                List<AggregateResult> results_ecoes = [select count(id) from vlocity_cmt__ServicePoint__c where id in : spSet AND SWAN_ECOES_Issue__c  = true];
                Integer count_ecoes = Integer.valueOf(results_ecoes[0].get('expr0'));
                system.debug('count_ecoes'+count_ecoes);
                if(count_ecoes > 0)
                {
                   ecoesIssue = true;
                }
                List<AggregateResult> results_MDD = [select count(id) from vlocity_cmt__ServicePoint__c where id in : spSet AND SWAN_MDD_Combination_Supported__c = false];
                Integer count_MDD = Integer.valueOf(results_MDD[0].get('expr0'));
                system.debug('count_MDD'+count_MDD);
                if(count_MDD > 0)
                {
                   mddvalIssue = true;
                }
                List<AggregateResult> results_supplycapacity = [select count(id) from vlocity_cmt__ServicePoint__c where id in : spSet AND SWAN_Supply_Capacity_Issue__c   = true];
                Integer count_supplycapacity = Integer.valueOf(results_supplycapacity[0].get('expr0'));
                system.debug('count_supplycapacity'+count_supplycapacity);
                if(count_supplycapacity > 0)
                {
                   supplycapacityIssue = true;
                }
                
                Integer spCount = 0;
                for(vlocity_cmt__ServicePoint__c each_SP : [Select id,SWAN_Measurement_Class__c,SWAN_Measurement_Class_Ovrd__c from vlocity_cmt__ServicePoint__c where id in : spSet])
                {
                    if(!String.isBlank(each_SP.SWAN_Measurement_Class_Ovrd__c))//to get correct measurement class
                    {
                        if(each_SP.SWAN_Measurement_Class_Ovrd__c != 'A' && each_SP.SWAN_Measurement_Class_Ovrd__c != 'B')//for HH
                        {
                            spCount++;
                        }
                    }
                    else
                    {
                        if(each_SP.SWAN_Measurement_Class__c != 'A' && each_SP.SWAN_Measurement_Class__c != 'B')//for HH
                        {
                            spCount++;
                        }
                    }
                }
                if(spCount <=0 && parentqList[0].SWAN_Passthrough_Option__c!= null && parentqList[0].SWAN_Passthrough_Option__c!= '')
                    NHH_Issue = true;
                //system.debug('====NHH_Issue'+NHH_Issue);
                
                List<vlocity_cmt__ServicePoint__c> results_consumption = getConsmpIssueRelatedSP(spSet);
                Integer count_consumption = results_consumption.size();
                system.debug('count_consumption'+count_consumption);
                if(count_consumption > 0)
                {
                   for(vlocity_cmt__ServicePoint__c each_SP : results_consumption)
                   {   
                       if(!String.isBlank(each_SP.SWAN_Measurement_Class_Ovrd__c))//to get correct measurement class
                       {
                           if((each_SP.SWAN_Measurement_Class_Ovrd__c != 'A' && each_SP.SWAN_Measurement_Class_Ovrd__c != 'B') && each_SP.SWAN_HH_Data_Uploaded_into_Gorilla__c == false)//for HH
                           {
                                consumptionIssue = true;
                           }
                       }
                       else
                       {
                           if((each_SP.SWAN_Measurement_Class__c != 'A' && each_SP.SWAN_Measurement_Class__c != 'B') && each_SP.SWAN_HH_Data_Uploaded_into_Gorilla__c == false)//for HH
                           {
                                consumptionIssue = true;
                           }
                       }
                   }
                }
                if(qliObj != null){
                    List<Case> csList = [Select SWAN_Experian_Score__c from Case where IsClosed=true and SWAN_Opportunity__c=:qliObj.Quote.OpportunityId ORDER BY LastModifiedDate DESC Limit 1];
                    if(csList != null && csList.size() > 0){
                        outputMap.put('CreditScore',csList[0].SWAN_Experian_Score__c);  
                    } 
                    
                    outputMap.put('BaseProductId',qliObj.product2Id);
                    outputMap.put('OpportunityId',qliObj.Quote.OpportunityId);
                    outputMap.put('QuoteType',qliObj.Quote.Swan_Quote_Type__c);
                }
                outputMap.put('QuoteNumber',quoteNumber);
                outputMap.put('ECOES_issues',ecoesIssue);
                outputMap.put('MDD_validation_issues',mddvalIssue);
                outputMap.put('Supply_Capacity_issues',supplycapacityIssue);
                outputMap.put('Consumption_issues',consumptionIssue);
                outputMap.put('ChildQuotesSize',spSet.size());
                outputMap.put('NHH_Issue',NHH_Issue);
    
        return true;
    }   
    
    
    public Boolean resetQLI (Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options){
                
                String masterQuoteId = (string)inputMap.get('QuoteId'); 
                String ProductId = (string) inputMap.get('BaseProductId');
                String OpportunityId = (string) inputMap.get('OpportunityId');
                Set<Id> spAQValIssueSet = new Set<ID>();
                List<QuoteLineItem> QLIList = new List<QuoteLineItem>();
                Boolean AqValIssue = false;
                Product2 pro = new Product2();
                if(!string.isBlank(ProductId))
                {
                    pro = [Select id, vlocity_cmt__JSONAttribute__c from Product2 where id = : ProductId];
                }
                spAQValIssueSet = getSPsRelToChildQuote(masterQuoteId,false);
                if(!spAQValIssueSet.isEmpty()) 
                {
                    List<AggregateResult> results = [Select count(Id) from OpportunityLineItem where vlocity_cmt__ServicePointId__c in : spAQValIssueSet AND SWAN_IsActive__c = true AND OpportunityId = : OpportunityId];
                    Integer count = Integer.valueOf(results[0].get('expr0'));
                    if(spAQValIssueSet.size()>0 && count != spAQValIssueSet.size())
                    {
                        AqValIssue = true;
                    }
                }
                
                Id recordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('GroupCart').getRecordTypeId();
                
                for(QuoteLineItem qli : [Select id,vlocity_cmt__JSONAttribute__c from QuoteLineItem where Product2Id = : ProductId AND Quote.vlocity_cmt__ParentQuoteId__c =: masterQuoteId AND Quote.RecordTypeId != : recordTypeId AND SWAN_needToReset__c = true])
                {
                    qli.vlocity_cmt__JSONAttribute__c = pro.vlocity_cmt__JSONAttribute__c;
                    qli.SWAN_needToReset__c = false;
                    QLIList.add(qli);
                }
                
                if(!QLIList.isEmpty())
                {
                    update QLIList;
                }
                outputMap.put('AqValIssue',AqValIssue);
            
    
        return true;
    }
    
    public Boolean setQLI (Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options){
                
                String masterQuoteId = (string)inputMap.get('QuoteId'); 
                String ProductId = (string)inputMap.get('BaseProductId');
                String OpptyId = (string)inputMap.get('OpportunityId');
                MAP<Id,QuoteLineItem> spQLIMap = new MAP<Id,QuoteLineItem>();
                List<QuoteLineItem> QLIList = new List<QuoteLineItem>();
                
                
                
                Id recordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('GroupCart').getRecordTypeId();
                
                for(QuoteLineItem qli : [Select id,vlocity_cmt__JSONAttribute__c,Quote.vlocity_cmt__DefaultServicePointId__c from QuoteLineItem where Product2Id = : ProductId AND Quote.vlocity_cmt__ParentQuoteId__c =: masterQuoteId AND Quote.RecordTypeId != : recordTypeId])
                {
                    spQLIMap.put(qli.Quote.vlocity_cmt__DefaultServicePointId__c,qli);
                    
                }
                //system.debug('spQLIMap===>'+spQLIMap);
                for(OpportunityLineItem oli : [Select id,vlocity_cmt__JSONAttribute__c,vlocity_cmt__ServicePointId__c from OpportunityLineItem where OpportunityId=:OpptyId and SWAN_IsActive__c=true and vlocity_cmt__ServicePointId__c in : spQLIMap.keyset()])
                {
                    QuoteLineItem qli = new QuoteLineItem();
                    qli.Id = spQLIMap.get(oli.vlocity_cmt__ServicePointId__c).Id;
                    qli.vlocity_cmt__JSONAttribute__c = oli.vlocity_cmt__JSONAttribute__c;
                    qli.SWAN_needToReset__c = true;
                    QLIList.add(qli);
                }
                if(!QLIList.isEmpty())
                {
                    update QLIList;
                }
                //system.debug('QLIList===>'+QLIList);
    
        return true;
    }
    
    public Boolean checkConsumptionIssueforCustEAC (Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options){
                System.debug('In checkConsumptionIssueforCustEAC ');    
                Id recordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('GroupCart').getRecordTypeId();
                Set<Id> spConsumpIssueSet_NHH = new Set<ID>();
                Set<Id> spConsumpIssueSet = new Set<ID>();
                List<vlocity_cmt__ServicePoint__c> spConsmpIssueList = new List<vlocity_cmt__ServicePoint__c>();
                String masterQuoteId = (string)inputMap.get('QuoteId');
                String OpportunityId = (string)inputMap.get('OpportunityId');
                Boolean consumpIssue = false;
                for(Quote qt : [Select id, vlocity_cmt__DefaultServicePointId__c from quote where vlocity_cmt__ParentQuoteId__c = : masterQuoteId AND RecordTypeId != : recordTypeId AND vlocity_cmt__DefaultServicePointId__r.SWAN_Electralink_Retrieval_Status__c   = 'Error'])
                {
                    spConsumpIssueSet.add(qt.vlocity_cmt__DefaultServicePointId__c);
                }  
                System.debug('spConsumpIssueSet '+spConsumpIssueSet); 
                spConsmpIssueList = getConsmpIssueRelatedSP(spConsumpIssueSet);
                for(vlocity_cmt__ServicePoint__c each_SP : spConsmpIssueList)
                   {   
                       System.debug('each_SP.SWAN_Measurement_Class_Ovrd__c'+each_SP.SWAN_Measurement_Class_Ovrd__c);
                       System.debug('each_SP.SWAN_Measurement_Class__c '+each_SP.SWAN_Measurement_Class__c );
                       if(!String.isBlank(each_SP.SWAN_Measurement_Class_Ovrd__c))//to get correct measurement class
                       {
                           if(each_SP.SWAN_Measurement_Class_Ovrd__c == 'A' || each_SP.SWAN_Measurement_Class_Ovrd__c == 'B')//for NHH
                           {
                                spConsumpIssueSet_NHH.add(each_SP.Id);
                                
                           }
                       }
                       else
                       {
                           if(each_SP.SWAN_Measurement_Class__c == 'A' || each_SP.SWAN_Measurement_Class__c == 'B')//for NHH
                           {
                                spConsumpIssueSet_NHH.add(each_SP.Id);
                           }
                       }
                   }
                System.debug('spConsumpIssueSet_NHH'+spConsumpIssueSet_NHH); 
                if(!spConsumpIssueSet_NHH.isEmpty())
                {
                   List<AggregateResult> results = [Select count(Id) from OpportunityLineItem where vlocity_cmt__ServicePointId__c in : spConsumpIssueSet_NHH AND SWAN_IsActive__c = true AND OpportunityId = : OpportunityId];
                   Integer count = Integer.valueOf(results[0].get('expr0'));
                   if(spConsumpIssueSet_NHH.size()>0 && count != spConsumpIssueSet_NHH.size())
                    {
                        consumpIssue = true;
                    }
                }
                System.debug('consumpIssue'+consumpIssue);    

                outputMap.put('Consumption_issues_NHH',consumpIssue);
                System.debug('outputMap'+outputMap);
    
        return true;
    }
    
   public Boolean setChildQuoteEAC (Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options){
                
                String masterQuoteId = (string)inputMap.get('QuoteId'); 
                String ProductId = (string)inputMap.get('BaseProductId');
                String OpptyId = (string)inputMap.get('OpportunityId');
                MAP<Id,Quote> spQuoMap = new MAP<Id,Quote>();
                List<Quote> QUOList = new List<Quote>();
                
                
                
                Id recordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('GroupCart').getRecordTypeId();
                
                for(Quote quo : [Select id,swan_JSONAttribute__c,vlocity_cmt__DefaultServicePointId__c from Quote where vlocity_cmt__DefaultServicePointId__c != null AND vlocity_cmt__ParentQuoteId__c =: masterQuoteId AND Quote.RecordTypeId != : recordTypeId])
                {
                    spQuoMap.put(quo.vlocity_cmt__DefaultServicePointId__c,quo);
                    
                }
                //system.debug('spQuoMap===>'+spQuoMap);
                for(OpportunityLineItem oli : [Select id,vlocity_cmt__JSONAttribute__c,vlocity_cmt__ServicePointId__c from OpportunityLineItem where OpportunityId=:OpptyId and SWAN_IsActive__c=true and vlocity_cmt__ServicePointId__c in : spQuoMap.keyset()])
                {
                    Quote quo1 = new Quote();
                    quo1.Id = spQuoMap.get(oli.vlocity_cmt__ServicePointId__c).Id;
                    quo1.swan_JSONAttribute__c = oli.vlocity_cmt__JSONAttribute__c;
                    quo1.SWAN_NeedToReset__c = true;
                    QUOList.add(quo1);
                }
                if(!QUOList.isEmpty())
                {
                    update QUOList;
                }
                //system.debug('QUOList===>'+QUOList);
    
        return true;
    }
    
    public Boolean resetChildQuoteEAC (Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options){
                
                String masterQuoteId = (string)inputMap.get('QuoteId'); 
                List<Quote> QUOList = new List<Quote>();
                
                
                
                Id recordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('GroupCart').getRecordTypeId();
                
                for(Quote quo : [Select id,swan_JSONAttribute__c,vlocity_cmt__DefaultServicePointId__c from Quote where vlocity_cmt__DefaultServicePointId__c != null AND vlocity_cmt__ParentQuoteId__c =: masterQuoteId AND Quote.RecordTypeId != : recordTypeId AND SWAN_NeedToReset__c = true])
                {
                    Quote quo1 = new Quote();
                    quo1.Id = quo.Id;
                    quo1.swan_JSONAttribute__c = null;
                    quo1.SWAN_NeedToReset__c = false;
                    QUOList.add(quo1);
                    
                }
                
                if(!QUOList.isEmpty())
                {
                    update QUOList;
                }
                //system.debug('QUOList===>'+QUOList);
    
        return true;
    }
    
    public Set<Id> getSPsRelToChildQuote(String masterQuoteId , boolean aqValIssue)
    {
        Id recordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('GroupCart').getRecordTypeId();
        Set<Id> spSet = new Set<ID>();
        if(aqValIssue)
        {
            for(Quote qt : [Select id, vlocity_cmt__DefaultServicePointId__c from quote where vlocity_cmt__ParentQuoteId__c = : masterQuoteId AND RecordTypeId != : recordTypeId])
            {
                spSet.add(qt.vlocity_cmt__DefaultServicePointId__c);
            }
        }
        else{
            for(Quote qt : [Select id, vlocity_cmt__DefaultServicePointId__c from quote where vlocity_cmt__ParentQuoteId__c = : masterQuoteId AND RecordTypeId != : recordTypeId AND vlocity_cmt__DefaultServicePointId__r.SWAN_AQ_Validation_Issue__c = true])
            {
                spSet.add(qt.vlocity_cmt__DefaultServicePointId__c);
            }
        }
            
        return spSet;
    }
    
    public List<vlocity_cmt__ServicePoint__c> getConsmpIssueRelatedSP(Set<Id>  set_of_SP)
    {
        List<vlocity_cmt__ServicePoint__c> spConsmpIssueList = new List<vlocity_cmt__ServicePoint__c>();
        for(vlocity_cmt__ServicePoint__c consmp_sp : [Select id,SWAN_HH_Data_Uploaded_into_Gorilla__c,SWAN_Measurement_Class__c,SWAN_Measurement_Class_Ovrd__c from vlocity_cmt__ServicePoint__c where id in : set_of_SP AND SWAN_Electralink_Retrieval_Status__c = 'Error'])
        {
            spConsmpIssueList.add(consmp_sp);
        }
        return spConsmpIssueList;
    }   
    
    public QuoteLineItem getProductId(String masterQuoteId)
    {
        QuoteLineItem qliObj ;
         for(QuoteLineItem qli : [Select id,Product2Id,Quote.OpportunityId,Quote.Swan_Quote_Type__c from QuoteLineItem where QuoteId = :masterQuoteId AND Product2.vlocity_cmt__IsOrderable__c = true limit 1])
         {
             qliObj = qli;
         }
         
         return qliObj;
    }   
    
    public Boolean invokeClearPricingBatch(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options)
    {
        String createDataComponent = JSON.serializePretty(inputMap.get('CreateDataComponent')); 
        String OpportunityId = (string)inputMap.get('OpportunityId'); 
        String quoteId = (string)inputMap.get('QuoteId'); 
        String authHostName = (string)inputMap.get('GorillaAuthorizationHostName'); 
        String secret = (string)inputMap.get('GorillaSecret'); 
        String hostName = (string)inputMap.get('GorillaHostName'); 
        String fuelType = (string) inputMap.get('FuelTypeVal');
        String ProductId = (string) inputMap.get('BaseProductId');
        
        database.executeBatch(new SWAN_ClearPrices(quoteId, createDataComponent, OpportunityId, authHostName, secret, hostName,fuelType,ProductId),250);
        return true;
    }
    
    public Boolean getOLIs(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options)
    {
        String OpportunityId=(string)inputMap.get('OpportunityId');
        Map<string,object>FinalMap = new Map<string,object>();
        for(OpportunityLineItem oli : [SELECT id,vlocity_cmt__ServicePointId__c,vlocity_cmt__JSONAttribute__c from OpportunityLineItem where SWAN_IsActive__c=true and OpportunityId=:OpportunityId])
        {
            if(!String.isblank(oli.vlocity_cmt__JSONAttribute__c))
            {
                Map<string,object> AttributeMap = new Map<string,object>();
                for(object Attr : (List<object>) ((Map<String, Object>)JSON.deserializeUntyped(oli.vlocity_cmt__JSONAttribute__c)).get('SWAN_SP_ATT_CAT'))
                {
                    String key = (string) ((map<string,object>)Attr).get('attributeuniquecode__c');
                    if(key == 'SWAN_ATT_CUST_AQ' || key == 'SWAN_ATT_CUST_EFF_FROM' || key == 'SWAN_ATT_CUST_EFF_TO' || key == 'SWAN_ATT_CUST_EUC' || key =='SWAN_ATT_CUST_SOQ')
                    {
                        AttributeMap.put(key,((MAP<string,object>)((map<string,object>)Attr).get('attributeRunTimeInfo')).get('value'));
                    }
                }
                FinalMap.put(oli.vlocity_cmt__ServicePointId__c,AttributeMap);
            }
        }
        outputMap.put('JsonNewOLI',FinalMap);
        return true;
    }
    
    public Boolean getQuoteAttr(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options)
    {
        String MasterQuoteId = (string)inputMap.get('QuoteId');
        Id recordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('GroupCart').getRecordTypeId();
        Map<string,object>FinalMap = new Map<string,object>();
        for(Quote quo : [SELECT id,vlocity_cmt__DefaultServicePointId__c,swan_JSONAttribute__c from Quote where vlocity_cmt__ParentQuoteId__c=:MasterQuoteId AND RecordTypeId != : recordTypeId AND vlocity_cmt__DefaultServicePointId__c != null])
        {
            if(!String.isblank(quo.SWAN_JSONAttribute__c))
            {
                Map<string,object> AttributeMap = new Map<string,object>();
                for(object Attr : (List<object>) ((Map<String, Object>)JSON.deserializeUntyped(quo.SWAN_JSONAttribute__c)).get('SWAN_SP_ATT_CAT'))
                {
                    String key = (string) ((map<string,object>)Attr).get('attributeuniquecode__c');
                    if(key == 'SWAN_ATT_CUST_EAC')
                    {
                        AttributeMap.put(key,((MAP<string,object>)((map<string,object>)Attr).get('attributeRunTimeInfo')).get('value'));
                    }
                }
                FinalMap.put(quo.vlocity_cmt__DefaultServicePointId__c,AttributeMap);
            }
        }
        outputMap.put('JsonNewEAC',FinalMap);
        return true;
    }
    
    public Boolean getQLIAttr(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options)
    {
                String masterQuoteId = (string)inputMap.get('QuoteId'); 
                String ProductId = (string)inputMap.get('BaseProductId');
              //  String OpptyId = (string)inputMap.get('OpportunityId');
                MAP<Id,QuoteLineItem> spQLIMap = new MAP<Id,QuoteLineItem>();
                List<QuoteLineItem> QLIList = new List<QuoteLineItem>();
                
                
                
        Id recordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('GroupCart').getRecordTypeId();
                
               
        Map<string,object>FinalMap = new Map<string,object>();
        for(QuoteLineItem qli : [Select id,vlocity_cmt__JSONAttribute__c,Quote.vlocity_cmt__DefaultServicePointId__c from QuoteLineItem where Product2Id = : ProductId AND Quote.vlocity_cmt__ParentQuoteId__c =: masterQuoteId AND Quote.RecordTypeId != : recordTypeId])
        {
        system.debug('gsgsgsg'+qli.id);
            if(!String.isblank(qli.vlocity_cmt__JSONAttribute__c))
            {
             system.debug('gsgsgqlisg'+qli);
                Map<string,object> AttributeMap = new Map<string,object>();
                for(object Attr : (List<object>) ((Map<String, Object>)JSON.deserializeUntyped(qli.vlocity_cmt__JSONAttribute__c)).get('SWAN_QUOTE_CONFIG_ATT_CAT'))
                {
                    String key = (string) ((map<string,object>)Attr).get('attributeuniquecode__c');
                    if(key == 'SWAN_ATT_HH_RATE_STRUCT')
                    {
                        AttributeMap.put(key,((MAP<string,object>)((MAP<string,object>)((map<string,object>)Attr).get('attributeRunTimeInfo')).get('selectedItem')).get('value'));
                    }
                }
                FinalMap.put(qli.Quote.vlocity_cmt__DefaultServicePointId__c,AttributeMap);
            }
        }
         system.debug('FinalMap'+FinalMap);
        outputMap.put('JsonRateStru',FinalMap);
        return true;
    }
    
    public Boolean BG_UpdateQuoteWebhook(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options)
    {
        String masterQuoteId=(string)inputMap.get('ContextId');
        string QuoteStatus = (string)inputMap.get('QuoteStatus');
        List<Quote>UpdateQuoteList = new List<Quote>();
        for(Quote qt : [SELECT id,status from quote where (id=:masterQuoteId or vlocity_cmt__ParentQuoteId__c=:masterQuoteId) and recordtype.developername!='GroupCart'])
        {
            qt.status=QuoteStatus;
            UpdateQuoteList.add(qt); 
        }
        
        if(UpdateQuoteList.size()<=3000)
            update UpdateQuoteList;
        else
            Database.executeBatch(new BG_UpdateQuoteWebhookBatch(masterQuoteId,QuoteStatus),2000);
        return true;
    }
    
    public Boolean PopulatePicklist(Map < String, Object > input, Map < String, Object > outMap, Map < String, Object > options) 
    {
        List < Map < String, String >> uiOptions = new List < Map < String, String >> ();
        String fxdCostPrd = ((Map<String, Object>)input.get('Product')).get('FixedCostPeriod')!=null && ((Map<String, Object>)input.get('Product')).get('FixedCostPeriod')!=''?(String)((Map<String, Object>)input.get('Product')).get('FixedCostPeriod'):null;
        if(fxdCostPrd != null && fxdCostPrd != '')
        {
            for(String rel:fxdCostPrd.split(';'))
            {
                Map < String, String > tempMap = new Map < String, String > ();
                tempMap.put('name', rel);
                tempMap.put('value', rel);
                UIoptions.add(tempMap);
            }
        }
        outMap.put('options', uiOptions);
        return true;
    }
    
    public Boolean fixedCostPeriodDefault(Map < String, Object > input, Map < String, Object > outMap, Map < String, Object > options) 
    {
        String fxdCostPrd = ((Map<String, Object>)input.get('Product')).get('FixedCostPeriod')!=null && ((Map<String, Object>)input.get('Product')).get('FixedCostPeriod')!=''?(String)((Map<String, Object>)input.get('Product')).get('FixedCostPeriod'):null;
        if(fxdCostPrd != null && fxdCostPrd != '')
        {
            for(String rel:fxdCostPrd.split(';'))
            {
                if(rel == 'Full Contract Duration')
                {
                    String full_Contract_Duration ='Full Contract Duration';
                    Map<String, Object> offerDatesMap = (Map<String, Object>)input.get('OfferDates');
                    offerDatesMap.put('FixedCostPeriodNew',full_Contract_Duration);
                    outMap.put('OfferDates', offerDatesMap);
                }
            }
        }
        System.debug('outMap'+outMap);
        return true;
    }
    
    public Boolean resetBA_QLI(Map < String, Object > input, Map < String, Object > outMap, Map < String, Object > options) 
    {
        String masterQuoteId=(string)input.get('ContextId');
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();
        for(QuoteLineItem QLI: [Select id, product2Id,vlocity_cmt__JSONAttribute__c,product2.vlocity_cmt__JSONAttribute__c From quoteLineItem Where Quote.vlocity_cmt__ParentQuoteId__c=:masterQuoteId and Quote.RecordType.DeveloperName = 'SubQuote' and Quote.vlocity_cmt__QuoteGroupId__r.vlocity_cmt__MemberType__c = 'Business_Account' and Product2.vlocity_cmt__Type__c='Volume Summary' and ((Product2.vlocity_cmt__SubType__c='Monthly Summary' AND vlocity_cmt__UsageQuantity__c != null) OR Product2.vlocity_cmt__SubType__c='Summary Total')])
        {
            qli.vlocity_cmt__JSONAttribute__c = qli.Product2.vlocity_cmt__JSONAttribute__c;
            qliList.add(qli);
        }
        if(qliList.size()>0)
            update qliList;
        return true;
    }
    
   public Boolean getBusinessAccSubQuoteQLI(Map < String, Object > input, Map < String, Object > outMap, Map < String, Object > options) 
    {
        String masterQuoteId=(string)input.get('QuoteId');
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();
        for(Quote qt : [SELECT id,name,(select id,product2.ProductCode,vlocity_cmt__UsageUnitPrice__c from QuoteLineItems where product2.vlocity_cmt__type__c='Flex Fee') FROM Quote WHERE RecordType.DeveloperName = 'SubQuote' AND vlocity_cmt__ParentQuoteId__c =: masterQuoteId AND vlocity_cmt__QuoteGroupId__r.vlocity_cmt__MemberType__c = 'Business_Account' Limit 1])
                    {
                        for(QuoteLineItem qli : qt.QuoteLineItems)
                        {
                           if(qli.product2.ProductCode=='BG_BAD_DEBT')
                           {
                                outMap.put('BadDebtVal',qli.vlocity_cmt__UsageUnitPrice__c);
                           }else if(qli.product2.ProductCode=='BG_XOSERVE')
                           {
                               outMap.put('XoserveVal',qli.vlocity_cmt__UsageUnitPrice__c);
                           }else if(qli.product2.ProductCode=='BG_GREEN_GAS_LEVY')
                           {
                               outMap.put('GreenGasLevVal',qli.vlocity_cmt__UsageUnitPrice__c);
                           }else if(qli.product2.ProductCode=='BG_BALANCE_IMBALANCE_PREMIUM')
                           {
                               outMap.put('BalImBalVal',qli.vlocity_cmt__UsageUnitPrice__c);
                           }else if(qli.product2.ProductCode=='BG_OPEX')
                           {
                               outMap.put('OpexVal',qli.vlocity_cmt__UsageUnitPrice__c);
                           }else if(qli.product2.ProductCode=='BG_COST_OF_CASH')
                           {
                               outMap.put('CostCashVal',qli.vlocity_cmt__UsageUnitPrice__c);
                           }else if(qli.product2.ProductCode=='BG_UNIFIED_RISK')
                           {
                               outMap.put('UniRiskVal',qli.vlocity_cmt__UsageUnitPrice__c);
                           }else if(qli.product2.ProductCode=='BG_CONTRIBUTION_MARGIN')
                           {
                               outMap.put('ContMarVal',qli.vlocity_cmt__UsageUnitPrice__c);
                           }else if(qli.product2.ProductCode=='BG_BROKER_COMMISSION')
                           {
                               outMap.put('BrokComVal',qli.vlocity_cmt__UsageUnitPrice__c);
                           }
                        }
                    }
        return true;
    }
}