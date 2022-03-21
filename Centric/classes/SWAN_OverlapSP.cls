global with sharing class SWAN_OverlapSP implements vlocity_cmt.VlocityOpenInterface {

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
            if (methodName.equals('calculateOverlap'))
            {
                calculateOverlap(inputMap,outputMap,options);
            }else if (methodName.equals('get_HH_Only_SP'))
            {
                get_HH_Only_SP(inputMap,outputMap,options);
            }else
            {
                result = false;
            }   
        } 
        catch(Exception e)
        {System.debug('SWAN_OverlapSP:invokeMethod -> exception: '+e);
            result = false;}
        
        return result;
    
    }

    /*private Boolean getServicePointsFromQuoteId(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        String masterQuoteId = String.ValueOf(inputMap.get('ContextId'));

        List<Quote> lstServicePointQuotes = [SELECT id,status,vlocity_cmt__defaultservicepointid__c,vlocity_cmt__parentquoteid__c,swan_offer_start_date__c,swan_offer_end_date__c, 
            vlocity_cmt__parentquoteid__r.swan_offer_start_date__c, vlocity_cmt__parentquoteid__r.swan_offer_end_date__c 
            FROM Quote 
            WHERE (vlocity_cmt__DefaultServicePointId__c != null 
            AND vlocity_cmt__ParentQuoteId__c = :masterQuoteId 
            AND vlocity_cmt__ParentQuoteId__r.Status != 'Accepted' 
            AND vlocity_cmt__ParentQuoteId__r.Status != 'Contract Issued') 
            LIMIT 50000];

        if(lstServicePointQuotes.size() == 0){
            return false;
        }

        List<Id> lstServicePointIds = new List<Id>();
        for(Quote q : lstServicePointQuotes){
            lstServicePointIds.Add(q.id);
        }
        outputMap.put('listOfIds', lstServicePointIds);
        outputMap.put('QuoteEndDate',lstServicePointQuotes.get(0).vlocity_cmt__parentquoteid__r.swan_offer_end_date__c);
        outputMap.put('QuoteStartDate',lstServicePointQuotes.get(0).vlocity_cmt__parentquoteid__r.swan_offer_start_date__c);

        return true;
    }*/
    
    public Boolean calculateOverlap(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
    
    Boolean isQuote = Boolean.valueOf(String.ValueOf(inputMap.get('isQuote')));
    List<Object> OverlapSupplyPoints = new List<Object>();
    Map<String,Object> mapSPObjects = new Map<String,Object>();
    
    if(isQuote)
    {
        String masterQuoteId = String.ValueOf(inputMap.get('ContextId'));
        String query = 'Select id, Name, vlocity_cmt__ServicePointId__c, vlocity_cmt__ServicePointId__r.Name,'+ 
            'vlocity_cmt__ServicePointId__r.vlocity_cmt__ServicePointNumber__c, Status, UsageEndDate, '+
            'vlocity_cmt__ActivationDate__c, vlocity_cmt__ContractId__c, vlocity_cmt__ContractId__r.ContractNumber from Asset '+
            'where Status != \'Cancelled\' AND Status != \'Terminated\' AND vlocity_cmt__ContractId__r.Status IN (\'Contract Counter Signed\',\'Contract Signed\''+
            ',\'Contract Live\') AND ';
        
        List<Quote> qList = [Select id, vlocity_cmt__DefaultServicePointId__c, SWAN_Service_Point_Start_Date__c, SWAN_Service_Point_End_Date__c 
            From Quote where vlocity_cmt__ParentQuoteId__c=:masterQuoteId and vlocity_cmt__ParentQuoteId__r.Status != 'Accepted' and 
            vlocity_cmt__ParentQuoteId__r.Status != 'Contract Issued' and vlocity_cmt__DefaultServicePointId__c != null]; 
        
        if(qList != null && qList.size() > 0)
        {
            Integer qCount = qList.size();
            Integer i=1;
            String whereQuery = '';
            for(Quote qt:qList)
            {
                
                String startDateString = string.valueOf(qt.SWAN_Service_Point_Start_Date__c);
                String endDateString = string.valueOf(qt.SWAN_Service_Point_End_Date__c);
                //String startDateString = qt.SWAN_Service_Point_Start_Date__c.Year()+'-'+((qt.SWAN_Service_Point_Start_Date__c.month()).length()<2?'0'+qt.SWAN_Service_Point_Start_Date__c.month():qt.SWAN_Service_Point_Start_Date__c.month())+'-'+((qt.SWAN_Service_Point_Start_Date__c.day()).length()<2?'0'+qt.SWAN_Service_Point_Start_Date__c.day():qt.SWAN_Service_Point_Start_Date__c.day());
                //String endDateString = qt.SWAN_Service_Point_End_Date__c.Year()+'-'+qt.SWAN_Service_Point_End_Date__c.month()+'-'+qt.SWAN_Service_Point_End_Date__c.day();
                //Date startDate = date.valueOf(startDateString);
                //Date endDate = date.valueOf(endDateString);
                
                Id spId = qt.vlocity_cmt__DefaultServicePointId__c;
                whereQuery += '(((UsageEndDate >='+startDateString+' AND vlocity_cmt__ActivationDate__c <='+startDateString+') OR '+
                '(UsageEndDate >='+endDateString+' AND vlocity_cmt__ActivationDate__c <='+endDateString+') OR '+
                '(UsageEndDate <='+endDateString+' AND vlocity_cmt__ActivationDate__c >='+startDateString+') OR '+
                '(UsageEndDate >='+startDateString+' AND UsageEndDate <='+endDateString+' AND vlocity_cmt__ActivationDate__c <='+startDateString+')) AND '+
                'vlocity_cmt__ServicePointId__c = \''+spId+'\') OR ';
                
                if(i<=500 && i != qCount)
                {
                    i++;
                }
                else
                {
                    String finalQuery = query + '(' + whereQuery.removeEndIgnoreCase('OR ') + ')'; 
                    system.debug('===== '+finalQuery);
                    List<Asset> asstList = database.Query(finalQuery);
                    system.debug('asstList size'+asstList.size());
                    if(asstList != null && asstList.size() > 0)
                    {
                        for(Asset ast:asstList)
                        {
                            Map<String, Object> eachRec = pushEachRecord(ast);
                            OverlapSupplyPoints.add(eachRec);
                            mapSPObjects.put((String)eachRec.get('SPNumber'), eachRec);
                        }
                    }
                
                    qCount = qCount - i;
                    i = 1;
                    whereQuery = '';
                }
            }
        }
    }
    else
    {
        Date startDate= Date.valueOf(String.ValueOf(inputMap.get('startDate')));
        Date endDate= Date.valueOf(String.ValueOf(inputMap.get('endDate')));
        List<Object> tempList = (List<object>)inputMap.get('spList');
        List<Id> spList = new List<Id>();
        
        for(Object str:tempList)
        {
            spList.add(String.valueOf(str));
        }
        for(Asset ast: [Select id, Name, vlocity_cmt__ServicePointId__c, vlocity_cmt__ServicePointId__r.Name, 
            vlocity_cmt__ServicePointId__r.vlocity_cmt__ServicePointNumber__c, Status, UsageEndDate, vlocity_cmt__ActivationDate__c, 
            vlocity_cmt__ContractId__c, vlocity_cmt__ContractId__r.ContractNumber from Asset where Status != 'Cancelled'AND Status != 'Terminated' AND 
            vlocity_cmt__ContractId__r.Status IN ('Contract Counter Signed','Contract Signed','Contract Live') AND 
            vlocity_cmt__ServicePointId__c IN: SPList AND 
            ((UsageEndDate >= :startDate AND vlocity_cmt__ActivationDate__c <= :startDate) OR 
            (UsageEndDate >= :endDate AND vlocity_cmt__ActivationDate__c <= :endDate) OR 
            (UsageEndDate <= :endDate AND vlocity_cmt__ActivationDate__c >= :startDate) OR 
            (UsageEndDate >= :startDate AND UsageEndDate <= :endDate AND vlocity_cmt__ActivationDate__c <= :startDate)) limit 50000])
        {
            Map<String, Object> eachRec = pushEachRecord(ast);
            mapSPObjects.put((String)eachRec.get('SPNumber'), eachRec);
            //OverlapSupplyPoints.add(eachRec);
        }
        
        if(mapSPObjects.size()>0)
        {   
            OverlapSupplyPoints.addAll(mapSPObjects.values());
        }
    }
    
    if(OverlapSupplyPoints.size()>0)
    {
        outputMap.put('OverlapSupplyPoints',OverlapSupplyPoints);
    }
    
    outputMap.put('OverlapSize',mapSPObjects.size());
    
    return true;
    }
    
    public Boolean get_HH_Only_SP(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        //String oppId = String.ValueOf(inputMap.get('ContextId'));
        String oppId = String.ValueOf(inputMap.get('OpptyId'));
        String parentAcc;
        for(Opportunity opty : [SELECT accountid FROM Opportunity WHERE ID =:oppId]){
            parentAcc = opty.accountid;
        }
        List<Id> premisesList = new List<Id>();
        for(Account servacc : [SELECT vlocity_cmt__premisesid__c FROM Account WHERE parentid = :parentAcc]){
            premisesList.add(servacc.vlocity_cmt__premisesid__c);
        }
        List<vlocity_cmt__ServicePoint__c> allSPList = [SELECT id,vlocity_cmt__premisesid__c,vlocity_cmt__servicepointnumber__c FROM vlocity_cmt__ServicePoint__c WHERE vlocity_cmt__premisesid__c IN :premisesList AND RecordType.DeveloperName = 'SWAN_Electricity_Service_point' AND (((SWAN_Measurement_Class__c NOT IN ('A','B') AND SWAN_Measurement_Class_Ovrd__c = NULL) OR (SWAN_Measurement_Class_Ovrd__c NOT IN ('A','B') AND SWAN_Measurement_Class_Ovrd__c != NULL)))];
        System.debug('allSPList'+allSPList);
        System.debug('size'+allSPList.size());
        outputMap.put('sp_list_HH_Only_SP',allSPList);
        System.debug('sp_list_HH_Only_SP'+outputMap);
        return true;
        
    }
    
    public Map<String, Object> pushEachRecord(Asset ast)
    {
        Map<String, Object> eachRec = new Map<String, Object>();
        eachRec.put('Id', ast.id);
        eachRec.put('LineStatus', ast.Status);
        eachRec.put('EndDate', ast.UsageEndDate);
        eachRec.put('StartDate', ast.vlocity_cmt__ActivationDate__c);
        eachRec.put('ContractId', ast.vlocity_cmt__ContractId__c);
        eachRec.put('ContractNumber', ast.vlocity_cmt__ContractId__r.ContractNumber);
        eachRec.put('ServicePointNumber', ast.vlocity_cmt__ServicePointId__r.Name);
        eachRec.put('SPNumber', ast.vlocity_cmt__ServicePointId__r.vlocity_cmt__ServicePointNumber__c);
        return eachRec;
    }
}