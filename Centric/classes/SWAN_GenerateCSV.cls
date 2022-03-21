public without sharing class SWAN_GenerateCSV{
    static final String NUL = '';
    static final String SEP = '","';
    
    public static void generateCSVForATLAS(){

        List<String> statusList = new List<String> {'Contract Signed', 'Contract Counter Signed', 'Contract Live'};
        List<id> quoteIds = new List<id>();
        List<id> servicePointIds = new List<id>();
        List<id> contractIds = new List<Id>();
        Segment_Values__c segmentVal = Segment_Values__c.getOrgDefaults();
        String csv ='';
        Integer recordCount = 0;
        Boolean isRenewal = false;
        Boolean isUpgrade = false;
        Boolean isSiteAddition = false;
        Boolean isCustAQnull = true;
        Boolean isCustSOQnull = true;
        String cust_SOQ ='';
        String cust_AQ ='';
        String cust_AQ_fromdate ='';
        String cust_AQ_todate ='';
        Date fromdate;
        Date todate;
        
        
        Map<id,Contract> quoteIdToContractMap = new  Map<id,Contract>();
        
        List<Contract> liveContractList = new List<Contract>([SELECT id,vlocity_cmt__QuoteId__c, EndDate, Status FROM Contract WHERE Status IN :statusList]);
       
        for(Contract con :liveContractList){
            quoteIds.add(con.vlocity_cmt__QuoteId__c);
            quoteIdToContractMap.put(con.vlocity_cmt__QuoteId__c,con);
            contractIds.add(con.id);
        }
        
        List<Quote> quoteWithChildQuote = new List<Quote>(
            [SELECT id,Name,QuoteNumber,vlocity_cmt__PriceListId__c,vlocity_cmt__PriceListId__r.Name,SWAN_Offer_Start_Date__c,Account.Name, OpportunityID, Opportunity.recordtype.name, 
                recordtype.name, SWAN_Service_Point_End_Date__c, ContractId, 
                (SELECT id,Name,vlocity_cmt__DefaultServicePointId__c,recordType.Name,SWAN_Service_Point_Start_Date__c,SWAN_Service_Point_End_Date__c, vlocity_cmt__ParentQuoteId__c,vlocity_cmt__ParentQuoteId__r.SWAN_Site_Addition_Parent__c FROM vlocity_cmt__Quotes__r where Recordtype.Developername != 'GroupCart') 
                FROM Quote WHERE id IN :quoteIds ]);
        System.debug(quoteWithChildQuote);
    
    Map<Id,Quote> siteAdditionQuote = new Map<Id,Quote>(
            [SELECT id,Name,QuoteNumber,vlocity_cmt__PriceListId__c,vlocity_cmt__PriceListId__r.Name,SWAN_Offer_Start_Date__c,Account.Name, OpportunityID, Opportunity.recordtype.name, 
                recordtype.name, SWAN_Service_Point_End_Date__c, ContractId, vlocity_cmt__ValidationDate__c, SWAN_Site_Addition_Parent__c, SWAN_Site_Addition_Parent__r.vlocity_cmt__PriceListId__c, SWAN_Site_Addition_Parent__r.vlocity_cmt__PriceListId__r.Name,  vlocity_cmt__ParentQuoteId__c,
                (SELECT id,Name,vlocity_cmt__DefaultServicePointId__c,recordType.Name,SWAN_Service_Point_Start_Date__c,SWAN_Service_Point_End_Date__c, vlocity_cmt__ParentQuoteId__c,vlocity_cmt__ParentQuoteId__r.SWAN_Site_Addition_Parent__c FROM vlocity_cmt__Quotes__r where Recordtype.Developername != 'GroupCart') 
                FROM Quote WHERE Status = 'Accepted']);
        System.debug(siteAdditionQuote);
    
    List<Id> QuoteSPList = new List<Id>(); 
    List<Id> parentIdList = new List<Id>();  
    List<Id> cancelledQuoteList = new List<Id>();   
    for(Quote qt:siteAdditionQuote.values())
    {
        if(qt.SWAN_Site_Addition_Parent__c != null)
            parentIdList.add(qt.SWAN_Site_Addition_Parent__c);    
        for(Quote ChildQt:qt.vlocity_cmt__Quotes__r)
        {
            QuoteSPList.add(ChildQt.id);
        }
    }
    
    if(parentIdList.size() > 0)
    {
        for(Contract c:[Select id, vlocity_cmt__QuoteId__c from Contract where vlocity_cmt__QuoteId__c in:parentIdList and (Status = 'Contract Cancelled' or Status = 'Contract Terminated')])
            cancelledQuoteList.add(c.vlocity_cmt__QuoteId__c);
    }
    Map<id,QuoteLineItem> quoteIdToQLI = new Map<id,QuoteLineItem>();
    if(QuoteSPList.size()>0)
    {
        for(QuoteLineItem qli:[Select id, QuoteId, Product2Id, Product2.Name from QuoteLineItem where Product2Id !=null and Product2.ProductCode='BG_GAS' and QuoteId in:QuoteSPList])
        {
            if(!quoteIdToQLI.containskey(qli.QuoteId))
                quoteIdToQLI.put(qli.QuoteId, qli);
        }
    }
    
    quoteWithChildQuote.addAll(siteAdditionQuote.values());
        
        for(Quote q :quoteWithChildQuote){
            for(Quote childQuote : q.vlocity_cmt__Quotes__r){
                servicePointIds.add(childQuote.vlocity_cmt__DefaultServicePointId__c);
            }
        }
    
    Map<Id,DateTime> quoteIdToSignedDate = new Map<Id,DateTime>();
    for(SWAN_Quote_Status_Tracking__c qtStatTrack : [select id,SWAN_Quote__c, createdDate from SWAN_Quote_Status_Tracking__c where New_Status__c ='Accepted' AND SWAN_Quote__c IN :siteAdditionQuote.keyset()])
    {
      quoteIdToSignedDate.put(qtStatTrack.SWAN_Quote__c,qtStatTrack.createdDate);
    } 
    
        
        Map<id,vlocity_cmt__ServicePoint__c> servicePointMap = new Map<id,vlocity_cmt__ServicePoint__c>(
            [SELECT id,Name,SWAN_Supply_Offtake_Quantity__c,SWAN_Exit_Zone__c,SWAN_End_User_Category_Code__c,SWAN_Local_Distribution_Zone__c,vlocity_cmt__ServicePointNumber__c,SWAN_Formula_Year_Annual_Quantity__c,Annual_Quantity__c,SWAN_Product_Class__c,vlocity_cmt__PremisesId__c,SWAN_Formula_Year_Offtake_Quantity__c, SWAN_End_Date__c 
                    FROM vlocity_cmt__ServicePoint__c WHERE id IN :servicePointIds]);
                    
        JSON2Apex jj = new JSON2Apex();
        List<OpportunityLineItem> oli_list = [SELECT id,vlocity_cmt__ServicePointId__c,vlocity_cmt__JSONAttribute__c,vlocity_cmt__JSONNode__c,vlocity_cmt__AttributeSelectedValues__c FROM OpportunityLineItem where SWAN_IsActive__c =true];
        
        List<Quote> quoteQLI =[SELECT id,vlocity_cmt__ParentQuoteId__c FROM Quote WHERE (vlocity_cmt__ParentQuoteId__c IN :quoteIds AND Recordtype.DeveloperName != 'GroupCart') OR ID IN :QuoteSPList];
        system.debug('quoteQLI'+quoteQLI);
        List<QuoteLineItem> qli_list = [SELECT id,Quote.Name,Quote.vlocity_cmt__DefaultServicePointId__c,Product2.Name,vlocity_cmt__JSONAttribute__c FROM QuoteLineItem where QuoteId IN :quoteQLI and Product2.vlocity_cmt__IsOrderable__c =true];
        system.debug('qli_list'+qli_list);
        
        Map<Id,List<JSON2Apex.SWAN_SP_ATT_CAT>> map_sp_Wrapper = new Map<Id,List<JSON2Apex.SWAN_SP_ATT_CAT>>();
        
        for(QuoteLineItem qli : qli_list)
        {
            String json = (String)qli.vlocity_cmt__JSONAttribute__c;
            system.debug('Jsonstring'+json);
            if(String.IsNotBlank(json))
            {       
                jj = JSON2Apex.parse(json);        
                map_sp_Wrapper.put(qli.Quote.vlocity_cmt__DefaultServicePointId__c,jj.SWAN_SP_ATT_CAT);
            }
        }
        system.debug('map_sp_Wrapper'+map_sp_Wrapper);          
        
        
        List<ContractHistory> contractHistoryList = new List<ContractHistory>(
            [SELECT ContractId,CreatedById,CreatedDate,Field,Id,IsDeleted,NewValue,OldValue FROM ContractHistory 
            WHERE ContractId IN :contractIds AND Field = 'Status' ORDER BY CreatedDate DESC]);
            
            
        Map<Id,DateTime> contractIdToSignedDate = new Map<Id,DateTime>();
        
        for(ContractHistory conHist : contractHistoryList){
            if(conHist.NewValue == 'Contract Signed' && !contractIdToSignedDate.containsKey(conHist.ContractId)){
                contractIdToSignedDate.put(conHist.ContractId,conHist.CreatedDate);
            }
        }      
        
        Map<id,List<vlocity_cmt__ContractLineItem__c>> contractIdToCLIsMap = new Map<id,List<vlocity_cmt__ContractLineItem__c>>();
        Map<id,vlocity_cmt__ContractLineItem__c> contractIdToCLI = new Map<id,vlocity_cmt__ContractLineItem__c>();
        
        for(vlocity_cmt__ContractLineItem__c cli:[SELECT Id, vlocity_cmt__Product2Id__r.Name, SWAN_Service_Point__c, vlocity_cmt__EffectiveStartDate__c, 
            vlocity_cmt__ContractId__c, vlocity_cmt__ContractId__r.Status, vlocity_cmt__EffectiveEndDate__c, vlocity_cmt__LineStatus__c, SWAN_Service_Point_End_Date__c, 
            vlocity_cmt__ProductCode__c, vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__c FROM vlocity_cmt__ContractLineItem__c 
            WHERE vlocity_cmt__ContractId__c IN :contractIds])
        {
            if(cli.vlocity_cmt__ProductCode__c == 'BG_GAS' && !contractIdToCLI.containskey(cli.vlocity_cmt__ContractId__c))
            {
                contractIdToCLI.put(cli.vlocity_cmt__ContractId__c, cli);
            }
            else if(cli.SWAN_Service_Point__c != null && cli.vlocity_cmt__ContractId__c != null && cli.vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__c != null)
            {
                if(contractIdToCLIsMap.containsKey(cli.vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__c)) {
                    List<vlocity_cmt__ContractLineItem__c> tempList = contractIdToCLIsMap.get(cli.vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__c);
                    tempList.add(cli);
                    contractIdToCLIsMap.put(cli.vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__c, tempList);
                } else {
                    contractIdToCLIsMap.put(cli.vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__c, new List<vlocity_cmt__ContractLineItem__c> { cli });
                }
            }
        }
        
        
        String nowString = Datetime.now().format('YYYYMMddHHmmss');
        system.debug(nowString);
        String header = 'ISS' + SEP +nowString;
        csv = header+'\r\n';
        
        for(Quote q :quoteWithChildQuote){
            String dateSigned = '';
            Contract contractRec = new Contract();
            
            if(quoteIdToContractMap.containskey(q.id)){
                contractRec = quoteIdToContractMap.get(q.id);
            }
            
            if(contractIdToSignedDate.containskey(contractRec.id)){
                DateTime signedDateTime = contractIdToSignedDate.get(contractRec.id);
                dateSigned = signedDateTime.format('dd/MM/YYYY HH:mm:ss');
            }
            
            // Populate segment for master quotes
            String segment='';
            if(q.vlocity_cmt__PriceListId__c != null)
            {
                if(q.vlocity_cmt__PriceListId__r.Name == label.Swan_Enterprise_Price_List)
                    segment = segmentVal.Enterprise_Segment__c;
                else if(q.vlocity_cmt__PriceListId__r.Name == label.Swan_I_C_Price_List)
                    segment = segmentVal.I_C_Segment__c;
            }
            
            for(Quote childQuote : q.vlocity_cmt__Quotes__r){

                if(q.recordType.Name.containsIgnoreCase('Site Addition')){
                    isRenewal = false;
                    isUpgrade = false;
                    isSiteAddition = true;
                }else if(q.OpportunityId != null && q.Opportunity.RecordType.Name.containsIgnoreCase('Renewal')){
                    isRenewal = true;
                    isUpgrade = false;
                    isSiteAddition = false; 

                }else if(q.OpportunityId != null && q.Opportunity.RecordType.Name.containsIgnoreCase('Upgrade')){
                    isRenewal = false;
                    isUpgrade = true;
                    isSiteAddition = false; 
                }else{
                    isRenewal = false;
                    isUpgrade = false;
                    isSiteAddition = false;
                }

                String meterType = '';
                vlocity_cmt__ServicePoint__c servicePoint = servicePointMap.get(childQuote.vlocity_cmt__DefaultServicePointId__c);
                Integer durationDays = childQuote.SWAN_Service_Point_Start_Date__c.daysBetween(childQuote.SWAN_Service_Point_End_Date__c)+1;
                DateTime startDateTime = childQuote.SWAN_Service_Point_Start_Date__c;
                DateTime endDateTime = childQuote.SWAN_Service_Point_End_Date__c;
                
                
                String startDate = startDateTime.format('YYYYMMdd');
                String endDate = endDateTime.format('YYYYMMdd');
                system.debug(startDate);
                
                if((isRenewal || isUpgrade) && q.SWAN_Service_Point_End_Date__c < System.now().date()){
                    continue;
                }else if(isSiteAddition && servicePoint.SWAN_End_Date__c < System.now().date()){
                    continue;
                }
                
                if((isRenewal || isUpgrade) || (!isRenewal &&  !isUpgrade && !isSiteAddition) || isSiteAddition)
                {
                    if((isRenewal || isUpgrade) || (!isRenewal &&  !isUpgrade && !isSiteAddition))
                    {
                        if(contractIdToCLIsMap.containskey(childQuote.vlocity_cmt__ParentQuoteId__c)){
                            vlocity_cmt__ContractLineItem__c tempCLI;
                            for(vlocity_cmt__ContractLineItem__c cli:contractIdToCLIsMap.get(childQuote.vlocity_cmt__ParentQuoteId__c))
                            {
                                if(cli.SWAN_Service_Point__c == childQuote.vlocity_cmt__DefaultServicePointId__c)
                                {
                                    tempCLI = cli; 
                                    break;
                                }   
                            }
                            if(tempCLI != null)
                            { 
                                if(tempCLI.vlocity_cmt__LineStatus__c == 'Terminated' || tempCLI.vlocity_cmt__LineStatus__c == 'Cancelled')
                                    continue;
                                else
                                {
                                    durationDays = ((tempCLI.vlocity_cmt__EffectiveStartDate__c != null && tempCLI.vlocity_cmt__EffectiveEndDate__c != null)?Date.valueOf(tempCLI.vlocity_cmt__EffectiveStartDate__c).daysBetween(Date.valueof(tempCLI.vlocity_cmt__EffectiveEndDate__c))+1:0);
                                    startDate = (tempCLI.vlocity_cmt__EffectiveStartDate__c != null?tempCLI.vlocity_cmt__EffectiveStartDate__c.format('YYYYMMdd'):'');
                                    endDate = (tempCLI.vlocity_cmt__EffectiveEndDate__c != null?tempCLI.vlocity_cmt__EffectiveEndDate__c.format('YYYYMMdd'):'');
                                }
                            }
                        }
                    }
                    if(isSiteAddition)
                    {
                        if(q.SWAN_Site_Addition_Parent__c != null && contractIdToCLIsMap.containskey(q.SWAN_Site_Addition_Parent__c)){
                            vlocity_cmt__ContractLineItem__c tempCLI;
                            for(vlocity_cmt__ContractLineItem__c cli:contractIdToCLIsMap.get(q.SWAN_Site_Addition_Parent__c))
                            {
                                if(cli.SWAN_Service_Point__c == childQuote.vlocity_cmt__DefaultServicePointId__c)
                                {
                                    tempCLI = cli; 
                                    break;
                                }   
                            }
                            if(tempCLI != null)
                            { 
                                if(tempCLI.vlocity_cmt__LineStatus__c == 'Terminated' || tempCLI.vlocity_cmt__LineStatus__c == 'Cancelled')
                                    continue;
                                else
                                {
                                    durationDays = ((tempCLI.vlocity_cmt__EffectiveStartDate__c != null && tempCLI.vlocity_cmt__EffectiveEndDate__c != null)?Date.valueOf(tempCLI.vlocity_cmt__EffectiveStartDate__c).daysBetween(Date.valueof(tempCLI.vlocity_cmt__EffectiveEndDate__c))+1:0);
                                    startDate = (tempCLI.vlocity_cmt__EffectiveStartDate__c != null?tempCLI.vlocity_cmt__EffectiveStartDate__c.format('YYYYMMdd'):'');
                                    endDate = (tempCLI.vlocity_cmt__EffectiveEndDate__c != null?tempCLI.vlocity_cmt__EffectiveEndDate__c.format('YYYYMMdd'):'');
                                }
                            }
                        }
                        else if(q.SWAN_Site_Addition_Parent__c != null && cancelledQuoteList.size() > 0 && cancelledQuoteList.contains(q.SWAN_Site_Addition_Parent__c))
                            continue;
                    }
                }

                //For a site addition the Execute Time column on the CSV needs to come from the time and date the quote was accepted
                //Initial idea was to retrieve the values from quote history
                //Problem is Field History Tracking is not available on Quote
                //Reference this Salesforce idea: 
                //  https://success.salesforce.com/ideaView?id=0873A000000E7tTQAS 
                if(isSiteAddition ){
                    dateSigned =  quoteIdToSignedDate.get(q.Id).format('dd/MM/YYYY HH:mm:ss');
                    
                    // Populate segment for site addtn quotes
                    if(q.SWAN_Site_Addition_Parent__c != null && q.SWAN_Site_Addition_Parent__r.vlocity_cmt__PriceListId__c != null)
                    {
                        if(q.SWAN_Site_Addition_Parent__r.vlocity_cmt__PriceListId__r.Name == label.Swan_Enterprise_Price_List)
                            segment = segmentVal.Enterprise_Segment__c;
                        else if(q.SWAN_Site_Addition_Parent__r.vlocity_cmt__PriceListId__r.Name == label.Swan_I_C_Price_List)
                            segment = segmentVal.I_C_Segment__c;
                    }
                }

                if(servicePoint.SWAN_Product_Class__c == '1' || servicePoint.SWAN_Product_Class__c == '2'){
                    meterType = 'DM';
                } else if (servicePoint.SWAN_Product_Class__c =='3' || servicePoint.SWAN_Product_Class__c == '4'){
                    meterType = 'NDM';
                }
                String productName ='';

                if(contractIdToCLI.containskey(contractRec.id)){
                    
                    vlocity_cmt__ContractLineItem__c cli=contractIdToCLI.get(contractRec.id);
                    if(cli.vlocity_cmt__Product2Id__c !=  null){
                        productName = contractIdToCLI.get(contractRec.id).vlocity_cmt__Product2Id__r.Name;
                    }  
                    /*
                    if(cli.vlocity_cmt__EffectiveEndDate__c > System.now() && cli.vlocity_cmt__LineStatus__c.containsIgnoreCase('Terminated')){
                        Datetime dtEndDate = cli.vlocity_cmt__EffectiveEndDate__c;
                        endDate = dtEndDate.format('YYYYMMdd');
                    }else if(cli.vlocity_cmt__LineStatus__c.containsIgnoreCase('Cancelled') || cli.vlocity_cmt__EffectiveEndDate__c < System.now()){
                        continue;
                    }  */           
                }
                if(isSiteAddition && quoteIdToQLI.containskey(childQuote.id)){
                    
                    QuoteLineItem qli=quoteIdToQLI.get(childQuote.id);
                    if(qli.Product2Id !=  null){
                        productName = quoteIdToQLI.get(childQuote.id).Product2.Name;
                    } 
                }
                
                if(map_sp_Wrapper.containskey(childQuote.vlocity_cmt__DefaultServicePointId__c))
                {   
                    for(JSON2Apex.SWAN_SP_ATT_CAT qli_attb : map_sp_Wrapper.get(childQuote.vlocity_cmt__DefaultServicePointId__c))
                    {
                        System.debug('childQuote_SWAN_Service_Point__c'+childQuote.vlocity_cmt__DefaultServicePointId__c);
                        System.debug('qli_attb'+qli_attb);
                        if(String.IsNotBlank(String.valueOf(qli_attb)))
                        { 
                            if(qli_attb.attributedisplayname == 'Customer AQ Effective From Date')
                            {
                                    
                                    cust_AQ_fromdate = qli_attb.value;
                                    System.debug('cust_AQ_fromdate'+cust_AQ_fromdate);
                                    if((String.IsNotBlank(cust_AQ_fromdate) && cust_AQ_fromdate != null && cust_AQ_fromdate != 'false' )){
                                        fromdate = Date.valueOf(cust_AQ_fromdate);
                                    }
                                    else 
                                    {
                                        cust_AQ_fromdate = ''; //defaulting date to consider blank value in qli_attb for dates
                                        //fromdate = Date.valueOf(cust_AQ_fromdate);
                                    }
                                    System.debug('fromdate'+fromdate);
                                   
                            }
                                
                            if(qli_attb.attributedisplayname == 'Customer AQ Effective To Date')
                            {
                                
                                    cust_AQ_todate = qli_attb.value;
                                    System.debug('cust_AQ_todate'+cust_AQ_todate);
                                    if(String.IsNotBlank(cust_AQ_todate) && cust_AQ_todate != null && cust_AQ_todate != 'false' ){
                                    todate = Date.valueOf(cust_AQ_todate);
                                    }
                                    else
                                    {
                                        cust_AQ_todate = ''; //defaulting date to consider blank value in qli_attb for dates
                                        //todate = Date.valueOf(cust_AQ_todate);
                                    }
                                    System.debug('todate'+todate);
                                      
                            }
                            
                            if(qli_attb.attributedisplayname == 'Customer AQ')
                            {
                                cust_AQ = qli_attb.value;
                                System.debug('cust_AQ'+cust_AQ);
                            }   
                            
                            if(qli_attb.attributedisplayname == 'Customer SOQ')
                            {
                                cust_SOQ = qli_attb.value;
                                System.debug('cust_SOQ'+cust_SOQ);
                            }   
                            
                            if(
                            (String.IsBlank(cust_AQ_fromdate) && String.IsBlank(cust_AQ_todate)) || 
                            (String.IsNotBlank(cust_AQ_fromdate) && String.IsBlank(cust_AQ_todate) && (isValidDateRangeFromDateNotBlank(fromdate,childQuote.SWAN_Service_Point_End_Date__c)))|| (String.IsNotBlank(cust_AQ_todate) && String.IsBlank(cust_AQ_fromdate) && (isValidDateRangeToDateNotBlank(todate,childQuote.SWAN_Service_Point_Start_Date__c)))|| (String.IsNotBlank(cust_AQ_fromdate) && String.IsNotBlank(cust_AQ_todate) && (isValidDateRangeFromDateNotBlank(fromdate,childQuote.SWAN_Service_Point_End_Date__c)) && (isValidDateRangeToDateNotBlank(todate,childQuote.SWAN_Service_Point_Start_Date__c)))
                            )
                            {
                                if(String.IsNotBlank(cust_AQ) && cust_AQ != 'false'  )
                                {
                                    isCustAQnull = false;
                                }
                                else if(cust_AQ == null || cust_AQ =='')
                                {
                                    isCustAQnull = true;
                                }
                                System.debug('cust_AQ'+ cust_AQ);
                            
                                if(String.IsNotBlank(cust_SOQ)  && cust_SOQ != 'false' )
                                {
                                    isCustSOQnull = false;
                                } 
                                else if(cust_SOQ == null || cust_SOQ =='')
                                {
                                    isCustSOQnull = true;
                                }   
                                System.debug('cust_SOQ'+ cust_SOQ);        
                            }
                        }   
                    }
                }
                   
                
                csv += '"'+q.QuoteNumber + 
                    SEP + NUL + 
                    SEP + servicePoint.vlocity_cmt__PremisesId__c + 
                    SEP + startDate + 
                    SEP + endDate + 
                    SEP + durationDays + 
                    SEP + NUL + 
                    SEP + NUL + 
                    SEP + NUL + 
                    SEP + '0' + 
                    SEP + returnFieldvalueDecimal(servicePoint.SWAN_Formula_Year_Offtake_Quantity__c) ;
                    
                    if(isCustSOQnull){
                        csv+= SEP + returnFieldvalueDecimal(servicePoint.SWAN_Formula_Year_Offtake_Quantity__c);
                    } else {
                        csv+= SEP + cust_SOQ;
                    }
                    
                    csv+= SEP + NUL + 
                    SEP + returnFieldValueString(servicePoint.SWAN_Exit_Zone__c) + 
                    SEP + returnFieldValueString(servicePoint.SWAN_End_User_Category_Code__c) + 
                    SEP + NUL + 
                    SEP + returnFieldvalueDecimal(servicePoint.SWAN_Formula_Year_Annual_Quantity__c) + 
                    SEP + 'Recorded in iPrice' + 
                    SEP + 'FIXED' + 
                    SEP + 'INC' + 
                    SEP + productName + 
                    SEP + returnFieldValueString(servicePoint.SWAN_Local_Distribution_Zone__c) + 
                    SEP + servicePoint.vlocity_cmt__ServicePointNumber__c + 
                    SEP + meterType + 
                    SEP + NUL + 
                    SEP + servicePoint.vlocity_cmt__ServicePointNumber__c + 
                    SEP + NUL + 
                    SEP + NUL + 
                    SEP + NUL + 
                    SEP + 'INC' + 
                    SEP + NUL + 
                    SEP + 'N';
                    
                    if(isRenewal){
                        csv+= SEP + 'RENEWAL';
                    } else if(isSiteAddition){
                        csv+= SEP + 'SITE ADDITION';
                    } else if(isUpgrade){
                        csv+= SEP + 'UPGRADE';
                    } else{
                        csv+= SEP + 'ACQUISITION';
                    }

                    if(isCustAQnull){
                        csv+= SEP +  returnFieldvalueDecimal(servicePoint.SWAN_Formula_Year_Annual_Quantity__c);
                    } else {
                        csv+= SEP + cust_AQ;
                    }
                    
                    csv+= SEP + returnFieldvalueDecimal(servicePoint.SWAN_Formula_Year_Annual_Quantity__c) + 
                    SEP + segment + 
                    SEP + NUL + 
                    SEP + returnFieldvalueDecimal(servicePoint.Annual_Quantity__c) + 
                    SEP + returnFieldValueString(servicePoint.SWAN_Product_Class__c) + 
                    SEP + dateSigned + 
                    SEP + q.Account.Name + '"\r\n';

                recordCount++;
            }
        }

        csv += recordCount;
        
        String fileName = 'BGB_Cust_Data_ISS_'+DateTime.now().format('YYYYMMddHHmmss')+'.csv';
        
        SWAN_Custom_Report__c atlasReport = new SWAN_Custom_Report__c();
        atlasReport.Name = fileName;
        atlasReport.SWAN_Report_Type__c = 'ATLAS';
        if (Schema.sObjectType.SWAN_Custom_Report__c.isCreateable()){
            insert atlasReport; 
        }
        
        
        
        Attachment csvFile = new Attachment(
                Name = fileName,
                ParentId = atlasReport.id,
                Body = Blob.valueOf( csv )
            );
            try{
                if (Schema.sObjectType.Attachment.isCreateable()) 
                {
                    insert csvFile;         
                }
                
            }
            catch(Exception e){
                system.debug(e);
                
            }
        system.debug(csv);
    }
    
    public static String returnFieldvalueDecimal(Decimal fieldvalue){
        if (fieldvalue == null){
            return '';
        } else{
            return String.valueof(fieldvalue);
        }
    }
    
    public static String returnFieldValueString(String fieldvalue){
        if (string.isblank(fieldvalue)){
            return '';
        } else{
            return fieldvalue;
        }
    }
    
    public static Boolean isValidDateRangeFromDateNotBlank(Date d1,Date d2){
        Integer noofdays = d1.daysBetween(d2);
        if(noofdays >= 0)
        {
            return true;
        }
        else return false;
    }
    
    public static Boolean isValidDateRangeToDateNotBlank(Date d1,Date d2){
        Integer noofdays = d1.daysBetween(d2);
        if(noofdays <= 0)
        {
            return true;
        }
        else return false;
    }
    
}