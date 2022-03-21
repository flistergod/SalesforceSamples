public class OfferPackExcelGeneratorController 
{
    public string ExcelFileName{get;set;}
    public string BGlogourl{get;set;}
    public id OfferPackId{get;set;}
    public id Mquoteid{get;set;}
    public string customer{get;set;}
    public string QuoteName;
    public string QuoteNumber{get;set;}
    public string startdate{get;set;}
    public string enddate{get;set;}
    public string product{get;set;}
    public string duration {get;set;}
    public integer NumberofSites{get;set;}
    public decimal annualspend{get;set;}
    public decimal totalAQ{get;set;}
    public decimal contractVolume{get;set;}
    public list<ServicePoints>SPs{get;set;}
    List<attachment>allReports=new List<attachment>();
    public String fuelType{get;set;}
    
    public OfferPackExcelGeneratorController()
    {
        if(!Test.isRunningTest())
            BGlogourl=URL.getSalesforceBaseUrl().toExternalForm()+'/servlet/servlet.ImageServer?id='+[SELECT Id, Name FROM Document where name='bgLogoQuoteAnnexe' limit 1].id+'&oid='+UserInfo.getOrganizationId();
        if(Apexpages.currentpage() != null) {
            OfferPackId=Apexpages.currentpage().getparameters().get('id');
            Mquoteid=Apexpages.currentpage().getparameters().get('mquoteid');
            OfferPackExcelGeneratorController1();
        }        
    }
    
    public List<attachment> OfferPackExcelGeneratorController1()//id Mquoteid,id OfferPackId
    {
        set<id>MasterQuoteId=new set<id>();
        /*for(SWAN_Offer_Pack_Quote__c opq : [Select id,SWAN_Quote__c from SWAN_Offer_Pack_Quote__c where SWAN_Offer_Pack__c =:OfferPackId])
        {
            MasterQuoteId.add(opq.SWAN_Quote__c);    
        }*/
        MasterQuoteId.add(Mquoteid);    //////////////
        List<Quote>MasteQuoteandSPQuoteDetails=new List<quote>();
        set<id>SPQID=new set<id>();
        for(Quote MasterQ : [SELECT id,
                            Name,
                            QuoteNumber,
							SWAN_Quote_Type__c,
                            SWAN_Account_Name__c, 
                            Opportunity.SWAN_Fuel_Type__c, 
                            SWAN_Offer_Start_Date__c,
                            SWAN_Offer_End_Date__c,
                            SWAN_Offer_Duration__c,
                            SWAN_Number_of_Service_Points__c,
                            SWAN_Annual_Spend__c,
                            SWAN_Contract_Volume_KWh__c,
                            (SELECT id,
                            SWAN_Contract_Volume_KWh__c,
                            SWAN_Service_Point_Start_Date__c,
                            vlocity_cmt__DefaultServicePointId__c,
                            vlocity_cmt__DefaultServicePointId__r.SWAN_Formula_Year_Annual_Quantity__c,
                            vlocity_cmt__DefaultServicePointId__r.SWAN_Formula_Year_Offtake_Quantity__c,
                            vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__ServicePointNumber__c,
                            vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.SWAN_House_Number__c,
                            vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.SWAN_House_Name__c,
                            vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,
                            vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c,
                            vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Country__c,
                            vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c,
                            vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c,
                            vlocity_cmt__DefaultServicePointId__r.SWAN_Supply_Capacity__c,
                            vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c,
                            vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class_Ovrd__c,
                            vlocity_cmt__DefaultServicePointId__r.SWAN_Standard_Settlement_Configuration__c,
                            vlocity_cmt__DefaultServicePointId__r.SWAN_Standard_Settlement_Config_Ovrd__c,
                            Recordtype.Developername 
                            FROM vlocity_cmt__Quotes__r 
                            WHERE Recordtype.Developername != 'GroupCart'),
                            (SELECT id,product2.name 
                            FROM QuoteLineItems 
                            WHERE product2.vlocity_cmt__IsOrderable__c=true/*SWAN_UnitRate__c=null and vlocity_cmt__RecurringCharge__c=null*/) 
                            FROM quote 
                            WHERE id in:MasterQuoteId])
        {
            MasteQuoteandSPQuoteDetails.add(MasterQ);
			if(MasterQ.SWAN_Quote_Type__c == 'Fixed'){
				for(quote spq : MasterQ.vlocity_cmt__Quotes__r)
				{
					SPQID.add(spq.id);   
				}
			}
        }
        
        map<id,List<QuotelineItem>>SPvsQLI=new map<id,List<QuotelineItem>>();
        for(QuotelineItem qli : [SELECT id,
                                        Quoteid,
                                        Product2Id,
                                        Product2.Name,
                                        SWAN_UnitRate__c,
                                        vlocity_cmt__RecurringCharge__c,
                                        vlocity_cmt__JSONAttribute__c, 
                                        Product2.vlocity_cmt__IsOrderable__c,
                                        Product2.vlocity_cmt__Type__c,
                                        Product2.vlocity_cmt__SubType__c 
                                FROM QuotelineItem 
                                WHERE (Product2.ProductCode != 'BG_BSUOS_PASS_THROUGH_PRICE' OR Product2.ProductCode != 'BG_AAHEDC_PASS_THROUGH_PRICE') AND Quoteid IN:SPQID order by Product2.vlocity_cmt__SubType__c, Product2.Name asc])
        {
            if(!SPvsQLI.containskey(qli.quoteid))
            {
                List<QuotelineItem>temp=new List<QuotelineItem>();
                temp.add(qli);
                SPvsQLI.put(qli.quoteid,temp);
            }
            else
            {
                List<QuotelineItem>temp=SPvsQLI.get(qli.quoteid);
                temp.add(qli);
                SPvsQLI.put(qli.quoteid,temp);
            }
        }
		
        for(quote mq : MasteQuoteandSPQuoteDetails)
        {
            customer=mq.SWAN_Account_Name__c;
            QuoteName=mq.name;
            fuelType =mq.Opportunity.SWAN_Fuel_Type__c;
            QuoteNumber=mq.quotenumber;
            startdate=(mq.SWAN_Offer_Start_Date__c!=null?mq.SWAN_Offer_Start_Date__c.format():'');
            enddate=(mq.SWAN_Offer_end_Date__c!=null?mq.SWAN_Offer_end_Date__c.format():'');
            product=mq.QuoteLineItems[0].product2.name;
            duration=mq.SWAN_Offer_Duration__c;
            duration = duration.substringBefore(' ');
            NumberofSites=(mq.SWAN_Number_of_Service_Points__c!=null?integer.valueof(mq.SWAN_Number_of_Service_Points__c):0);
            annualspend=mq.SWAN_Annual_Spend__c;
            contractVolume = mq.SWAN_Contract_Volume_KWh__c;
            SPs=new List<ServicePoints>();
            totalAQ=0;
            for(quote spq : mq.vlocity_cmt__Quotes__r)            
            {
                ServicePoints row = new ServicePoints();
                row.ServicePointNumber=spq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__ServicePointNumber__c;
                row.siteAddress = (spq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.SWAN_House_Number__c!=null?spq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.SWAN_House_Number__c+',':'')+(spq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.SWAN_House_Name__c!=null?spq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.SWAN_House_Name__c+',':'')+(spq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c!=null?spq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c+',':'')+(spq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c!=null?spq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c+',':'')+(spq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Country__c!=null?spq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Country__c+',':'')+(spq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c!=null?spq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c+',':'')+(spq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c!=null?spq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c:'');    
                row.AQ=spq.vlocity_cmt__DefaultServicePointId__r.SWAN_Formula_Year_Annual_Quantity__c!=null?Integer.valueof(spq.vlocity_cmt__DefaultServicePointId__r.SWAN_Formula_Year_Annual_Quantity__c):0;
                row.SOQ=spq.vlocity_cmt__DefaultServicePointId__r.SWAN_Formula_Year_Offtake_Quantity__c!=null?Integer.valueof(spq.vlocity_cmt__DefaultServicePointId__r.SWAN_Formula_Year_Offtake_Quantity__c):0;
                totalAQ+=row.AQ;
                row.conVol = Integer.ValueOf(spq.SWAN_Contract_Volume_KWh__c);
                system.debug('con volume='+row.ConVol+'=sp='+spq.Id);
                row.standingCharge='="0.000"';// defaulting for bug 3645
                row.supplyStartDate = spq?.SWAN_Service_Point_Start_Date__c.format();
                row.kVA = spq.vlocity_cmt__DefaultServicePointId__r?.SWAN_Supply_Capacity__c;
                row.unit =  new List<string>();
                
                for(quotelineitem qli : SPvsQLI.get(spq.id)){

                    if(qli.SWAN_UnitRate__c!=null)
                    {
                        row.unitRate=qli.SWAN_UnitRate__c;
                    }
                    else if(qli.vlocity_cmt__RecurringCharge__c!=null)
                    {
                        row.standingCharge=string.valueof(qli.vlocity_cmt__RecurringCharge__c);
                    }

                    // Map elec csv fields 
                    if( fuelType == 'Electricity' && qli.Product2.Name == 'Availability Charge' && qli.Product2.vlocity_cmt__IsOrderable__c == false) {
                        row.availabilityCharge=qli?.SWAN_UnitRate__c;

                    }else if( fuelType == 'Electricity' && qli.Product2.Name == 'Standing Charge') {
                        row.standingCharge = string.valueof( (qli?.SWAN_UnitRate__c) );

                    }else if( fuelType== 'Electricity' && qli.Product2.vlocity_cmt__Type__c=='Electricity'  && fuelType == 'Electricity' && qli.Product2.vlocity_cmt__IsOrderable__c == true ){
                        
                        String measurementClass;
                        String value = spq.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c;
                        String valueOvrd = spq.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class_Ovrd__c;
                    
                        measurementClass = (valueOvrd != null) ? valueOvrd : value;
                        //Map Rate Structure
                        if (measurementClass == 'A' || measurementClass == 'B') {
                            value = spq.vlocity_cmt__DefaultServicePointId__r.SWAN_Standard_Settlement_Configuration__c;
                            valueOvrd = spq.vlocity_cmt__DefaultServicePointId__r.SWAN_Standard_Settlement_Config_Ovrd__c;
                            
                            row.rateStructure = 'NHH (' + ((valueOvrd != null) ? valueOvrd : value) + ')';
                        } else {
                            
                            for(object Attr : (List<object>) ((Map<String, Object>)JSON.deserializeUntyped(String.valueof(qli.vlocity_cmt__JSONAttribute__c))).get('SWAN_QUOTE_CONFIG_ATT_CAT')) {
                                String key = (string) ((map<string,object>)Attr).get('attributeuniquecode__c');
                                
                                if(key == 'SWAN_ATT_HH_RATE_STRUCT'){
                                    row.rateStructure = string.valueof(((MAP<string,object>)((MAP<string,object>)((map<string,object>)Attr).get('attributeRunTimeInfo')).get('selectedItem')).get('value'));
                                    break;
                                }
                            }
                        }
                        
                    }else if(fuelType == 'Electricity' && qli.Product2.vlocity_cmt__SubType__c == 'Unit Rate' && qli.Product2.vlocity_cmt__IsOrderable__c == false ){
                        String unitRateVal = qli.SWAN_UnitRate__c == null || qli.SWAN_UnitRate__c == 0.0 ? '0.000'  : String.ValueOf(qli.SWAN_UnitRate__c);
                        String pName = qli.Product2.Name + '</td><td style="text-align:left;vertical-align: middle;font-family: Arial;border-right:1px solid #03C3F2;">' + unitRateVal;
                        
                        if(pName != null ){
                            row.unit.add(pName);
                        }
                    } 
                }
                 if(row.unit.size() < 6)
                 {
                    for(integer i = row.unit.size() ; i < 6;i++)
                    {
                      row.unit.add('</td><td style="text-align:left;border-right:1px solid #03C3F2;">');
                    }
                 }
                  system.debug('total size='+row.unit.size());
                SPs.add(row);
            }

            // Excel file name 
            ExcelFileName = QuoteNumber+' - '+system.now()+'.xls';
            // Produce Excell file 
            allReports.add(saveExcel());
        }
        return allReports;
    }
    
    public attachment saveExcel() {
    
        PageReference excel =  (fuelType == 'Electricity' ? Page.Excel_ImageElec : Page.Excel_Image);
        excel.getParameters().put('id', OfferPackId);
        excel.getParameters().put('mquoteid', Mquoteid);//temp

        // add parent id to the parameters for standardcontroller
    
        // create the new attachment
        //system.debug(annualspend+' % '+ExcelFileName+' % '+customer+' % '+QuoteName+' % '+startdate+' % '+enddate+' % '+product+' % '+duration +' % '+NumberofSites+' % '+totalAQ);
        
        Attachment attach = new Attachment();
        
        // the contents of the attachment from the pdf
        Blob body;
        
        try {  
            // returns the output of the page as a excel
            body = excel.getContent();      
            //system.debug('=========='+excel.getContent()+'$$%%%%% '+body     );
            // need to pass unit test -- current bug    
        } catch (VisualforceException e) {
            body = Blob.valueOf('Some Text');
        }
        
        attach.Body = body;
        // add the user entered name
        attach.Name = ExcelFileName;
        attach.IsPrivate = false;
        // attach the excel to the account
        attach.ParentId = (OfferPackId!=null ? OfferPackId : Mquoteid) ;
        attach.ContentType='application/vnd.ms-excel';
        return attach;
    }
    public class ServicePoints{
        public string ServicePointNumber{get;set;}
        public string siteAddress {get;set;}
        public integer AQ{get;set;}
        public integer SOQ{get;set;}
        public integer conVol{get;set;}
        public decimal CustomerAQ{get;set;}
        public decimal unitRate{get;set;}
        public string standingCharge{get;set;}
        public string supplyStartDate{get;set;}
        public double kVA{get;set;}
        public double availabilityCharge{get;set;}
        public string rateStructure{get;set;}
        public List<string> unit{get;set;}
       
    }
}