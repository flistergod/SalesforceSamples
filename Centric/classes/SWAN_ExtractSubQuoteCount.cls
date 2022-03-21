//Test class: SWAN_OverlapSPTest
global with sharing class SWAN_ExtractSubQuoteCount implements vlocity_cmt.VlocityOpenInterface {

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
               if (methodName.equals('getSubQuoteCount'))
               {
                   getSubQuoteCount(inputMap,outputMap,options);
               }
               if (methodName.equals('createContract'))
               {
                   createContract(inputMap,outputMap,options);
               }
               if (methodName.equals('updateServicePointStatus'))
               {
                   updateServicePointStatus(inputMap,outputMap,options);
               }
               if (methodName.equals('updateSelectedServicePointStatus'))
               {
                   updateSelectedServicePointStatus(inputMap,outputMap,options);
               }
               else 
               {
                   result = false;
               }   
           } 
           catch(Exception e)
           {System.debug('SWAN_ExtractSubQuoteCount:invokeMethod -> exception: '+e);
               result = false;}
           
           return result;
       
       }
       
       global Boolean getSubQuoteCount(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
       /*List<Object> subQuotes = new List<Object>();
       List<Object> subQuotesQLI = new List<Object>();*/
       String masterQuoteId = String.ValueOf(inputMap.get('ContextId'));
       /*for(Quote childQuote : [SELECT id,swan_parent_quote__c,opportunityid,status,accountid,swan_broker_commission__c,swan_commission_payment_period__c,email,name,swan_pricing_structure__c,swan_productid__c,swan_annual_spend__c,swan_broker__c,swan_broker_commission_margin_p__c,swan_broker_commission_margin_pence_per__c,swan_broker_commission_as_pc__c,swan_broker_commission_margin_unit__c,swan_contract_volume_kwh__c,swan_service_point_end_date__c,swan_service_point_start_date__c,pricebook2id,description,discount,recordtypeid,swan_service_point__c,swan_broker__r.commission_payment_period__c,swan_commodity__c,swan_commodity_as_pc__c,swan_contract_spend__c,swan_contribution_margin_p__c,swan_contribution_margin_unit__c,swan_contribution_margin_pc__c,swan_contribution_margin_pence_per__c,swan_cost_to_serve__c,swan_gross_margin__c,swan_gross_margin_pc__c,swan_justification_comment__c,swan_justification_reasons__c,swan_metering__c,swan_metering_as_pc__c,swan_non_commodity_as_pc__c,swan_number_of_service_points__c,swan_offer_duration__c,swan_offer_end_date__c,swan_offer_start_date__c,swan_parent_opportunity__c,swan_payment_method__c,swan_payment_term__c,vlocity_cmt__pricelistid__c,vlocity_cmt__pricelistid__r.name,swan_price_out_of_date__c,swan_quote_for_fuel_type__c,recordtype.name,swan_payment_method_and_term__c,swan_standing_charge_as_split__c,swan_unit_rate_as_split__c,swan_sales_channel__c FROM Quote WHERE SWAN_Parent_Quote__c = :masterQuoteId])
       {
               Map<String, Object> eachRec = pushEachRecord(childQuote);
               subQuotes.add(eachRec);
       }   */
   
       Integer sub_Quotes_Size= [Select COUNT() from Quote WHERE vlocity_cmt__ParentQuoteId__c = :masterQuoteId AND Recordtype.DeveloperName != 'GroupCart'];
           if(sub_Quotes_Size > 0)
       {
           outputMap.put('sub_Quotes_Size',sub_Quotes_Size);
       }
           else{outputMap.put('sub_Quotes_Size',0);}
            
       
       
       return true;
       }
       
       
        global Boolean createContract(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
       String masterQuoteId = String.ValueOf(inputMap.get('ContextId'));
       /*for(Quote childQuote : [SELECT id,swan_parent_quote__c,opportunityid,status,accountid,swan_broker_commission__c,swan_commission_payment_period__c,email,name,swan_pricing_structure__c,swan_productid__c,swan_annual_spend__c,swan_broker__c,swan_broker_commission_margin_p__c,swan_broker_commission_margin_pence_per__c,swan_broker_commission_as_pc__c,swan_broker_commission_margin_unit__c,swan_contract_volume_kwh__c,swan_service_point_end_date__c,swan_service_point_start_date__c,pricebook2id,description,discount,recordtypeid,swan_service_point__c,swan_broker__r.commission_payment_period__c,swan_commodity__c,swan_commodity_as_pc__c,swan_contract_spend__c,swan_contribution_margin_p__c,swan_contribution_margin_unit__c,swan_contribution_margin_pc__c,swan_contribution_margin_pence_per__c,swan_cost_to_serve__c,swan_gross_margin__c,swan_gross_margin_pc__c,swan_justification_comment__c,swan_justification_reasons__c,swan_metering__c,swan_metering_as_pc__c,swan_non_commodity_as_pc__c,swan_number_of_service_points__c,swan_offer_duration__c,swan_offer_end_date__c,swan_offer_start_date__c,swan_parent_opportunity__c,swan_payment_method__c,swan_payment_term__c,vlocity_cmt__pricelistid__c,vlocity_cmt__pricelistid__r.name,swan_price_out_of_date__c,swan_quote_for_fuel_type__c,recordtype.name,swan_payment_method_and_term__c,swan_standing_charge_as_split__c,swan_unit_rate_as_split__c,swan_sales_channel__c FROM Quote WHERE SWAN_Parent_Quote__c = :masterQuoteId])
       {
               Map<String, Object> eachRec = pushEachRecord(childQuote);
               subQuotes.add(eachRec);
       }   */
       try{
               Database.executeBatch(new SWAN_CreateContractBatch(masterQuoteId,UserInfo.getUserId()),1000);
               return true;
           }
           catch(exception e){
               return false;
           } 
       }
       
       global Boolean updateServicePointStatus(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
           String process_Name = String.ValueOf(inputMap.get('Processname'));
           String final_status = String.ValueOf(inputMap.get('FinalStatus'));
           String needForMap= String.ValueOf(inputMap.get('NeedForMap'));
           String terminatedEndDateTime = String.ValueOf(inputMap.get('TerminatedEndDateTime'));
           Object selectServicePoint = inputMap.get('SelectServicePoint');
           Object contractLineItem;
           List<Object> contractLineItem_list;
   
           if(needForMap=='false'){
               contractLineItem_list= (List<Object>)inputMap.get('ContractLineItem');
           }else{
               try {
                   Map<String, Object> selectServicePoint_map = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(selectServicePoint));
                   system.debug('selectServicePoint_map.values()'+selectServicePoint_map.values());
                   system.debug('selectServicePoint_map.keyset()'+selectServicePoint_map.keyset());
                   contractLineItem = selectServicePoint_map.get('ContractLineItem');
                   contractLineItem_list = (List<Object>)contractLineItem;
   
               } catch(Exception e) {
                   System.debug(e.getMessage());
               }
           }
       
           system.debug('contractLineItem_list debuggg'+contractLineItem_list);
           List<Id> cli_Id_List = new List<Id>();
   
           for(Object obj : contractLineItem_list)
           {
               System.debug('obj'+obj);
               Map<String, Object> contractLineItemId_map = (Map<String, Object>)obj;
               system.debug('contractLineItemId_map.values()'+contractLineItemId_map.values());
               system.debug('contractLineItemId_map.keyset()'+contractLineItemId_map.keyset());
               Object contractLineItemId = contractLineItemId_map.get('Contract_Line_Item_Id');
               System.debug('contractLineItemId'+contractLineItemId);
               cli_Id_List.add((Id)contractLineItemId);        
           }
           
           System.debug('cli_Id_List'+cli_Id_List);
   
           try{
               if(process_Name == 'Cancelled')
               {   
                   system.debug('In Cancelled');
                   Database.executeBatch(new SWAN_updateSPStatusCancelledBatch(cli_Id_List,UserInfo.getUserId(),process_Name),1000);
               }
               else if(process_Name == 'Termination')
               {   
                   system.debug('In termination');
                   Database.executeBatch(new SWAN_updateSPStatusCancelledBatch(cli_Id_List,UserInfo.getUserId(),final_status,terminatedEndDateTime,process_Name),1000);
               } 
               return true;  
           }
           catch(exception e){
               return false;
           } 
       }
   
       global Boolean updateSelectedServicePointStatus(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
          // System.debug('entered new method');
           String process_Name = String.ValueOf(inputMap.get('Processname'));
           String final_status = String.ValueOf(inputMap.get('FinalStatus'));
           String terminatedEndDateTime = String.ValueOf(inputMap.get('TerminatedEndDateTime'));
           List<Object> contractLineItem_list= (List<Object>)inputMap.get('SelectedSpsJson');
          // System.debug(contractLineItem_list);
       
          System.debug('Processname: ' + process_Name);
          System.debug('final_status: ' + final_status);
          System.debug('TerminatedEndDateTime: ' + terminatedEndDateTime);
          System.debug('contractLineItem_list: ' + contractLineItem_list.size());
   
           system.debug('contractLineItem_list debuggg'+contractLineItem_list);
           List<Id> cli_Id_List = new List<Id>();
           for(Object obj : contractLineItem_list)
           {
               System.debug('obj'+obj);
               Map<String, Object> contractLineItemId_map = (Map<String, Object>)obj;
               system.debug('contractLineItemId_map.values()'+contractLineItemId_map.values());
               system.debug('contractLineItemId_map.keyset()'+contractLineItemId_map.keyset());
               Object contractLineItemId = contractLineItemId_map.get('Contract_Line_Item_Id');
               System.debug('contractLineItemId'+contractLineItemId);
               cli_Id_List.add((Id)contractLineItemId);        
           }
           System.debug('cli_Id_List'+cli_Id_List);
           try{
                   if(process_Name == 'Cancelled')
                   {   
                       system.debug('In Cancelled');
                       Database.executeBatch(new SWAN_updateSPStatusCancelledBatch(cli_Id_List,UserInfo.getUserId(),process_Name),1000);
                   }
                   else if(process_Name == 'Termination')
                   {   
                       system.debug('In termination');
                       Database.executeBatch(new SWAN_updateSPStatusCancelledBatch(cli_Id_List,UserInfo.getUserId(),final_status,terminatedEndDateTime,process_Name),1000);
                   } 
                   return true;  
               }
               catch(exception e){
                   return false;
               } 
           }
   }