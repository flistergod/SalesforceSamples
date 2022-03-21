@isTest
public class QUOTE_ANNEX_Test {
    public static Quote masterQuote = new Quote();
    public static Quote masterQuote1 = new Quote();
    public static Opportunity opp = new Opportunity();
    public static Opportunity oppclose = new Opportunity();
    public static Contact con = new Contact();
  
    public static void createStaticDataWithOfferPack()
    {   
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.SWAN_Customer_Segment__c = 'I&C';
        acc.SWAN_Micro_Business_Selection__c = 'Non_Micro_Business';
        insert acc;
        
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.CloseDate = date.today();
        insert opp;
        
        oppclose.AccountId = acc.Id;
        oppclose.Name = 'Test Opp';
        oppclose.StageName = 'Prospecting';
        oppclose.CloseDate = date.today();
        insert oppclose;
        
        /*        //Account m = new Account(Name = 'AsyncTest1',recordtypeid=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId());
        //insert m;
        List<vlocity_cmt__Premises__c>pList=new List<vlocity_cmt__Premises__c>();
        vlocity_cmt__Premises__c p1= new vlocity_cmt__Premises__c(name='Prem 57374905',vlocity_cmt__PremisesType__c='Commercial Building',vlocity_cmt__PremisesIdentifier__c='6019556730',vlocity_cmt__PremisesNumber__c='57374905');
        pList.add(p1);
        vlocity_cmt__Premises__c p2= new vlocity_cmt__Premises__c(name='Prem 57374906',vlocity_cmt__PremisesType__c='Commercial Building',vlocity_cmt__PremisesIdentifier__c='6019556731',vlocity_cmt__PremisesNumber__c='57374906');
        pList.add(p2);
        insert(pList);                
        List<vlocity_cmt__ServicePoint__c>SPList=new List<vlocity_cmt__ServicePoint__c>();
        vlocity_cmt__ServicePoint__c sp1=new vlocity_cmt__ServicePoint__c(SWAN_Corrector__c=true,SWAN_Data_Logger__c='Unknown',vlocity_cmt__ServicePointNumber__c='99994905',name='SP_57374905',vlocity_cmt__ActivationDate__c=date.today(),multisite_sync_due__c=true,vlocity_cmt__ServiceType__c='Gas',vlocity_cmt__PremisesId__c=p1.id);
        SPList.add(sp1);
        vlocity_cmt__ServicePoint__c sp2=new vlocity_cmt__ServicePoint__c(SWAN_Corrector__c=true,SWAN_Data_Logger__c='Unknown',vlocity_cmt__ServicePointNumber__c='99994906',name='SP_57374906',vlocity_cmt__ActivationDate__c=date.today(),multisite_sync_due__c=true,vlocity_cmt__ServiceType__c='Gas',vlocity_cmt__PremisesId__c=p2.id);
        SPList.add(sp2);
        insert(SPList);*/
        
        con.AccountId = acc.Id;
        con.lastName = 'Last Name';
        con.firstname ='Fname';
        con.MailingStreet='M street';
        con.MailingPostalCode='M50 2HX';
        con.SWAN_Mailing_Building_Name__c='Building name';
        con.MailingCity = 'test City';
        insert con;
                
        Product2 p = new Product2();
        p.name='Fixed Price Gas';
        p.productCode='BG_GAS';
        p.vlocity_cmt__IsOrderable__c=true;
        insert p;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = p.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = p.Id, UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
        
        List<Quote> masterQuoteList = new List<Quote>();
        
        //Quote masterQuote = new Quote();
        masterQuote1.OpportunityId = opp.Id;
        masterQuote1.Name = 'Master Quote 1';
        masterQuote1.SWAN_Pricing_Structure__c = 'Site Specific With Standing Charge';
        masterQuote1.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote1.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote1.SWAN_Offer_End_Date__c = date.today()+1000;
        masterQuote1.SWAN_Number_of_Service_Points__c = 2;
        masterQuote1.Status = 'Draft';
        masterQuote1.pricebook2Id=customPB.id;
        masterQuote1.recordtypeid=Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('MasterQuote').getRecordTypeId();
        masterQuote1.SWAN_Contract_Spend__c=100;
        masterQuote1.SWAN_Annual_Spend__c=10;
        masterQuote1.SWAN_Quote_Type__c = 'Fixed';
        masterQuoteList.add(masterQuote1);
        
        Quote masterQuote2 = new Quote();
        masterQuote2.OpportunityId = opp.Id;
        masterQuote2.Name = 'Master Quote 2';
        masterQuote2.SWAN_Pricing_Structure__c = 'Site Specific Without Standing Charge';
        masterQuote2.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote2.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote2.SWAN_Number_of_Service_Points__c = 2;
        masterQuote2.Status = 'Draft';
        masterQuote2.pricebook2Id=customPB.id;
        masterQuote2.recordtypeid=Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('MasterQuote').getRecordTypeId();
        masterQuote2.SWAN_Quote_Type__c = 'Fixed';
        masterQuoteList.add(masterQuote2);
        
        Quote masterQuote3 = new Quote();
        masterQuote3.OpportunityId = opp.Id;
        masterQuote3.Name = 'Master Quote 2';
        masterQuote3.SWAN_Pricing_Structure__c = 'Site Specific Without Standing Charge';
        masterQuote3.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote3.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote3.SWAN_Number_of_Service_Points__c = 2;
        masterQuote3.Status = 'Issued';
        masterQuote3.recordtypeid = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Site_Addition_Quote').getRecordTypeId();
        masterQuote3.pricebook2Id=customPB.id;
        masterQuote3.SWAN_Quote_Type__c = 'Fixed';
        masterQuoteList.add(masterQuote3);
        
        insert masterQuoteList;
    
        vlocity_cmt__Premises__c premise = new vlocity_cmt__Premises__c();
        insert premise;
        
        vlocity_cmt__ServicePoint__c servicePoint = new vlocity_cmt__ServicePoint__c();
        servicePoint.SWAN_Formula_Year_Annual_Quantity__c = 12331;
        servicePoint.SWAN_Formula_Year_Offtake_Quantity__c = 3321;
        servicePoint.vlocity_cmt__ServicePointNumber__c = '1231231231';
        servicePoint.vlocity_cmt__PremisesId__c = premise.id;
        servicePoint.SWAN_Product_Class__c = '3';
        insert servicePoint;
        
        List<OpportunityLineItem>olilist= new List<OpportunityLineItem>();       
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.opportunityId = opp.id;
        oli.PriceBookEntryId=customPrice.id;
        oli.Quantity=1;
        oli.UnitPrice=10;
        oli.vlocity_cmt__ServicePointId__c=servicePoint.id;
        olilist.add(oli);      
        insert olilist;
        
        string JSONATT = '{"SWAN_SP_ATT_CAT":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t8E00000Aj5dRQAR","attributeid__c":"a0L8E000005RGDqUAO","attributecategoryid__c":"a0K8E000007rJX0UAM","categorycode__c":"SWAN_SP_ATT_CAT","categoryname__c":"SWAN Service Point Attributes","attributeuniquecode__c":"SWAN_ATT_CUST_AQ","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":true,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Customer AQ","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0I8E000005ssIHUAY","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"a2D8E000000tLv1UAE","attributeid__c":"a0L8E000005RGDrUAO","attributecategoryid__c":"a0K8E000007rJX0UAM","categorycode__c":"SWAN_SP_ATT_CAT","categoryname__c":"SWAN Service Point Attributes","attributeuniquecode__c":"SWAN_ATT_CUST_EFF_FROM","attributeconfigurable__c":true,"attributedisplaysequence__c":"40","attributefilterable__c":true,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Customer AQ Effective From Date","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0I8E0000061yRKUAY","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedatatype__c":"Datetime","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Datetime","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"a2D8E000000tLv1UAE","attributeid__c":"a0L8E000005RGDsUAO","attributecategoryid__c":"a0K8E000007rJX0UAM","categorycode__c":"SWAN_SP_ATT_CAT","categoryname__c":"SWAN Service Point Attributes","attributeuniquecode__c":"SWAN_ATT_CUST_EFF_TO","attributeconfigurable__c":true,"attributedisplaysequence__c":"50","attributefilterable__c":true,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Customer AQ Effective To Date","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0I8E0000061yRLUAY","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedatatype__c":"Datetime","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Datetime","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"a2D8E000000tLv1UAE","attributeid__c":"a0L8E000005RGDtUAO","attributecategoryid__c":"a0K8E000007rJX0UAM","categorycode__c":"SWAN_SP_ATT_CAT","categoryname__c":"SWAN Service Point Attributes","attributeuniquecode__c":"SWAN_ATT_CUST_EUC","attributeconfigurable__c":true,"attributedisplaysequence__c":"30","attributefilterable__c":true,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Customer EUC","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0I8E0000061yRNUAY","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"a2D8E000000tLv1UAE","attributeid__c":"a0L8E000005RGDuUAO","attributecategoryid__c":"a0K8E000007rJX0UAM","categorycode__c":"SWAN_SP_ATT_CAT","categoryname__c":"SWAN Service Point Attributes","attributeuniquecode__c":"SWAN_ATT_CUST_SOQ","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":true,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Customer SOQ","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0I8E0000061yROUAY","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":null},"$$AttributeDefinitionEnd$$":null}],"SWAN_PR_ATT":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t8E00000Aj5dRQAR","attributeid__c":"a0L8E000005qU9aUAE","attributecategoryid__c":"a0K8E000007sjcVUAQ","categorycode__c":"SWAN_PR_ATT","categoryname__c":"Pricing Attributes","attributeuniquecode__c":"SWAN_ATT_TC_URL","attributeconfigurable__c":true,"attributedisplaysequence__c":"30","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"TC URL","displaysequence__c":"null","categorydisplaysequence__c":20,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0I8E000005ssIGUAY","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t8E00000Aj5dRQAR","attributeid__c":"a0L8E000005qU9QUAU","attributecategoryid__c":"a0K8E000007sjcVUAQ","categorycode__c":"SWAN_PR_ATT","categoryname__c":"Pricing Attributes","attributeuniquecode__c":"SWAN_PR_ATT_TC_DOCUSIGN","attributeconfigurable__c":true,"attributedisplaysequence__c":"3","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"TC DocuSign Tag","displaysequence__c":"null","categorydisplaysequence__c":20,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0I8E000005ssIEUAY","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[],"default":[],"selectedItem":{}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t8E00000Aj5dRQAR","attributeid__c":"a0L8E000005qU9VUAU","attributecategoryid__c":"a0K8E000007sjcVUAQ","categorycode__c":"SWAN_PR_ATT","categoryname__c":"Pricing Attributes","attributeuniquecode__c":"SWAN_PR_ATT_TC_REFERENCE","attributeconfigurable__c":true,"attributedisplaysequence__c":"2","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"TC Reference","displaysequence__c":"null","categorydisplaysequence__c":20,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0I8E000005ssIFUAY","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[],"default":[],"selectedItem":{}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t8E00000Aj5dRQAR","attributeid__c":"a0L8E000005k7o2UAA","attributecategoryid__c":"a0K8E000007sjcVUAQ","categorycode__c":"SWAN_PR_ATT","categoryname__c":"Pricing Attributes","attributeuniquecode__c":"SWAN_PR_ATT_PRICE_CURVE","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Price Curve","displaysequence__c":"20","categorydisplaysequence__c":20,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":true,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0I8E000005ssIDUAY","isrequired__c":true,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Daily/Bespoke","valuedatatype__c":"Picklist","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"displayText":"Daily/Bespoke","id":"c086af65-af35-944c-2c56-78222aa93031","sequence":10,"value":"Daily/Bespoke"}],"values":[{"displayText":"Daily/Bespoke","id":"c086af65-af35-944c-2c56-78222aa93031","sequence":10,"value":"Daily/Bespoke"},{"displayText":"Weekly","id":"614a5231-6a23-6c43-9b81-f1c00bfeca83","sequence":20,"value":"Weekly"}],"selectedItem":{"displayText":"Daily/Bespoke","id":"c086af65-af35-944c-2c56-78222aa93031","sequence":10,"value":"Daily/Bespoke"}},"$$AttributeDefinitionEnd$$":null}]}';

        List<quote>childqList=new List<quote>();
        Quote childQuote = new Quote();
        childQuote.vlocity_cmt__ParentQuoteId__c = masterQuote1.id;
        childQuote.vlocity_cmt__DefaultServicePointId__c = servicePoint.id;
        childQuote.SWAN_Service_Point_Start_Date__c = date.today();
        childQuote.name = 'child quote';
        childQuote.OpportunityId = opp.id;
        childQuote.SWAN_Broker_Commission__c = 10;
        childQuote.pricebook2Id=customPB.id;
        childqList.add(childQuote);
        Quote childQuote1 = new Quote();
        childQuote1.vlocity_cmt__ParentQuoteId__c = masterQuote1.id;
        childQuote1.vlocity_cmt__DefaultServicePointId__c = servicePoint.id;
        childQuote1.SWAN_Service_Point_Start_Date__c = date.today();
        childQuote1.name = 'child quote';
        childQuote1.OpportunityId = opp.id;
        childQuote1.SWAN_Broker_Commission__c = 10;
        childQuote1.pricebook2Id=customPB.id;
        childqList.add(childQuote1);
        Quote childQuote2 = new Quote();
        childQuote2.pricebook2Id=customPB.id;
        childQuote2.vlocity_cmt__ParentQuoteId__c = masterQuote3.id;
        childQuote2.vlocity_cmt__DefaultServicePointId__c = servicePoint.id;
        childQuote2.SWAN_Service_Point_Start_Date__c = date.today();
        childQuote2.name = 'child quote';
        childQuote2.OpportunityId = opp.id;
        childQuote2.SWAN_Broker_Commission__c = 10;
        childQuote2.pricebook2Id=customPB.id;
        childQuote2.recordtypeid = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('SWAN_Service_Point_Quote').getRecordTypeId();
        childqList.add(childQuote2);
        
        insert childqList;
        
        List<QuoteLineItem>qlilist= new List<QuoteLineItem>();
        
        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = childQuote.id;
        qli.PriceBookEntryId=customPrice.id;
        qli.Quantity=1;
        qli.UnitPrice=10;
        qli.vlocity_cmt__JSONAttribute__c=JSONATT;
        qlilist.add(qli);
        
        QuoteLineItem qli1 = new QuoteLineItem();
        qli1.QuoteId = childQuote1.id;
        qli1.PriceBookEntryId=customPrice.id;
        qli1.Quantity=1;
        qli1.UnitPrice=10;
        qlilist.add(qli1);
        
        QuoteLineItem qli2 = new QuoteLineItem();
        qli2.QuoteId = masterQuote1.id;
        qli2.PriceBookEntryId=customPrice.id;
        qli2.Quantity=1;
        qli2.UnitPrice=10;
        qlilist.add(qli2);
        
        QuoteLineItem qli3 = new QuoteLineItem();
        qli3.QuoteId = masterQuote2.id;
        qli3.PriceBookEntryId=customPrice.id;
        qli3.Quantity=1;
        qli3.UnitPrice=10;
        qlilist.add(qli3);
        
        QuoteLineItem qli4 = new QuoteLineItem();
        qli4.QuoteId = masterQuote3.id;
        qli4.PriceBookEntryId=customPrice.id;
        qli4.Quantity=1;
        qli4.UnitPrice=10;
        qlilist.add(qli4);
        
        QuoteLineItem qli5 = new QuoteLineItem();
        qli5.QuoteId = childQuote2.id;
        qli5.PriceBookEntryId=customPrice.id;
        qli5.Quantity=1;
        qli5.UnitPrice=10;
        qlilist.add(qli5);
        
        insert qlilist;
        
        List<SWAN_Offer_Pack__c>offerpacks=new List<SWAN_Offer_Pack__c>();    
        SWAN_Offer_Pack__c offerPack = new SWAN_Offer_Pack__c();
        offerPack.Contact__c = con.id;
        offerPack.Name = 'HappyPath';
        offerPack.SWAN_Opportunity__c = opp.id;
        offerpacks.add(offerPack);
        
        SWAN_Offer_Pack__c offerPack1 = new SWAN_Offer_Pack__c();
        offerPack1.Name = 'SadPath1';
        offerPack1.SWAN_Opportunity__c = opp.id;
        offerpacks.add(offerPack1);
        
        SWAN_Offer_Pack__c offerPack2 = new SWAN_Offer_Pack__c();
        offerPack2.Name = 'SadPath2';
        offerPack2.SWAN_Opportunity__c=oppclose.id;//[select id from opportunity where stagename='Closed Won' limit 1].id;
        offerpacks.add(offerPack2);
        
        insert offerpacks;
        
        oppclose.StageName = 'Closed Won';
        update oppclose;
        
        List<SWAN_Offer_Pack_Quote__c> listOfferPackQuote = new List<SWAN_Offer_Pack_Quote__c>();
        SWAN_Offer_Pack_Quote__c opq1 = new SWAN_Offer_Pack_Quote__c();
        opq1.SWAN_Offer_Pack__c = offerPack.id;
        opq1.SWAN_Quote__c = masterQuote1.id;
        listOfferPackQuote.add(opq1);
        
        SWAN_Offer_Pack_Quote__c opq2 = new SWAN_Offer_Pack_Quote__c();
        opq2.SWAN_Offer_Pack__c = offerPack.id;
        opq2.SWAN_Quote__c = masterQuote2.id;
        listOfferPackQuote.add(opq2);
        
        insert listOfferPackQuote;
        
        offerPack.SWAN_IsNotAmendable__c=true;
        update offerPack;
    
        system.debug('~~~~~'+masterQuote1.Status);
        masterQuote1.Status = 'Selected';
        update masterQuote1;
        system.debug('~~~~~'+masterQuote1.Status);        
        
    }
    
    @isTest
    public static void childQuoteInsertTest(){
        createStaticDataWithOfferPack();
        QUOTE_ANNEX.insertAttachment([SELECT id from SWAN_Offer_Pack__c where name='HappyPath' limit 1].id);
        QUOTE_ANNEX.insertAttachment([SELECT id from SWAN_Offer_Pack__c where name='SadPath1' limit 1].id);
        QUOTE_ANNEX.insertAttachment([SELECT id from SWAN_Offer_Pack__c where name='SadPath2' limit 1].id);
        QUOTE_ANNEX.insertAttachment([SELECT id from quote where recordtype.developername='Site_Addition_Quote' limit 1].id);
        
        // ************* SWAN_GetOfferPackRelatedData Test coverage *****************
        SWAN_getOfferPackRelatedData obj = new SWAN_getOfferPackRelatedData();
        obj.invokeMethod('getTokenData',new Map<String, Object>{'contextId'=>[select id from SWAN_Offer_Pack__c where name='HappyPath' limit 1].id},new Map<String, Object>(),new Map<String, Object>());

    }
    
}