@isTest
public with sharing class SWAN_GetOfferPackRelatedDataTest {

    public static Quote masterQuote = new Quote();
    public static Quote masterQuote1 = new Quote();
    public static Opportunity opp = new Opportunity();
    public static Opportunity oppclose = new Opportunity();
    public static Contact con = new Contact();

    @TestSetup
    static void testSetupMethod(){
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
        p.productCode='BG_UNITRATE';
        p.vlocity_cmt__IsOrderable__c=true;
        insert p;
        
        Product2 pElec = new Product2();
        pElec.name='Fixed Price Electricity';
        pElec.productCode='BG_STD';
        pElec.vlocity_cmt__IsOrderable__c=true;
        insert pElec;

        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = p.Id, UnitPrice = 10000, IsActive = true);
        PricebookEntry standardPriceElec = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = pElec.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        insert standardPriceElec;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = p.Id, UnitPrice = 12000, IsActive = true);
        PricebookEntry customPriceElec = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = pElec.Id, UnitPrice = 12000, IsActive = true);
        insert customPrice;
        insert customPriceElec;
        
        
        List<Quote> masterQuoteList = new List<Quote>();

        Quote masterQuoteElec = new Quote();
        masterQuoteElec.OpportunityId = opp.Id;
        masterQuoteElec.Name = 'Master Quote Elec';
        masterQuoteElec.SWAN_Pricing_Structure__c = 'Site Specific Without Standing Charge';
        masterQuoteElec.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuoteElec.SWAN_Offer_Start_Date__c = Date.today();
        masterQuoteElec.SWAN_Offer_End_Date__c = Date.today().addMonths(12);
        masterQuoteElec.SWAN_Number_of_Service_Points__c = 2;
        masterQuoteElec.SWAN_Broker_Commission_Margin_p__c = 0.50;
        masterQuoteElec.Status = 'Issued';
        masterQuoteElec.recordtypeid = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('MasterQuote').getRecordTypeId();
        masterQuoteElec.pricebook2Id=customPB.id;
        masterQuoteList.add(masterQuoteElec);
        
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
        
        OpportunityLineItem oliElec = new OpportunityLineItem();
        oliElec.opportunityId = opp.id;
        oliElec.PriceBookEntryId=customPrice.id;
        oliElec.Quantity=1;
        oliElec.UnitPrice=10;
        oliElec.vlocity_cmt__ServicePointId__c=servicePoint.id;
     
        olilist.add(oliElec);
        insert olilist;
        
        string JSONATT = '{"SWAN_SP_ATT_CAT":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t8E00000Aj5dRQAR","attributeid__c":"a0L8E000005RGDqUAO","attributecategoryid__c":"a0K8E000007rJX0UAM","categorycode__c":"SWAN_SP_ATT_CAT","categoryname__c":"SWAN Service Point Attributes","attributeuniquecode__c":"SWAN_ATT_CUST_AQ","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":true,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Customer AQ","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0I8E000005ssIHUAY","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"a2D8E000000tLv1UAE","attributeid__c":"a0L8E000005RGDrUAO","attributecategoryid__c":"a0K8E000007rJX0UAM","categorycode__c":"SWAN_SP_ATT_CAT","categoryname__c":"SWAN Service Point Attributes","attributeuniquecode__c":"SWAN_ATT_CUST_EFF_FROM","attributeconfigurable__c":true,"attributedisplaysequence__c":"40","attributefilterable__c":true,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Customer AQ Effective From Date","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0I8E0000061yRKUAY","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedatatype__c":"Datetime","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Datetime","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"a2D8E000000tLv1UAE","attributeid__c":"a0L8E000005RGDsUAO","attributecategoryid__c":"a0K8E000007rJX0UAM","categorycode__c":"SWAN_SP_ATT_CAT","categoryname__c":"SWAN Service Point Attributes","attributeuniquecode__c":"SWAN_ATT_CUST_EFF_TO","attributeconfigurable__c":true,"attributedisplaysequence__c":"50","attributefilterable__c":true,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Customer AQ Effective To Date","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0I8E0000061yRLUAY","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedatatype__c":"Datetime","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Datetime","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"a2D8E000000tLv1UAE","attributeid__c":"a0L8E000005RGDtUAO","attributecategoryid__c":"a0K8E000007rJX0UAM","categorycode__c":"SWAN_SP_ATT_CAT","categoryname__c":"SWAN Service Point Attributes","attributeuniquecode__c":"SWAN_ATT_CUST_EUC","attributeconfigurable__c":true,"attributedisplaysequence__c":"30","attributefilterable__c":true,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Customer EUC","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0I8E0000061yRNUAY","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"a2D8E000000tLv1UAE","attributeid__c":"a0L8E000005RGDuUAO","attributecategoryid__c":"a0K8E000007rJX0UAM","categorycode__c":"SWAN_SP_ATT_CAT","categoryname__c":"SWAN Service Point Attributes","attributeuniquecode__c":"SWAN_ATT_CUST_SOQ","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":true,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Customer SOQ","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0I8E0000061yROUAY","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":null},"$$AttributeDefinitionEnd$$":null}],"SWAN_PR_ATT":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t8E00000Aj5dRQAR","attributeid__c":"a0L8E000005qU9aUAE","attributecategoryid__c":"a0K8E000007sjcVUAQ","categorycode__c":"SWAN_PR_ATT","categoryname__c":"Pricing Attributes","attributeuniquecode__c":"SWAN_ATT_TC_URL","attributeconfigurable__c":true,"attributedisplaysequence__c":"30","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"TC URL","displaysequence__c":"null","categorydisplaysequence__c":20,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0I8E000005ssIGUAY","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t8E00000Aj5dRQAR","attributeid__c":"a0L8E000005qU9QUAU","attributecategoryid__c":"a0K8E000007sjcVUAQ","categorycode__c":"SWAN_PR_ATT","categoryname__c":"Pricing Attributes","attributeuniquecode__c":"SWAN_PR_ATT_TC_DOCUSIGN","attributeconfigurable__c":true,"attributedisplaysequence__c":"3","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"TC DocuSign Tag","displaysequence__c":"null","categorydisplaysequence__c":20,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0I8E000005ssIEUAY","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[],"default":[],"selectedItem":{}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t8E00000Aj5dRQAR","attributeid__c":"a0L8E000005qU9VUAU","attributecategoryid__c":"a0K8E000007sjcVUAQ","categorycode__c":"SWAN_PR_ATT","categoryname__c":"Pricing Attributes","attributeuniquecode__c":"SWAN_PR_ATT_TC_REFERENCE","attributeconfigurable__c":true,"attributedisplaysequence__c":"2","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"TC Reference","displaysequence__c":"null","categorydisplaysequence__c":20,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0I8E000005ssIFUAY","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[],"default":[],"selectedItem":{}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t8E00000Aj5dRQAR","attributeid__c":"a0L8E000005k7o2UAA","attributecategoryid__c":"a0K8E000007sjcVUAQ","categorycode__c":"SWAN_PR_ATT","categoryname__c":"Pricing Attributes","attributeuniquecode__c":"SWAN_PR_ATT_PRICE_CURVE","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Price Curve","displaysequence__c":"20","categorydisplaysequence__c":20,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":true,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0I8E000005ssIDUAY","isrequired__c":true,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Daily/Bespoke","valuedatatype__c":"Picklist","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"displayText":"Daily/Bespoke","id":"c086af65-af35-944c-2c56-78222aa93031","sequence":10,"value":"Daily/Bespoke"}],"values":[{"displayText":"Daily/Bespoke","id":"c086af65-af35-944c-2c56-78222aa93031","sequence":10,"value":"Daily/Bespoke"},{"displayText":"Weekly","id":"614a5231-6a23-6c43-9b81-f1c00bfeca83","sequence":20,"value":"Weekly"}],"selectedItem":{"displayText":"Daily/Bespoke","id":"c086af65-af35-944c-2c56-78222aa93031","sequence":10,"value":"Daily/Bespoke"}},"$$AttributeDefinitionEnd$$":null}]}';

        List<quote> childqList=new List<quote>();

        Quote childQuoteElec = new Quote();
        childQuoteElec.pricebook2Id=customPB.id;
        childQuoteElec.vlocity_cmt__ParentQuoteId__c = masterQuoteElec.id;
        childQuoteElec.vlocity_cmt__DefaultServicePointId__c = servicePoint.id;
        childQuoteElec.SWAN_Service_Point_Start_Date__c = date.today();
        childQuoteElec.name = 'child quote';
        childQuoteElec.OpportunityId = opp.id;
        childQuoteElec.SWAN_Broker_Commission__c = 10;
        childQuoteElec.pricebook2Id=customPB.id;
        childQuoteElec.recordtypeid = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('SWAN_Service_Point_Quote').getRecordTypeId();
        childqList.add(childQuoteElec);
        
        insert childqList;
        

        List<QuoteLineItem>qlilist= new List<QuoteLineItem>();
        
        QuoteLineItem qliElec = new QuoteLineItem();
        qliElec.QuoteId = childQuoteElec.id;
        qliElec.PriceBookEntryId=customPriceElec.id;
        qliElec.Quantity=1;
        qliElec.UnitPrice=10;

        qlilist.add(qliElec);
        insert qlilist;
        
        List<SWAN_Offer_Pack__c>offerpacks=new List<SWAN_Offer_Pack__c>();    
        SWAN_Offer_Pack__c offerPack = new SWAN_Offer_Pack__c();
        offerPack.Contact__c = con.id;
        offerPack.Name = 'HappyPath';
        offerPack.SWAN_Opportunity__c = opp.id;
        offerpacks.add(offerPack);
                
        insert offerpacks;
        
        oppclose.StageName = 'Closed Won';
        update oppclose;
        
        List<SWAN_Offer_Pack_Quote__c> listOfferPackQuote = new List<SWAN_Offer_Pack_Quote__c>();

        SWAN_Offer_Pack_Quote__c opqElec = new SWAN_Offer_Pack_Quote__c();
        opqElec.SWAN_Offer_Pack__c = offerPack.id;
        opqElec.SWAN_Quote__c = masterQuoteElec.id;
        listOfferPackQuote.add(opqElec);
        
        insert listOfferPackQuote;
        
        offerPack.SWAN_IsNotAmendable__c=true;
        update offerPack;

        masterQuoteElec.Status = 'Selected';
        update masterQuoteElec;
    }

    @isTest
    static void testMethod1(){
        Test.startTest();
        
        SWAN_GetOfferPackRelatedData obj = new SWAN_GetOfferPackRelatedData();
        obj.invokeMethod('getTokenData',new Map<String, Object>{'contextId'=>[select id from SWAN_Offer_Pack__c where name='HappyPath' limit 1].id},new Map<String, Object>(),new Map<String, Object>());
        
        Test.stopTest();
    }

}