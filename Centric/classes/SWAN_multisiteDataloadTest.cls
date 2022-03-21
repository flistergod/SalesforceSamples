@isTest
private class SWAN_multisiteDataloadTest {
    
    /*
    @testSetup static void methodName() {

    }
    */
    @isTest(SeeAllData=true)
    static void test() {
        Account m = new Account(Name = 'AsyncTest1',SWAN_Customer_Segment__c = 'I&C', SWAN_Micro_Business_Selection__c = 'Non_Micro_Business',recordtypeid=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId());
        insert m;
        
        Map<string,object>AHmap=new Map<string,object>();
        Map<string,object>SLmap=new Map<string,object>();
        List<Map<string,object>>listMap=new list<Map<string,object>>();
        Map<string,object>DataMap1=new map<string,object>();
        
        DataMap1.put('ServicePointId','57374905');
        DataMap1.put('Datalogger','Unknown');
        DataMap1.put('Corrector','Asda');
        listMap.add(DataMap1);
        Map<string,object>DataMap2=new map<string,object>();
      
        DataMap2.put('ServicePointId', '57374906' );
        DataMap2.put('Datalogger','Unknown');
        DataMap2.put('Corrector','Asda');
        listMap.add(DataMap2);
        SLmap.put('ServiceLocations',listMap);
        SLmap.put('ParentAccountName',m.name);
        SLmap.put('ParentAccountId',m.id);
        AHmap.put('AccountHierarchy',SLmap);
        AHmap.put('ParentAccount',new map<string,object>{'ServiceRecordTypeID'=>Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service').getRecordTypeId()});
        system.debug('==>'+JSON.serialize(AHmap));
        
        Test.startTest();
        SWAN_multisiteDataload remoteclass = new SWAN_multisiteDataload();
        remoteclass.invokeMethod('load',AHmap,new Map<String, Object>(), new Map<String, Object>());
        /*
        String recIdElec = Schema.SObjectType.vlocity_cmt__ServicePoint__c.getRecordTypeInfosByDeveloperName().get('SWAN_Electricity_Service_point').getRecordTypeId();
        DataMap1.put('SPrecordtype',recIdElec);
        DataMap2.put('SPrecordtype',recIdElec);
        remoteclass.invokeMethod('load_ELEC',AHmap,new Map<String, Object>(), new Map<String, Object>());
        remoteclass.invokeMethod('load_Nothing',new Map<String, Object>(),new Map<String, Object>(), new Map<String, Object>());*/
        //break something to fall on Exeption
        remoteclass.invokeMethod('load',new Map<String, Object>(),new Map<String, Object>(), new Map<String, Object>());
        remoteclass.invokeMethod('load_ELEC',new Map<String, Object>(),new Map<String, Object>(), new Map<String, Object>());
        //
        Test.stopTest(); 
    }
    
    static testmethod void testcallVIP() {
        Account m = new Account(Name = 'AsyncTest1',SWAN_Customer_Segment__c = 'I&C', SWAN_Micro_Business_Selection__c = 'Non_Micro_Business',recordtypeid=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId());
        insert m;
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
        insert(SPList);
        set<id>SPids=new set<id>{sp1.id,sp2.id};
        
        Test.startTest();
        Database.executeBatch(new callVIP (SPids,UserInfo.getUserId(),m.name,m.id), 45);  
        Test.stopTest();   
    }
    
    static testmethod void testload_ELEC() {
        Account m = new Account(Name = 'AsyncTest1',SWAN_Customer_Segment__c = 'I&C', SWAN_Micro_Business_Selection__c = 'Non_Micro_Business',recordtypeid=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId());
        insert m;
        
        Map<string,object>AHmap=new Map<string,object>();
        Map<string,object>SLmap=new Map<string,object>();
        List<Map<string,object>>listMap=new list<Map<string,object>>();
        Map<string,object>DataMap1=new map<string,object>();
        
        DataMap1.put('ServicePointId','57374905');
        DataMap1.put('Datalogger','Unknown');
        DataMap1.put('Corrector','Asda');
        listMap.add(DataMap1);
        Map<string,object>DataMap2=new map<string,object>();
      
        DataMap2.put('ServicePointId', '57374906' );
        DataMap2.put('Datalogger','Unknown');
        DataMap2.put('Corrector','Asda');
        listMap.add(DataMap2);
        SLmap.put('ServiceLocations',listMap);
        SLmap.put('ParentAccountName',m.name);
        SLmap.put('ParentAccountId',m.id);
        AHmap.put('AccountHierarchy',SLmap);
        AHmap.put('ParentAccount',new map<string,object>{'ServiceRecordTypeID'=>Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service').getRecordTypeId()});
        system.debug('==>'+JSON.serialize(AHmap));
        
        Test.startTest();
        SWAN_multisiteDataload remoteclass = new SWAN_multisiteDataload();
        //remoteclass.invokeMethod('load',AHmap,new Map<String, Object>(), new Map<String, Object>());
        
        String recIdElec = Schema.SObjectType.vlocity_cmt__ServicePoint__c.getRecordTypeInfosByDeveloperName().get('SWAN_Electricity_Service_point').getRecordTypeId();
        DataMap1.put('SPrecordtype',recIdElec);
        DataMap2.put('SPrecordtype',recIdElec);
        remoteclass.invokeMethod('load_ELEC',AHmap,new Map<String, Object>(), new Map<String, Object>());
        Test.stopTest();   
    }
    
    static testmethod void testcallVIP_ELEC() {
        Account m = new Account(Name = 'AsyncTest1',SWAN_Customer_Segment__c = 'I&C', SWAN_Micro_Business_Selection__c = 'Non_Micro_Business',recordtypeid=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId());
        insert m;
        List<vlocity_cmt__Premises__c>pList=new List<vlocity_cmt__Premises__c>();
        vlocity_cmt__Premises__c p1= new vlocity_cmt__Premises__c(name='Prem 57374905',vlocity_cmt__PremisesType__c='Commercial Building',vlocity_cmt__PremisesIdentifier__c='6019556730',vlocity_cmt__PremisesNumber__c='57374905');
        pList.add(p1);
        //vlocity_cmt__Premises__c p2= new vlocity_cmt__Premises__c(name='Prem 57374906',vlocity_cmt__PremisesType__c='Commercial Building',vlocity_cmt__PremisesIdentifier__c='6019556731',vlocity_cmt__PremisesNumber__c='57374906');
        //pList.add(p2);
        insert(pList);                
        List<vlocity_cmt__ServicePoint__c>SPList=new List<vlocity_cmt__ServicePoint__c>();
        vlocity_cmt__ServicePoint__c sp1=new vlocity_cmt__ServicePoint__c(SWAN_Corrector__c=true,SWAN_Data_Logger__c='Unknown',vlocity_cmt__ServicePointNumber__c='99994905',name='SP_57374905',vlocity_cmt__ActivationDate__c=date.today(),multisite_sync_due__c=true,vlocity_cmt__ServiceType__c='Electricity',vlocity_cmt__PremisesId__c=p1.id);
        SPList.add(sp1);
        //vlocity_cmt__ServicePoint__c sp2=new vlocity_cmt__ServicePoint__c(SWAN_Corrector__c=true,SWAN_Data_Logger__c='Unknown',vlocity_cmt__ServicePointNumber__c='99994906',name='SP_57374906',vlocity_cmt__ActivationDate__c=date.today(),multisite_sync_due__c=true,vlocity_cmt__ServiceType__c='Electricity',vlocity_cmt__PremisesId__c=p2.id);
        //SPList.add(sp2);
        insert(SPList);
        //set<id>SPids=new set<id>{sp1.id,sp2.id};
        set<id>SPids=new set<id>{sp1.id};
        
        Test.startTest();
        Database.executeBatch(new callVIP_ELEC(SPids,UserInfo.getUserId(),m.name,m.id), 1);  
        Test.stopTest();   
    }


    static testmethod void testelEctricRefresh() {
        Account m = new Account(Name = 'AsyncTest1',SWAN_Customer_Segment__c = 'I&C', SWAN_Micro_Business_Selection__c = 'Non_Micro_Business',recordtypeid=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId());
        insert m;
        List<vlocity_cmt__Premises__c>pList=new List<vlocity_cmt__Premises__c>();
        vlocity_cmt__Premises__c p1= new vlocity_cmt__Premises__c(name='Prem 57374905',vlocity_cmt__PremisesType__c='Commercial Building',vlocity_cmt__PremisesIdentifier__c='6019556730',vlocity_cmt__PremisesNumber__c='57374905');
        pList.add(p1);
        insert(pList);                
        List<vlocity_cmt__ServicePoint__c>SPList=new List<vlocity_cmt__ServicePoint__c>();
        vlocity_cmt__ServicePoint__c sp1=new vlocity_cmt__ServicePoint__c(SWAN_Corrector__c=true,SWAN_Data_Logger__c='Unknown',vlocity_cmt__ServicePointNumber__c='99994905',name='SP_57374905',vlocity_cmt__ActivationDate__c=date.today(),multisite_sync_due__c=true,vlocity_cmt__ServiceType__c='Electricity',vlocity_cmt__PremisesId__c=p1.id);
        vlocity_cmt__ServicePoint__c sp2=new vlocity_cmt__ServicePoint__c(SWAN_Corrector__c=true,SWAN_Data_Logger__c='Unknown',vlocity_cmt__ServicePointNumber__c='99994904',name='SP_57374904',vlocity_cmt__ActivationDate__c=date.today(),multisite_sync_due__c=true,vlocity_cmt__ServiceType__c='Electricity',vlocity_cmt__PremisesId__c=p1.id);
        SPList.add(sp1);
        SPList.add(sp2);
        insert(SPList);

        String UserId=UserInfo.getUserId();
        Map<String, Object> inputMap= new Map<String, Object>();
        Map<String, Object> outputMap=new Map<String, Object>();
        Map<String, Object> options=new Map<String, Object>();

        List<Id> spIds_Elec= new List<Id>{sp1.Id, sp2.Id};
        List<Id> spIds_Gas= new List<Id>();
        Map<String, Object> spIds= new Map<String, Object>();
        spIds.put('spIds_Elec',spIds_Elec);
        spIds.put('spIds_Gas',spIds_Gas);
        inputMap.put('spIds',spIds);

        Map<String, Object> AccountDetails= new Map<String, Object>();
        AccountDetails.put('AccountName',m.Name);
        AccountDetails.put('AccountId',m.Id);
        Map<String, Object> ParentAccount= new Map<String, Object>();
        ParentAccount.put('AccountDetails',AccountDetails);
        inputMap.put('ParentAccount',ParentAccount);
        String methodName='electricityIndustryDataLoad';
            
        Test.startTest();
        SWAN_multisiteDataload multisiteDataload = new SWAN_multisiteDataload();
        multisiteDataload.invokeMethod(methodName,inputMap, outputMap, options);
        Test.stopTest();   
    }
    
    
    static testmethod void testGasRefresh() {
        Account m = new Account(Name = 'AsyncTest1',SWAN_Customer_Segment__c = 'I&C', SWAN_Micro_Business_Selection__c = 'Non_Micro_Business',recordtypeid=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId());
        insert m;
        List<vlocity_cmt__Premises__c>pList=new List<vlocity_cmt__Premises__c>();
        vlocity_cmt__Premises__c p1= new vlocity_cmt__Premises__c(name='Prem 57374905',vlocity_cmt__PremisesType__c='Commercial Building',vlocity_cmt__PremisesIdentifier__c='6019556730',vlocity_cmt__PremisesNumber__c='57374905');
        pList.add(p1);
        insert(pList);                
        List<vlocity_cmt__ServicePoint__c>SPList=new List<vlocity_cmt__ServicePoint__c>();
        vlocity_cmt__ServicePoint__c sp1=new vlocity_cmt__ServicePoint__c(SWAN_Corrector__c=true,SWAN_Data_Logger__c='Unknown',vlocity_cmt__ServicePointNumber__c='99994905',name='SP_57374905',vlocity_cmt__ActivationDate__c=date.today(),multisite_sync_due__c=true,vlocity_cmt__ServiceType__c='Gas',vlocity_cmt__PremisesId__c=p1.id);
        vlocity_cmt__ServicePoint__c sp2=new vlocity_cmt__ServicePoint__c(SWAN_Corrector__c=true,SWAN_Data_Logger__c='Unknown',vlocity_cmt__ServicePointNumber__c='99994904',name='SP_57374904',vlocity_cmt__ActivationDate__c=date.today(),multisite_sync_due__c=true,vlocity_cmt__ServiceType__c='Gas',vlocity_cmt__PremisesId__c=p1.id);
        SPList.add(sp1);
        SPList.add(sp2);
        insert(SPList);

        String UserId=UserInfo.getUserId();
        Map<String, Object> inputMap= new Map<String, Object>();
        Map<String, Object> outputMap=new Map<String, Object>();
        Map<String, Object> options=new Map<String, Object>();

        List<Id> spIds_Elec= new List<Id>();
        List<Id> spIds_Gas= new List<Id>{sp1.Id, sp2.Id};
        Map<String, Object> spIds= new Map<String, Object>();
        spIds.put('spIds_Elec',spIds_Elec);
        spIds.put('spIds_Gas',spIds_Gas);
        inputMap.put('spIds',spIds);

        Map<String, Object> AccountDetails= new Map<String, Object>();
        AccountDetails.put('AccountName',m.Name);
        AccountDetails.put('AccountId',m.Id);
        Map<String, Object> ParentAccount= new Map<String, Object>();
        ParentAccount.put('AccountDetails',AccountDetails);
        inputMap.put('ParentAccount',ParentAccount);
        String methodName='gasIndustryDataLoad';
            
        Test.startTest();
        SWAN_multisiteDataload multisiteDataload = new SWAN_multisiteDataload();
        multisiteDataload.invokeMethod(methodName,inputMap, outputMap, options);
        Test.stopTest();    
    }

    static testmethod void testBulkIndustryRefresh() {
        Account m = new Account(Name = 'AsyncTest1',SWAN_Customer_Segment__c = 'I&C', SWAN_Micro_Business_Selection__c = 'Non_Micro_Business',recordtypeid=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId());
        insert m;
        List<vlocity_cmt__Premises__c>pList=new List<vlocity_cmt__Premises__c>();
        vlocity_cmt__Premises__c p1= new vlocity_cmt__Premises__c(name='Prem 57374905',vlocity_cmt__PremisesType__c='Commercial Building',vlocity_cmt__PremisesIdentifier__c='6019556730',vlocity_cmt__PremisesNumber__c='57374905');
        pList.add(p1);
        insert(pList);                
        List<vlocity_cmt__ServicePoint__c>SPList=new List<vlocity_cmt__ServicePoint__c>();
        vlocity_cmt__ServicePoint__c sp1=new vlocity_cmt__ServicePoint__c(SWAN_Corrector__c=true,SWAN_Data_Logger__c='Unknown',vlocity_cmt__ServicePointNumber__c='99994905',name='SP_57374905',vlocity_cmt__ActivationDate__c=date.today(),multisite_sync_due__c=true,vlocity_cmt__ServiceType__c='Gas',vlocity_cmt__PremisesId__c=p1.id);
        vlocity_cmt__ServicePoint__c sp2=new vlocity_cmt__ServicePoint__c(SWAN_Corrector__c=true,SWAN_Data_Logger__c='Unknown',vlocity_cmt__ServicePointNumber__c='99994904',name='SP_57374904',vlocity_cmt__ActivationDate__c=date.today(),multisite_sync_due__c=true,vlocity_cmt__ServiceType__c='Gas',vlocity_cmt__PremisesId__c=p1.id);
        vlocity_cmt__ServicePoint__c sp3=new vlocity_cmt__ServicePoint__c(SWAN_Corrector__c=true,SWAN_Data_Logger__c='Unknown',vlocity_cmt__ServicePointNumber__c='99994905',name='SP_57374905',vlocity_cmt__ActivationDate__c=date.today(),multisite_sync_due__c=true,vlocity_cmt__ServiceType__c='Electricity',vlocity_cmt__PremisesId__c=p1.id);
        vlocity_cmt__ServicePoint__c sp4=new vlocity_cmt__ServicePoint__c(SWAN_Corrector__c=true,SWAN_Data_Logger__c='Unknown',vlocity_cmt__ServicePointNumber__c='99994904',name='SP_57374904',vlocity_cmt__ActivationDate__c=date.today(),multisite_sync_due__c=true,vlocity_cmt__ServiceType__c='Electricity',vlocity_cmt__PremisesId__c=p1.id);
        
        SPList.add(sp1);
        SPList.add(sp2);
        SPList.add(sp3);
        SPList.add(sp4);
        insert(SPList);

        String UserId=UserInfo.getUserId();
        Map<String, Object> inputMap= new Map<String, Object>();
        Map<String, Object> outputMap=new Map<String, Object>();
        Map<String, Object> options=new Map<String, Object>();

        List<Id> spIds_Elec= new List<Id>{sp3.Id, sp4.Id};
        List<Id> spIds_Gas= new List<Id>{sp1.Id, sp2.Id};
        Map<String, Object> spIds= new Map<String, Object>();
        spIds.put('spIds_Elec',spIds_Elec);
        spIds.put('spIds_Gas',spIds_Gas);
        inputMap.put('spIds',spIds);

        Map<String, Object> AccountDetails= new Map<String, Object>();
        AccountDetails.put('AccountName',m.Name);
        AccountDetails.put('AccountId',m.Id);
        Map<String, Object> ParentAccount= new Map<String, Object>();
        ParentAccount.put('AccountDetails',AccountDetails);
        inputMap.put('ParentAccount',ParentAccount);
        String methodName='bulkIndustryDataRefresh';
            
        Test.startTest();
        SWAN_multisiteDataload multisiteDataload = new SWAN_multisiteDataload();
        multisiteDataload.invokeMethod(methodName,inputMap, outputMap, options);
        Test.stopTest(); 
    }
    


}