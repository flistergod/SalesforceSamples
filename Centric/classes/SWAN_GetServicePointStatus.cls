global with sharing class SWAN_GetServicePointStatus implements vlocity_cmt.VlocityOpenInterface {

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
                if (methodName.equals('getServicePointStatus'))
                {
                    getServicePointStatus(inputMap,outputMap,options);
                }
                if (methodName.equals('getServicePointCount'))
                {
                    getServicePointCount(inputMap,outputMap,options);
                }
                else 
                {
                    result = false;
                }   
            } 
            catch(Exception e)
            {System.debug('SWAN_GetServicePointStatus:invokeMethod -> exception: '+e);
                result = false;}
            
            return result;
        
        }

        global Boolean getServicePointCount(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options){

        
            String contractID = String.ValueOf(inputMap.get('ContextId'));
            String contractStatus = String.ValueOf(inputMap.get('ContractStatus')); //updated line on 03/09/2021

            List<vlocity_cmt__ContractLineItem__c> clis=
            [
                SELECT id, vlocity_cmt__ContractId__r.vlocity_cmt__OpportunityId__r.RecordType.Name, vlocity_cmt__ContractId__c,
                Name,vlocity_cmt__LineStatus__c, vlocity_cmt__EffectiveEndDate__c,vlocity_cmt__ContractId__r.ContractNumber, vlocity_cmt__ContractId__r.EndDate,
                vlocity_cmt__ContractId__r.StartDate, vlocity_cmt__ContractId__r.Status,vlocity_cmt__ContractId__r.vlocity_cmt__ContractType__c,
                SWAN_Service_Point__c,SWAN_Service_Point__r.Name, SWAN_Service_Point__r.Id, SWAN_Service_Point__r.vlocity_cmt__ServicePointNumber__c,
                vlocity_cmt__EffectiveStartDate__c, SWAN_Service_Point_Start_Date__c, SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Site_Addition_Parent__c, 
                SWAN_Service_Point_End_Date__c, 
                (select id,SWAN_Service_Point_End_Date__c,vlocity_cmt__EffectiveEndDate__c, vlocity_cmt__EffectiveStartDate__c,vlocity_cmt__LineStatus__c 
                from vlocity_cmt__Contract_Line_Items__r) 
                from vlocity_cmt__ContractLineItem__c 
                where vlocity_cmt__ContractId__c =:contractID 
                AND vlocity_cmt__LineStatus__c =:contractStatus  
                AND vlocity_cmt__OriginalLineItemId__c = null 
                AND SWAN_Service_Point__c != null
                ];

            if(clis==null || clis.size()==0){
                outputMap.put('ContractLineItemSize',0);
                return false;
            }

            outputMap.put('ContractLineItemSize',clis.size());
            return true;
        }
        
        global Boolean getServicePointStatus(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
          Boolean result=false;
            List<Object> parentCLI= new List<Object>();
            Integer i =0;
            String contractID = String.ValueOf(inputMap.get('ContextId'));
            String contractStatus = String.ValueOf(inputMap.get('ContractStatus')); //updated line on 03/09/2021

            List<vlocity_cmt__ContractLineItem__c> clis=
            [
                SELECT id, vlocity_cmt__ContractId__r.vlocity_cmt__OpportunityId__r.RecordType.Name, vlocity_cmt__ContractId__c,
                Name,vlocity_cmt__LineStatus__c, vlocity_cmt__EffectiveEndDate__c,vlocity_cmt__ContractId__r.ContractNumber, vlocity_cmt__ContractId__r.EndDate,
                vlocity_cmt__ContractId__r.StartDate, vlocity_cmt__ContractId__r.Status,vlocity_cmt__ContractId__r.vlocity_cmt__ContractType__c,
                SWAN_Service_Point__c,SWAN_Service_Point__r.Name, SWAN_Service_Point__r.Id, SWAN_Service_Point__r.vlocity_cmt__ServicePointNumber__c,
                vlocity_cmt__EffectiveStartDate__c, SWAN_Service_Point_Start_Date__c, SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Site_Addition_Parent__c, 
                SWAN_Service_Point_End_Date__c, 
                (select id,SWAN_Service_Point_End_Date__c,vlocity_cmt__EffectiveEndDate__c, vlocity_cmt__EffectiveStartDate__c,vlocity_cmt__LineStatus__c 
                from vlocity_cmt__Contract_Line_Items__r) 
                from vlocity_cmt__ContractLineItem__c 
                where vlocity_cmt__ContractId__c =:contractID 
                AND vlocity_cmt__LineStatus__c =:contractStatus  
                AND vlocity_cmt__OriginalLineItemId__c = null 
                AND SWAN_Service_Point__c != null
                ];

            if(clis==null || clis.size()==0){
                outputMap.put('ContractLineItem',parentCLI);
            }
            else{

            for(vlocity_cmt__ContractLineItem__c cli : clis) {
                if(i == 0)
                {
                    outputMap.put('NumberOfSps',clis.size());
                    outputMap.put('Contract Number',cli.vlocity_cmt__ContractId__r.ContractNumber);
                    outputMap.put('Contract Status', cli.vlocity_cmt__ContractId__r.Status);    
                    outputMap.put('EndDate', cli.vlocity_cmt__ContractId__r.EndDate); 
                    outputMap.put('StartDate', cli.vlocity_cmt__ContractId__r.StartDate);
                    i++;
                }   
                Map<String, Object> eachRec = pushEachRecord(cli);
                parentCLI.add(eachRec);
            //    System.debug('Size Parent cli'+parentCLI.size());
            }   
            if(parentCLI.size()>0)
            {
                outputMap.put('ContractLineItem',parentCLI);
              //  system.debug('outputMapNinad'+outputMap);
            }

            result =true;
          
        }

        return result;
       
            }
            
            global Map<String, Object> pushEachRecord(vlocity_cmt__ContractLineItem__c cli)
            {
                Map<String, Object> eachRec = new Map<String, Object>();
                List<Object> childCLI= new List<Object>();
                childCLI.addAll(pushEachRecordOfChildCLI(cli));
               // System.debug('Size CHild cli'+childCLI.size());
                if(childCLI.size()>0)
                {
                    eachRec.put('ContractLineItemChild',childCLI);
                  //  system.debug('eachRec'+eachRec);
                }

                //used on Cancel Contract for selectable items template
                eachRec.put('ServicePointId', cli.SWAN_Service_Point__r.Id);
                eachRec.put('ServicePoint', cli.SWAN_Service_Point__r.vlocity_cmt__ServicePointNumber__c); 
                

                try {
                    
                    DateTime effectivefrom = (DateTime) cli.vlocity_cmt__EffectiveStartDate__c;
                    DateTime effectiveto = (DateTime) cli.vlocity_cmt__EffectiveEndDate__c;
                    DateTime Contractualstartdate = (DateTime) cli.SWAN_Service_Point_Start_Date__c;
                  
                    Date effectivefromDate = date.newinstance(effectivefrom.year(), effectivefrom.month(), effectivefrom.day());
                    Date effectivetoDate = date.newinstance(effectiveto.year(), effectiveto.month(), effectiveto.day());
                    Date ContractualstartdateDate = date.newinstance(Contractualstartdate.year(), Contractualstartdate.month(), Contractualstartdate.day());
                    
                    eachRec.put('ContractualStartDate', ContractualstartdateDate.format());
                    eachRec.put('EffectiveFrom',  effectivefromDate.format());
                    eachRec.put('EffectiveTo', effectivetoDate.format());
                    eachRec.put('Status', cli.vlocity_cmt__LineStatus__c);
                    

                        
                if(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Site_Addition_Parent__c == null)
                {
                    if(cli.vlocity_cmt__ContractId__r.vlocity_cmt__OpportunityId__r.Recordtype.Name==null){
                        eachRec.put('DealType', '');
                    }
                    else{
                    eachRec.put('DealType', cli.vlocity_cmt__ContractId__r.vlocity_cmt__OpportunityId__r.Recordtype.Name);
                    }
                }
                else
                {
                    String site_Addition = 'Site Addition';
                    eachRec.put('DealType',(Object)site_Addition);
                } 
              
                
     
                //
                eachRec.put('Contract Number', cli.vlocity_cmt__ContractId__r.ContractNumber);
                eachRec.put('Effective Start Date', cli.vlocity_cmt__EffectiveStartDate__c);
              
                Date d = date.valueof(cli.vlocity_cmt__EffectiveEndDate__c);
                //system.debug('//d' + d);
                string dateStr = DateTime.newInstance(d.year(),d.month(),d.day()).format('dd/MM/yyyy');
               // system.debug('//' + dateStr);
                //eachRec.put('End Date', dateStr));
                eachRec.put('Effective End Date', dateStr);
                eachRec.put('ContractId', cli.vlocity_cmt__ContractId__c);
                eachRec.put('Contract_Line_Item_Id', cli.Id);
                eachRec.put('Name', cli.Name);
                eachRec.put('Service Point', cli.SWAN_Service_Point__c);
                eachRec.put('Service Point Name', cli.SWAN_Service_Point__r.Name);
                eachRec.put('Contract Type', cli.vlocity_cmt__ContractId__r.vlocity_cmt__ContractType__c);
              // system.debug('//cli' + cli.SWAN_Service_Point_End_Date__c);
                eachRec.put('End Date', Date.valueOf(cli.SWAN_Service_Point_End_Date__c));
                eachRec.put('Contract Status', cli.vlocity_cmt__ContractId__r.Status);

            } catch(Exception e) {
                System.debug(e.getMessage());
            }
             
                return eachRec;


            }
            
            global List<Object> pushEachRecordOfChildCLI(vlocity_cmt__ContractLineItem__c cli)
            {
                Map<String, Object> eachRecOfChildCLI = new Map<String, Object>();
                List<Object> childCLI= new List<Object>();
                for(vlocity_cmt__ContractLineItem__c  child_cli : cli.vlocity_cmt__Contract_Line_Items__r){ 
                        eachRecOfChildCLI.put('Id',child_cli .id);
                        eachRecOfChildCLI.put('End Date',child_cli .SWAN_Service_Point_End_Date__c);
                        eachRecOfChildCLI.put('Effective End Date',child_cli .vlocity_cmt__EffectiveEndDate__c);
                        eachRecOfChildCLI.put('Effective Start Date',child_cli .vlocity_cmt__EffectiveStartDate__c);
                        eachRecOfChildCLI.put('Status',child_cli .vlocity_cmt__LineStatus__c);
                        childCLI.add(eachRecOfChildCLI);
                    }   
                return childCLI;
            }
    }