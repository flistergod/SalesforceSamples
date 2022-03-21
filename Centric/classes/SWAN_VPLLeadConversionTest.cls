@isTest
public class SWAN_VPLLeadConversionTest {
    public static Lead l = new Lead();
    public static void createStaticData()
    {
        //Lead l = new Lead();
    l.LastName = 'LastName';
    l.Company = 'Company';
        l.SWAN_Company_Registration_No__c = '12344322';
        l.SWAN_Billing_Building_Name__c= 'test building';
        l.Street = 'test Street';
        l.PostalCode ='FT66 5RR';
        l.FirstName ='TestLead';
        l.city = 'test City';
        l.LeadSource='Advertisement';
        l.SWAN_Customer_Segment__c = 'I&C';
        l.SWAN_Micro_Business_Selection__c = 'Non_Micro_Business';
    //insert l;
    }
    
    @isTest
  public static void leadConversionTest()
    {
        createStaticData();
      //  l.Lead_Type__c = 'Consumer';
        insert l;
        VPLLeadConversion leadConversion = new VPLLeadConversion();
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> businessTypeMap = new Map<String,Object>();
        businessTypeMap.put('BusinessType','Business');
        inputMap.put('LeadDetails',businessTypeMap);
        Map<String,Object> outputMap = new Map<String,Object>();
        inputMap.put('DRId_Lead', (Object)l.Id);
    leadConversion.invokeMethod('LeadConversion',inputMap,outputMap,null);
    Map<String,Object> options= new Map<String,Object>();
    options.put('ObjectAPI','OPPORTUNITY');
    options.put('RecordId',string.valueof(outputMap.get('OpportunityId')));
    leadConversion.invokeMethod('CloneRecord',inputMap,outputMap,options);
        
    }
    
    @isTest
  public static void leadConversionToBrokerTest()
    {
        createStaticData();
        //l.Lead_Type__c = 'Consumer';
        Boolean val = true;
        Boolean IsBrokerAccount = Boolean.valueOf(val);
        Object obj = (Object)IsBrokerAccount;
        insert l;
        VPLLeadConversion leadConversion = new VPLLeadConversion();
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outputMap = new Map<String,Object>();
        Map<String,Object> businessTypeMap = new Map<String,Object>();
        businessTypeMap.put('BusinessType','Business');
        inputMap.put('LeadDetails',businessTypeMap);
        inputMap.put('DRId_Lead', (Object)l.Id);
        System.debug('obj'+obj);
        inputMap.put('IsBrokerAccount', obj);
        System.debug('inputMap'+inputMap);
    leadConversion.invokeMethod('LeadConversion',inputMap,outputMap,null);
        
    }
    
    @isTest
  public static void leadConversionTestIncorrectMethod()
    {
        createStaticData();
        l.Lead_Type__c = 'Business';
        insert l;
        VPLLeadConversion leadConversion = new VPLLeadConversion();
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outputMap = new Map<String,Object>();
        Map<String,Object> businessTypeMap = new Map<String,Object>();
        businessTypeMap.put('BusinessType','Business');
        inputMap.put('LeadDetails',businessTypeMap);
        inputMap.put('DRId_Lead', (Object)l.Id);
    leadConversion.invokeMethod('Lead',inputMap,outputMap,null);
        
    }
    
    @isTest
  public static void leadConversionTestIncorrectLeadType()
    {
        createStaticData();
        insert l;
        VPLLeadConversion leadConversion = new VPLLeadConversion();
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outputMap = new Map<String,Object>();
        Map<String,Object> businessTypeMap = new Map<String,Object>();
        businessTypeMap.put('BusinessType','Business');
        inputMap.put('LeadDetails',businessTypeMap);
        inputMap.put('DRId_Lead', '');
    leadConversion.invokeMethod('LeadConversion',inputMap,outputMap,null);
        
    }
    
    @isTest
  public static void leadConversionTestDuplicateCustomer()
    {
        createStaticData();
        l.Lead_Type__c = 'Business';
        insert l;
        VPLLeadConversion leadConversion = new VPLLeadConversion();
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outputMap = new Map<String,Object>();
        Map<String,Object> businessTypeMap = new Map<String,Object>();
        businessTypeMap.put('BusinessType','Business');
        inputMap.put('LeadDetails',businessTypeMap);
        inputMap.put('DRId_Lead', (Object)l.Id);
    leadConversion.invokeMethod('LeadConversion',inputMap,outputMap,null);
        
    l = new Lead();
        createStaticData();
        l.Lead_Type__c = 'Business';
        insert l;
        VPLLeadConversion leadConversion1 = new VPLLeadConversion();
        Map<String,Object> inputMap1 = new Map<String,Object>();
        Map<String,Object> outputMap1 = new Map<String,Object>();
        inputMap1.put('DRId_Lead', (Object)l.Id);
        try{
          leadConversion1.invokeMethod('LeadConversion',inputMap1,outputMap1,null);    
        }
        catch(Exception e)
        {
            system.debug(e);
        }
    
    }
}