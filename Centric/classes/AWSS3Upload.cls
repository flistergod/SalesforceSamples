global with sharing class AWSS3Upload implements vlocity_cmt.VlocityOpenInterface {
 global Boolean invokeMethod(String methodName,
    Map < String, Object > input,
    Map < String, Object > output,
    Map < String, Object > options) {
    
    system.debug('In AWSS3Upload:=' + methodName);
        
    switch on methodName{
       when 'uploadCSVFileToS3'{
          return uploadCSVFileToS3(input, output, options);
       }
       when 'CreateMeterListFile'{
          return CreateMeterListFile(input, output, options);
       }
       when 'UploadFile'{
          return UploadFile(input, output, options);
       }  
       when 'UpdateQuoteCalculationId'{
          return UpdateQuoteCalculationId(input, output, options);
       }
       when 'CreateMeterListFile_Elec'{
          return CreateMeterListFile_Elec(input, output, options);
       }
       when 'apiBatchRequestElec'{
            return apiBatchRequestElec(input, output, options);
        }
       when 'CreateMeterListFile_HF'{
            return CreateMeterListFile_HF(input, output, options);
        }                        
    }
    return false;
 }

public Boolean uploadCSVFileToS3 (Map < String, Object > input,Map < String, Object > output,Map < String, Object > options) {
  try{
  
      system.debug('Begin AWSS3Upload:uploadCSVFileToS3');
      
      // set the connection parameters
      String formattedDateString = Datetime.now().format('EEE, dd MMM yyyy HH:mm:ss'); // Timestamp format of the file
      String requestType = 'PUT'; // The HTTP Request Type
      String contentType = 'text/csv'; // File Type


      // Get inputs
      String fileType = (string)input.get('strUploadFileType'); // Get File Type
      
      String filePath = (string)input.get('strUploadURL'); // Get File Name
            
      string csvFileHeader = '';
      string csvFileMPRN = '';

      //System.debug('In FILEUPLOAD: ' + (string)input.get('QuoteId'));
      // Create HTTP request
      HttpRequest req = new HttpRequest();
            system.debug('AWSS3Upload:uploadCSVFileToS3 fileType: '+fileType);

      if(fileType.equalsIgnoreCase('MeterListFile')){
          CreateMeterListFile(input,output,options);
      }
      if(fileType.equalsIgnoreCase('MeterListFileElec')){
          CreateMeterListElecFile(input,output,options);
      }
      if(fileType.equalsIgnoreCase('ClipStructureElecFlex')){
          createClipStructureCSV(input,output,options);
      }
      system.debug('End AWSS3Upload:uploadCSVFileToS3. fileType: '+fileType);

      
  } catch(System.CalloutException e) {
      system.debug('AWSS3Upload Callout Exception: ' + e.getMessage());
      system.debug('AWSS3Upload Callout Exception: ' + e.getCause());
      system.debug('AWSS3Upload Exception: ' + e.getStackTraceString());
  } catch(Exception e) {
      system.debug('AWSS3Upload Exception: ' + e.getMessage());
      system.debug('AWSS3Upload Exception: ' + e.getStackTraceString());
  }
return true;
}
public Boolean CreateMeterListFile (Map < String, Object > input,Map < String, Object > output,Map < String, Object > options) {
  try{
      
      system.debug('Begin AWSS3Upload:CreateMeterListFile'+input);
      
      system.debug('hahahaha'+input.get('JsonNewOLI'));
      Map<String,Object> opMap = (Map<string,object>)input.get('JsonNewOLI');// added by SPAL 11 JUNE 2020 
      /***** Commented by SPAL 11 JUNE 2020 [START]*******
      String objectString = String.ValueOf(input.get('JsonNewOLI'));
      Map<String,Object> opMap = new Map<String,Object>();
      
      if(objectString.Contains('('))
      {
         system.debug('List json object');
         for(Object obj : (List<Object>)input.get('JsonNewOLI'))
          {
              MAP<String,Object> objMap = (MAP<String,Object>) obj;
              opMap.put((string)objMap.get('ServicePointId') ,objMap);
          }
      }
      else
      {
          MAP<String,Object> objMap = (MAP<String,Object>) input.get('JsonNewOLI');
          opMap.put((string)objMap.get('ServicePointId') ,objMap);
          system.debug('single json object');
      }
      ************Commented by SPAL 11 JUNE 2020 [END]***********/
      
      // set the connection parameters
      String formattedDateString = Datetime.now().format('EEE, dd MMM yyyy HH:mm:ss'); // Timestamp format of the file
      String requestType = 'PUT'; // The HTTP Request Type
      String contentType = 'text/csv'; // File Type


      // Get inputs
      String fileType = (string)input.get('strUploadFileType'); // Get File Type
      String filePath = (string)input.get('strUploadURL'); // Get File Name
          
      string csvFileHeader = '';
      string csvFileMPRN = '';
      string csvFileUpload = '';

 
      // Generate the file
      
      String sQuoteId = (String)input.get('QuoteId');
      csvFileHeader = 'mprn,exit_zone,local_distribution_zone,product_class,rolling_supply_offtake_quantity,formula_year_supply_offtake_quantity,formula_year_annual_quantity,rolling_annual_quantity,transporter,automated_meter_reads,automated_meter_reads_provider,data_logger,data_corrector,meter_asset_manager,end_user_category,supply_start_date,supply_end_date,perspective_date,perspective_aq,perspective_soq,csep_development_soq,dcc_status,imperial_indicator,meter_type,meter_serial_number,meter_capacity,csep_id,smso_id,interruption_contract_exists,twin_stream_indicator,igt_transporter_rate,igt_transporter_rate_type,customer_euc,customer_aq,customer_soq,customer_aq_start_date,customer_aq_end_date';        

      csvFileUpload = csvFileHeader;
      
      if (!Schema.sObjectType.Quote.isAccessible()) { return false; }        
      for(Quote qt:[select vlocity_cmt__DefaultServicePointId__c,SWAN_Service_Point_Start_Date__c,SWAN_Service_Point_End_Date__c,
          vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__ServicePointNumber__c,vlocity_cmt__DefaultServicePointId__r.SWAN_Exit_Zone__c,
          vlocity_cmt__DefaultServicePointId__r.SWAN_Local_Distribution_Zone__c,vlocity_cmt__DefaultServicePointId__r.SWAN_Product_Class__c,
          vlocity_cmt__DefaultServicePointId__r.SWAN_Supply_Offtake_Quantity__c,vlocity_cmt__DefaultServicePointId__r.SWAN_Formula_Year_Offtake_Quantity__c,
          vlocity_cmt__DefaultServicePointId__r.SWAN_Formula_Year_Annual_Quantity__c,vlocity_cmt__DefaultServicePointId__r.Annual_Quantity__c,
          vlocity_cmt__DefaultServicePointId__r.SWAN_Transporter_Calc__c,vlocity_cmt__DefaultServicePointId__r.SWAN_AMR_Indicator__c,
          vlocity_cmt__DefaultServicePointId__r.SWAN_AMR_Service_Provider__c,vlocity_cmt__DefaultServicePointId__r.SWAN_Data_Logger__c,
          vlocity_cmt__DefaultServicePointId__r.SWAN_Corrector__c,vlocity_cmt__DefaultServicePointId__r.SWAN_Meter_Asset_Manager__c,
          vlocity_cmt__DefaultServicePointId__r.SWAN_End_User_Category_Code__c,vlocity_cmt__DefaultServicePointId__r.SWAN_Perspective_FY_Effective_Date__c,
          vlocity_cmt__DefaultServicePointId__r.SWAN_Perspective_FY_Annual_Quantity__c,vlocity_cmt__DefaultServicePointId__r.SWAN_Perspective_FY_Offtake_Qty__c,
          vlocity_cmt__DefaultServicePointId__r.SWAN_CSEP_Development_SOQ__c,vlocity_cmt__DefaultServicePointId__r.SWAN_DCC_Service_Flag__c,
          vlocity_cmt__DefaultServicePointId__r.SWAN_Imperial_Indicator__c,vlocity_cmt__DefaultServicePointId__r.SWAN_Meter_Type__c,
          vlocity_cmt__DefaultServicePointId__r.SWAN_Meter_Serial_Number__c,vlocity_cmt__DefaultServicePointId__r.SWAN_Meter_Capacity__c,
          vlocity_cmt__DefaultServicePointId__r.SWAN_CSEP_Id__c,vlocity_cmt__DefaultServicePointId__r.SWAN_SMSO_ID__c,
          vlocity_cmt__DefaultServicePointId__r.SWAN_Interruption_Contract_Exists__c,vlocity_cmt__DefaultServicePointId__r.SWAN_Twin_Stream_indicator__c,
          vlocity_cmt__DefaultServicePointId__r.SWAN_IGT_Transportation_Rate__c,vlocity_cmt__DefaultServicePointId__r.SWAN_IGT_Transportation_Rate_Type__c from 
          Quote where vlocity_cmt__ParentQuoteId__c =: sQuoteId AND RecordType.DeveloperName != 'GroupCart' AND vlocity_cmt__DefaultServicePointId__c != null])
      {
          String sServicePointId = qt.vlocity_cmt__DefaultServicePointId__c;
          Date sStartDate = qt.SWAN_Service_Point_Start_Date__c; 
          Date sEndDate = qt.SWAN_Service_Point_End_Date__c; 
          
          if (!Schema.sObjectType.vlocity_cmt__ServicePoint__c.isAccessible()) { return false; } 
          if(qt.vlocity_cmt__DefaultServicePointId__c != null)
          {
               String smprn = qt.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__ServicePointNumber__c;
               String sexit_zone = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Exit_Zone__c;
               String slocal_distribution_zone = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Local_Distribution_Zone__c;
               String sproduct_class = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Product_Class__c;
               Double srolling_supply_offtake_quantity = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Supply_Offtake_Quantity__c;
               Double sformula_year_supply_offtake_quantity = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Formula_Year_Offtake_Quantity__c;
               Double sformula_year_annual_quantity = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Formula_Year_Annual_Quantity__c;
               Double srolling_annual_quantity = qt.vlocity_cmt__DefaultServicePointId__r.Annual_Quantity__c;
               String stransporter = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Transporter_Calc__c;
               Boolean bautomated_meter_reads = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_AMR_Indicator__c;
               String sautomated_meter_reads_provider = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_AMR_Service_Provider__c;
               String sautomated_meter_reads_type = 'Logger'; // Still ned to be mapped
               String sdata_logger = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Data_Logger__c;
               Boolean bdata_corrector = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Corrector__c; 
               String smeter_asset_manager = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Meter_Asset_Manager__c; 
               String send_user_category = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_End_User_Category_Code__c; 
               Date dsupply_start_date = sStartDate; 
               Date dsupply_end_date = sEndDate;
               Date dperspective_date = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Perspective_FY_Effective_Date__c;
               Double dperspective_aq = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Perspective_FY_Annual_Quantity__c;
               Double dperspective_soq = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Perspective_FY_Offtake_Qty__c;
               Double dcsep_development_soq = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_CSEP_Development_SOQ__c;
               String sdcc_status = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_DCC_Service_Flag__c;
               Boolean bimperial_indicator = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Imperial_Indicator__c;
               String smeter_type = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Meter_Type__c;
               String smeter_serial_number = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Meter_Serial_Number__c;
               Double fmeter_capacity = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Meter_Capacity__c;
               //Double fmeter_capacity;
               String scsep_id = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_CSEP_Id__c;
               String ssmso_id = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_SMSO_ID__c;
               Boolean binterruption_contract_exists = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Interruption_Contract_Exists__c;
               Boolean btwin_stream_indicator = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Twin_Stream_indicator__c;
               Double digt_transporter_rate = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_IGT_Transportation_Rate__c;
               String sigt_transporter_rate_type = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_IGT_Transportation_Rate_Type__c ;
               String Cus_EUC = '';
               Integer Cus_AQ ;
               Integer Cus_SOQ;
               Date Cust_AQ_StartDate;
               Date Cust_AQ_EndDate;
               
               Integer matchCount =0;
               String meterNumber = '';
               Integer startIndex ;
               Integer stopIndex ;
               if(smeter_serial_number != null)
               {
                    for(integer i=0; i< smeter_serial_number.length();i++)
                    {
                        if(smeter_serial_number.substring(i,i+1).isAlpha())
                        {
                            matchCount++;
                            if(matchCount == 1)
                            {
                              startIndex = i;
                            }
                            
                            if(matchCount == 2)
                            {
                                stopIndex = i;
                                break;
                            }
                        }
                    }
                    if(startIndex != null && stopIndex != null)
                    meterNumber = smeter_serial_number.substring(startIndex,stopIndex+1);
               }
               
               if(opMap.containsKey(qt.vlocity_cmt__DefaultServicePointId__c))
               {
                  Map<String,object> objAt = (Map<String,Object>)opMap.get(qt.vlocity_cmt__DefaultServicePointId__c);
                  System.debug('we found sp'+objAt.get('CustomerAQ'));
                  if(!String.isBlank(String.ValueOf(objAt.get('SWAN_ATT_CUST_AQ'))))//CustomerAQ    // Changed by SPAL 11 JUNE 2020
                  {
                    Cus_AQ = Integer.ValueOf(objAt.get('SWAN_ATT_CUST_AQ'));//CustomerAQ    // Changed by SPAL 11 JUNE 2020
                  }
                  if(!String.isBlank(String.ValueOf(objAt.get('SWAN_ATT_CUST_EFF_FROM'))))//EFD    // Changed by SPAL 11 JUNE 2020
                  {
                    String stdate = String.ValueOf(objAt.get('SWAN_ATT_CUST_EFF_FROM'));//EFD    // Changed by SPAL 11 JUNE 2020
                    system.debug('sssss='+stdate);
                    Cust_AQ_StartDate = Date.ValueOf(stdate);
                  }
                  if(!String.isBlank(String.ValueOf(objAt.get('SWAN_ATT_CUST_EFF_TO'))))//ETD    // Changed by SPAL 11 JUNE 2020
                  {
                  
                    String etdate = String.ValueOf(objAt.get('SWAN_ATT_CUST_EFF_TO'));//ETD    // Changed by SPAL 11 JUNE 2020
                    system.debug('sssss='+etdate);
                    Cust_AQ_EndDate = Date.ValueOf(etdate);
                  }
                  
                  if(!String.isBlank(String.ValueOf(objAt.get('SWAN_ATT_CUST_SOQ'))))//SOQ    // Changed by SPAL 11 JUNE 2020
                  {
                    Cus_SOQ = Integer.ValueOf(objAt.get('SWAN_ATT_CUST_SOQ'));//SOQ    // Changed by SPAL 11 JUNE 2020
                  }
                  
                  if(!String.isBlank(String.ValueOf(objAt.get('SWAN_ATT_CUST_EUC'))))//EUC    // Changed by SPAL 11 JUNE 2020
                  {
                    Cus_EUC = String.ValueOf(objAt.get('SWAN_ATT_CUST_EUC'));//EUC    // Changed by SPAL 11 JUNE 2020
                  }
               }
               String cbtwin_stream_indicator = (string.valueOf(btwin_stream_indicator)).toUpperCase();
               String cbinterruption_contract_exists  = (string.valueOf(binterruption_contract_exists)).toUpperCase();
               String cbdata_corrector  = (string.valueOf(bdata_corrector)).toUpperCase();
               String cbautomated_meter_reads = (string.valueOf(bautomated_meter_reads)).toUpperCase();
               String cbimperial_indicator = (string.valueOf(bimperial_indicator)).toUpperCase(); 
               //String cbdata_logger = (string.valueOf(bdata_logger)).toUpperCase();           
               
               
               csvFileMPRN = smprn + ',' + sexit_zone + ',' + slocal_distribution_zone + ',' + sproduct_class + ',' + srolling_supply_offtake_quantity + ',' + sformula_year_supply_offtake_quantity + ',' + sformula_year_annual_quantity + ',' + srolling_annual_quantity + ',' + stransporter + ',' + cbautomated_meter_reads + ',' + sautomated_meter_reads_provider + ',' + sdata_logger + ',' + cbdata_corrector + ',' + smeter_asset_manager + ',' + send_user_category + ',' + dsupply_start_date + ',' + dsupply_end_date + ',' + dperspective_date + ',' + dperspective_aq + ',' + dperspective_soq + ',' + dcsep_development_soq + ',' + sdcc_status + ',' + cbimperial_indicator + ',' + smeter_type + ',' + meterNumber + ',' + fmeter_capacity + ',' + scsep_id + ',' + ssmso_id + ',' + cbinterruption_contract_exists + ',' + cbtwin_stream_indicator + ',' + digt_transporter_rate + ',' + sigt_transporter_rate_type+','+Cus_EUC+','+Cus_AQ+','+Cus_SOQ+','+Cust_AQ_StartDate+','+Cust_AQ_Enddate;

               csvFileUpload = csvFileUpload + '\r\n' + csvFileMPRN;
               System.debug('FILEUPLOAD METER LIST MPRN: ' + csvFileMPRN);
               System.debug('FILEUPLOAD METER LIST CURRENT: ' + csvFileUpload);
          }
      }
     
      System.debug('FILEUPLOAD METER LIST FINAL Quote Id: ' + sQuoteId);
      System.debug('FILEUPLOAD METER LIST FINAL: ' + csvFileUpload);
            
      input.put('filePath',filePath);
      input.put('csvFileUpload',csvFileUpload);
      
      UploadFile(input,output,options); 
      
      system.debug('End AWSS3Upload:CreateMeterListFile');    
         
  } catch(System.CalloutException e) {
      system.debug('AWS Service Callout Exception: ' + e.getMessage());
      system.debug('AWS Service Callout Exception: ' + e.getCause());
      system.debug('Exception: ' + e.getStackTraceString());
  } catch(Exception e) {
      system.debug('Exception: ' + e.getMessage());
      system.debug('Exception: ' + e.getStackTraceString());
  }
    return true;
}

public Boolean CreateMeterListElecFile (Map < String, Object > input,Map < String, Object > output,Map < String, Object > options) {
  try{    
      String formattedDateString = Datetime.now().format('EEE, dd MMM yyyy HH:mm:ss'); // Timestamp format of the file
      String requestType = 'PUT'; // The HTTP Request Type
      String contentType = 'text/csv'; // File Type


      // Get inputs
      String fileType = (string)input.get('strUploadFileType'); // Get File Type
      String filePath = (string)input.get('strUploadURL'); // Get File Name
          
      string csvFileHeader = '';
      string csvFileMPAN = '';
      string csvFileUpload = '';
      
      Map<String,Object> opMap = (Map<string,object>)input.get('JsonNewEAC');
      Map<String,Object> rsMap = (Map<string,object>)input.get('JsonRateStru');
      // Generate the file
      
      String sQuoteId = (String)input.get('QuoteId');
      
      csvFileHeader = 'mpan,distributor_id,distributor_market_participant_id,gsp_group_id,line_loss_factor_class,dcc_service_flag,green_deal_in_effect,profile_class,standard_settlement_configuration,meter_timeswitch_class,measurement_class,data_aggregator_market_participant_id,data_collector_market_participant_id,meter_operator_market_participant_id,smart_metering_system_operator_market_participant_id,in_house_display_status,smets_version,metered_indicator,consumer_type,rmp_state,supply_start_date,supply_end_date,pricing_structure,customer_eac,agreed_supply_capacity,business_use_at_meter,meter_relationship,primary_meter,smart_metering_indicator,read_frequency,meter_asset_provider_market_participant_id';        

      csvFileUpload = csvFileHeader;
      
      if (!Schema.sObjectType.Quote.isAccessible()) { return false; }        
      for(Quote qt:[select vlocity_cmt__DefaultServicePointId__c,SWAN_Service_Point_Start_Date__c,SWAN_Service_Point_End_Date__c,SWAN_Pricing_Structure__c,vlocity_cmt__DefaultServicePointId__r.SWAN_smart_metering_indicator__c,
          vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__ServicePointNumber__c,vlocity_cmt__DefaultServicePointId__r.SWAN_Distributor_Id__c ,
          vlocity_cmt__DefaultServicePointId__r.SWAN_Distributor_ID_Ovrd__c,vlocity_cmt__DefaultServicePointId__r.SWAN_Grid_Supply_Point__c,
          vlocity_cmt__DefaultServicePointId__r.SWAN_Grid_Supply_Point_Group_Id_Ovrd__c,vlocity_cmt__DefaultServicePointId__r.SWAN_Line_Loss_Factor_Class__c,
          vlocity_cmt__DefaultServicePointId__r.SWAN_Line_Loss_Factor_Class_Ovrd__c,vlocity_cmt__DefaultServicePointId__r.SWAN_DCC_Service_Flag__c,
          vlocity_cmt__DefaultServicePointId__r.SWAN_green_deal_in_effect__c,vlocity_cmt__DefaultServicePointId__r.SWAN_Profile_Class__c,
          vlocity_cmt__DefaultServicePointId__r.SWAN_Profile_Class_Ovrd__c,vlocity_cmt__DefaultServicePointId__r.SWAN_Standard_Settlement_Configuration__c,
          vlocity_cmt__DefaultServicePointId__r.SWAN_Standard_Settlement_Config_Ovrd__c,vlocity_cmt__DefaultServicePointId__r.SWAN_Meter_Time_Switch_Code__c,
          vlocity_cmt__DefaultServicePointId__r.SWAN_Meter_Time_switch_Class_Ovrd__c,vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c,
          vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class_Ovrd__c,vlocity_cmt__DefaultServicePointId__r.SWAN_data_aggregator_mpid__c,
          vlocity_cmt__DefaultServicePointId__r.SWAN_distributor_mpid__c,vlocity_cmt__DefaultServicePointId__r.SWAN_data_collector_mpid__c,vlocity_cmt__DefaultServicePointId__r.SWAN_meter_operator_mpid__c,vlocity_cmt__DefaultServicePointId__r.SWAN_smso_mpid__c,vlocity_cmt__DefaultServicePointId__r.SWAN_ihd_status__c,vlocity_cmt__DefaultServicePointId__r.SWAN_smets_version__c,
          vlocity_cmt__DefaultServicePointId__r.SWAN_consumer_type__c,vlocity_cmt__DefaultServicePointId__r.SWAN_metered_indicator__c,vlocity_cmt__DefaultServicePointId__r.SWAN_rmp_state__c,vlocity_cmt__DefaultServicePointId__r.SWAN_Supply_Capacity__c,vlocity_cmt__DefaultServicePointId__r.SWAN_Meter_Relationship__c,vlocity_cmt__DefaultServicePointId__r.SWAN_map_mpid__c from 
          Quote where vlocity_cmt__ParentQuoteId__c =: sQuoteId AND RecordType.DeveloperName != 'GroupCart' AND vlocity_cmt__DefaultServicePointId__c != null])
      {
           Integer distId = Integer.valueOf(qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Distributor_Id__c);
           if(qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Distributor_ID_Ovrd__c != null)
           {
               distId = Integer.valueOf(qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Distributor_ID_Ovrd__c);
           }

           String gspGId = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Grid_Supply_Point__c;
           if(qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Grid_Supply_Point_Group_Id_Ovrd__c != null)
           {
               gspGId = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Grid_Supply_Point_Group_Id_Ovrd__c;
           }

           String llfC = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Line_Loss_Factor_Class__c;
           if(qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Line_Loss_Factor_Class_Ovrd__c != null)
           {
               llfC = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Line_Loss_Factor_Class_Ovrd__c;
           }

           String ssConf = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Standard_Settlement_Configuration__c;
           if(qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Standard_Settlement_Config_Ovrd__c != null)
           {
               ssConf = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Standard_Settlement_Config_Ovrd__c;
           }

           String mtSC = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Meter_Time_Switch_Code__c;
           if(qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Meter_Time_switch_Class_Ovrd__c != null)
           {
               mtSC = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Meter_Time_switch_Class_Ovrd__c;
           }

           String productClass = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Profile_Class__c;
           if(qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Profile_Class_Ovrd__c != null)
           {
               productClass = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Profile_Class_Ovrd__c;
           }

           String mcls = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c;
           Double supCap = null;
           String rateStruct= '';
           if(qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class_Ovrd__c != null)
           {
               mcls = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class_Ovrd__c;
               if(qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class_Ovrd__c == 'C' || qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class_Ovrd__c == 'E')
               {
                   supCap = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Supply_Capacity__c;
               }
               
               if((qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class_Ovrd__c != 'A' || qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class_Ovrd__c != 'B') && rsMap.containsKey(qt.vlocity_cmt__DefaultServicePointId__c))
               {
                   Map<String,object> objAt = (Map<String,Object>)rsMap.get(qt.vlocity_cmt__DefaultServicePointId__c);
                  if(!String.isBlank(String.ValueOf(objAt.get('SWAN_ATT_HH_RATE_STRUCT'))))//QLIRateStr   
                  {
                    rateStruct = String.ValueOf(objAt.get('SWAN_ATT_HH_RATE_STRUCT'));//QLIRateStr
                  }
               }
           }
           else{
                if(qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c == 'C' || qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c == 'E')
               {
                   supCap = qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Supply_Capacity__c;
               }
               
               if((qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c != 'A' || qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c != 'B') && rsMap.containsKey(qt.vlocity_cmt__DefaultServicePointId__c))
               {
                   Map<String,object> objAt = (Map<String,Object>)rsMap.get(qt.vlocity_cmt__DefaultServicePointId__c);
                  if(!String.isBlank(String.ValueOf(objAt.get('SWAN_ATT_HH_RATE_STRUCT'))))//QLIRateStr   
                  {
                    rateStruct = String.ValueOf(objAt.get('SWAN_ATT_HH_RATE_STRUCT'));//QLIRateStr
                  }
               }
           }
           
           Double custEAC = null;
            if(opMap.containsKey(qt.vlocity_cmt__DefaultServicePointId__c))
               {
                  Map<String,object> objAt = (Map<String,Object>)opMap.get(qt.vlocity_cmt__DefaultServicePointId__c);
                  if(!String.isBlank(String.ValueOf(objAt.get('SWAN_ATT_CUST_EAC'))))//CustomerEAC   
                  {
                    custEAC = Double.ValueOf(objAt.get('SWAN_ATT_CUST_EAC'));//CustomerEAC
                  }
               }
           
           //system.debug('=====qt.vlocity_cmt__DefaultServicePointId__r.SWAN_map_mpid__c'+ qt.vlocity_cmt__DefaultServicePointId__r.SWAN_map_mpid__c);
           csvFileMPAN =qt.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__ServicePointNumber__c+','+distId+','+qt.vlocity_cmt__DefaultServicePointId__r.SWAN_distributor_mpid__c+','+gspGId+','+llfC+','+qt.vlocity_cmt__DefaultServicePointId__r.SWAN_DCC_Service_Flag__c+','+qt.vlocity_cmt__DefaultServicePointId__r.SWAN_green_deal_in_effect__c+','+productClass+','+ssConf+','+mtSC+','+mcls+','+qt.vlocity_cmt__DefaultServicePointId__r.SWAN_data_aggregator_mpid__c+','+qt.vlocity_cmt__DefaultServicePointId__r.SWAN_data_collector_mpid__c+','+qt.vlocity_cmt__DefaultServicePointId__r.SWAN_meter_operator_mpid__c+','+qt.vlocity_cmt__DefaultServicePointId__r.SWAN_smso_mpid__c+','+qt.vlocity_cmt__DefaultServicePointId__r.SWAN_ihd_status__c+','+qt.vlocity_cmt__DefaultServicePointId__r.SWAN_smets_version__c+','+qt.vlocity_cmt__DefaultServicePointId__r.SWAN_metered_indicator__c+','+qt.vlocity_cmt__DefaultServicePointId__r.SWAN_consumer_type__c+','+qt.vlocity_cmt__DefaultServicePointId__r.SWAN_rmp_state__c+','+qt.SWAN_Service_Point_Start_Date__c+','+qt.SWAN_Service_Point_End_Date__c+','+rateStruct+','+custEAC+','+supCap+','+''+','+qt.vlocity_cmt__DefaultServicePointId__r.SWAN_Meter_Relationship__c+','+qt.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__ServicePointNumber__c+','+qt.vlocity_cmt__DefaultServicePointId__r.SWAN_smart_metering_indicator__c+','+''+','+qt.vlocity_cmt__DefaultServicePointId__r.SWAN_map_mpid__c;
           
           csvFileUpload = csvFileUpload + '\r\n' + csvFileMPAN;
        }
         System.debug('FILEUPLOAD METER LIST FINAL: ' + csvFileUpload);
            
          input.put('filePath',filePath);
          input.put('csvFileUpload',csvFileUpload);
          
          UploadFile(input,output,options); 
          SWAN_Status_Log__c st = new SWAN_Status_Log__c();
          st.SWAN_DatacomponentId__c = String.valueOf(input.get('DataComponentId'));
          st.SWAN_Process_Name__c = 'Elec';
          st.SWAN_Record_Id__c = sQuoteId;
          insert st;
          
          system.debug('End AWSS3Upload:CreateMeterListFile');    
         
      
  }
   catch(Exception e) {
      system.debug('Exception: ' + e.getMessage());
      system.debug('Exception: ' + e.getStackTraceString());
  }
  return true;
}


public Boolean UploadFile (Map < String, Object > input,Map < String, Object > output,Map < String, Object > options) {
    try{
        
        system.debug('Begin AWSS3Upload:UploadFile');
        
        // set the connection parameters
        String formattedDateString = Datetime.now().format('EEE, dd MMM yyyy HH:mm:ss'); // Timestamp format of the file
        String requestType = 'PUT'; // The HTTP Request Type
        String contentType = 'text/csv'; // File Type

        // Get inputs
        String fileType = (string)input.get('strUploadFileType'); // Get File Type
        String filePath = (string)input.get('strUploadURL'); // Get File Name
        String sFilePath = (string)input.get('filePath');
        String scsvFileUpload = (string)input.get('csvFileUpload');
        
        //   Integer delayInMilliseconds = Integer.valueOf(sdelayInMilliseconds); // Set Publish delay
        
        string csvFileHeader = '';
        string csvFileMPRN = '';
        string csvFileUpload = '';

        // Create HTTP request
        HttpRequest req = new HttpRequest();
        
        // Set the file request details
        req.setMethod(requestType);      
        req.setEndpoint(FilePath);
        req.setHeader('Content-Length', String.valueOf(csvFileUpload.length()));
        req.setHeader('Content-Type', contentType);
        req.setHeader('Date', formattedDateString);
        req.setHeader('ACL', 'public-read-write');
        Blob CSV = Blob.valueof(scsvFileUpload);
        req.setBodyAsBlob(CSV);

        Http http = new Http();
        //Send the file upload request and debug the response / check for exceptions
        HTTPResponse res = http.send(req);

        System.debug('RESPONSE STRING: ' + res.toString());
        System.debug('RESPONSE STATUS: ' + res.getStatus());
        System.debug('STATUS_CODE: ' + res.getStatusCode());
        
        system.debug('End AWSS3Upload:UploadFile');
        
    } catch(System.CalloutException e) {
        system.debug('AWS Service Callout Exception: ' + e.getMessage());
        system.debug('AWS Service Callout Exception: ' + e.getCause());
        system.debug('Exception: ' + e.getStackTraceString());
    } catch(Exception e) {
        system.debug('Exception: ' + e.getMessage());
        system.debug('Exception: ' + e.getStackTraceString());
    }
    return true;
    }

public Boolean UpdateQuoteCalculationId (Map < String, Object > input,Map < String, Object > output,Map < String, Object > options) {
  try{
      
      system.debug('Begin AWSS3Upload:UpdateQuoteCalculationId');
      
      String fuelType = (input.get('FuelType')!=null?(string)input.get('FuelType'):'');
      String sCalculationId = (string)input.get('strCalculationId'); // Get Calculation Id
      String sDataCompId = (string)input.get('data_component_id'); // Get Calculation Id
      String sContractParamId = (string)input.get('strContractParamId'); // Get Contract Level Parameter Id
      String sMeterParamId = (string)input.get('strMeterParamId'); // Get Meter Level Parameter Id
      String sCommodityCalculationId = (string)input.get('strCommodityCalculationId'); // Get Meter Level Parameter Id
      Integer iCommodityVersionId = (Integer)input.get('strCommodityVersionId'); // Get Meter Level Parameter Id
      String sCostResultsId = (string)input.get('strCostResultsId'); // Get Cost Resultsl Parameter Id
      String sMeterListId = (string)input.get('strMeterListId'); // Get Cost Resultsl Parameter Id
	  String strVolumeSummaryParamId = (string)input.get('strVolumeSummaryParamId'); // Get Volume Summary Parameter Id
      
      String sQuoteId = (string)input.get('strQuoteId'); // Get Master Quote Id
      
      //Update Master Quote Calculation Id
      system.debug('AWSS3Upload Calculation Id: ' + sCalculationId);
      system.debug('AWSS3Upload Quote Id: ' + sQuoteId); 
       if (!Schema.sObjectType.Quote.isAccessible()) { return false; }
      Quote oMasterQuote = [Select Id,SWAN_Pricing_Calculation_Id__c from Quote where Id =: sQuoteId];

      oMasterQuote.SWAN_Pricing_Calculation_Id__c = sCalculationId;
      oMasterQuote.SWAN_Contract_Level_Param_Id__c = sContractParamId;
      oMasterQuote.SWAN_Meter_Level_Param_Id__c = sMeterParamId;
	  oMasterQuote.SWAN_Volume_Summary_Param_Id__c = strVolumeSummaryParamId;
      oMasterQuote.SWAN_Calculation_Commodity_Id__c = sCommodityCalculationId; 
      oMasterQuote.SWAN_Calculation_Commodity_Version__c = iCommodityVersionId;
      oMasterQuote.SWAN_Cost_Results_Id__c = sCostResultsId;
      oMasterQuote.SWAN_Meter_List_Id__c = sMeterListId;
      if (!Schema.sObjectType.Quote.fields.SWAN_Meter_Level_Param_Id__c.isUpdateable()) { return false; }
      update oMasterQuote;     
      
      if(fuelType == 'Electricity' && sDataCompId != null && sDataCompId != '')
      {
          List<SWAN_Status_Log__c> statusLog = [Select id,SWAN_WorkflowId__c from SWAN_Status_Log__c where SWAN_DatacomponentId__c=:sDataCompId limit 1];
          if(statusLog != null && statusLog.size() > 0)
              statusLog[0].SWAN_WorkflowId__c = sCalculationId;
          update statusLog;
      }
      
      system.debug('End AWSS3Upload:UpdateQuoteCalculationId');
      
      
  } catch(System.CalloutException e) {
      system.debug('AWS Service Callout Exception: ' + e.getMessage());
      system.debug('AWS Service Callout Exception: ' + e.getCause());
      system.debug('Exception: ' + e.getStackTraceString());
  } catch(Exception e) {
      system.debug('Exception: ' + e.getMessage());
      system.debug('Exception: ' + e.getStackTraceString());
  }
return true;
}
 //MDD validation call :- DM 
 public Boolean CreateMeterListFile_Elec (Map < String, Object > input,Map < String, Object > output,Map < String, Object > options) {
        try{
            
            system.debug('Begin AWSS3Upload:CreateMeterListFile'+input);
            
            
            // Generate the file
             List<String> servPointIds = new List<String>();
             if(input.get('servicePointId') == null || input.get('servicePointId') == '')
             {
                for(Object obj : (List<object>)input.get('servicePointList'))
                  {
                      servPointIds.add(String.valueOf(obj));
                  }
             }
             else
             {
                 servPointIds.add(string.valueOf(input.get('servicePointId')));
             }
             
             string csvFileUpload = parseCSVElec(servPointIds);
            input.put('csvFileUpload',csvFileUpload);
            
            if(csvFileUpload != '')
            {
             UploadFile(input,output,options);  
             SWAN_Status_Log__c st = new SWAN_Status_Log__c();
             st.SWAN_DatacomponentId__c = String.valueOf(input.get('DataComponentId'));
             st.SWAN_Process_Name__c = string.valueOf(input.get('ProcessName'));
             st.SWAN_Record_Id__c = string.valueOf(input.get('RecordId'));
             st.OwnerId = string.valueOf(input.get('UserId'));
             insert st;
            }
            
        } catch(System.CalloutException e) {
            system.debug('AWS Service Callout Exception: ' + e.getMessage());
            system.debug('AWS Service Callout Exception: ' + e.getCause());
            system.debug('Exception: ' + e.getStackTraceString());
        } catch(Exception e) {
            system.debug('Exception: ' + e.getMessage());
            system.debug('Exception: ' + e.getStackTraceString());
        }
        return true;
    }
    
  public string parseCSVElec(List<String> servPointIds)
    {
        string csvFileHeader = '';
        string csvFileMPRN = '';
        string csvFileUpload = '';
        Boolean recordsCheck = false;
        
        csvFileHeader = 'mpan,distributor_id,gsp_group_id,line_loss_factor_class,profile_class,standard_settlement_configuration,meter_timeswitch_class,measurement_class';        
            
        csvFileUpload = csvFileHeader;
      
                
                for(vlocity_cmt__ServicePoint__c serPoint :[select id, 
                                                            SWAN_Distributor_Id__c,SWAN_Distributor_ID_Ovrd__c, 
                                                            SWAN_Measurement_Class__c, SWAN_Measurement_Class_Ovrd__c,
                                                            vlocity_cmt__ServicePointNumber__c,
                                                            SWAN_Grid_Supply_Point__c, SWAN_Grid_Supply_Point_Group_Id_Ovrd__c,
                                                            SWAN_Line_Loss_Factor_Class__c, SWAN_Line_Loss_Factor_Class_Ovrd__c,
                                                            SWAN_Profile_Class__c, SWAN_Profile_Class_Ovrd__c,
                                                            SWAN_Standard_Settlement_Configuration__c,SWAN_Standard_Settlement_Config_Ovrd__c, 
                                                            SWAN_Meter_Time_Switch_Code__c, SWAN_Meter_Time_switch_Class_Ovrd__c, 
                                                            SWAN_ECOES_Issue__c from vlocity_cmt__ServicePoint__c where Id in :servPointIds AND SWAN_ECOES_Issue__c = false] ){
                    
                    String smpan = serPoint.vlocity_cmt__ServicePointNumber__c;
                    String distributorId = String.valueOf(serPoint.SWAN_Distributor_Id__c);
                    String sgsp_group_id = serPoint.SWAN_Grid_Supply_Point__c;
                    String sline_loss_factor_class =  serPoint.SWAN_Line_Loss_Factor_Class__c;
                    String sprofile_class = serPoint.SWAN_Profile_Class__c;
                    String sstandard_settlement_configuration =  serPoint.SWAN_Standard_Settlement_Configuration__c ;
                    String smeter_timeswitch_class = serPoint.SWAN_Meter_Time_Switch_Code__c;
                    String measurementClass =  serPoint.SWAN_Measurement_Class__c ;
                    recordsCheck = true;
                    
                    csvFileMPRN = smpan + ',' + distributorId + ',' + sgsp_group_id + ',' + sline_loss_factor_class + ',' + sprofile_class + ',' + sstandard_settlement_configuration + ',' + smeter_timeswitch_class + ',' + measurementClass;
                    
                    csvFileUpload = csvFileUpload + '\r\n' + csvFileMPRN;
                    System.debug('FILEUPLOAD METER LIST MPRN: ' + csvFileMPRN);
                    System.debug('FILEUPLOAD METER LIST CURRENT: ' + csvFileUpload);
                }
            
           
            System.debug('FILEUPLOAD METER LIST FINAL: ' + csvFileUpload);
            if(recordsCheck)
            return csvFileUpload;
            else
            return '';
            
             
    }
    
    public Boolean CreateMeterListFile_HF(Map < String, Object > input,Map < String, Object > output,Map < String, Object > options)
    {
        try{
        string fileName = string.valueOf(input.get('FileName'));
        String csvBody = '';
        String custReportId = '';
        for(Attachment att : [Select id, body,ParentId from Attachment where name like : fileName+'%' order by CreatedDate])
        {
            csvBody = csvBody + att.body.toString();
            custReportId = att.ParentId;
            
        }
        if(!String.isEmpty(csvBody))
        {
            input.put('csvFileUpload',csvBody);
            UploadFile(input,output,options);
            SWAN_Status_Log__c st = new SWAN_Status_Log__c();
                 st.SWAN_DatacomponentId__c = String.valueOf(input.get('DataComponentId'));
                 st.SWAN_Process_Name__c = 'HnF Report';
                 insert st;
                 
             SWAN_Custom_Report__c custR = new SWAN_Custom_Report__c();
                 custR.Id = custReportId;
                 custR.Swan_Meter_List_Id__c = String.valueOf(input.get('DataComponentId'));
                 update custR;
        }
        } catch(Exception e) {
            system.debug('Exception: ' + e.getMessage());
        }
        
        
        return true;
    }
    
    public static Boolean apiBatchRequestElec(Map < String, Object > input,Map < String, Object > output,Map < String, Object > options){
      
        try{
            Integer numberOfRequests =0;
            Integer successfulAnswer=0;
            String hostName = String.valueOf(options.get('HostName'));
            String BrokerMarginPound    = String.valueOf(options.get('BrokerMarginPound'));
            String BrokerMarginPence    = String.valueOf(options.get('BrokerMarginPence'));
            String batchIdentifierToGorila ='batch_'+String.valueOf(options.get('DataComponentId'));
            String AuthorizationToken =(string)input.get('AuthorizationToken');
            String bodyDataReq = '';    

            for( String param : input.keySet() ){
                 if(param.indexOf('HTTPMethodPath') > 0  && param != 'AuthorizationToken' && 
                 param !='SetTransformSetBrokerMarginPoundHTTPMethodPath' && param !='SetTransformSetBrokerMarginPenceHTTPMethodPath' ){

                    String paramContent = param.split('HTTPMethodPath')[0];
                    String content =JSON.serialize(input.get(ParamContent));
                    String urlPath =param;
                    String bodyAPI ='--'+batchIdentifierToGorila+'\r\n'+
                                    'Content-Type: application/http\r\n\r\n\r\n'+
                                    input.get(urlPath) + '\r\n'+
                                    'Content-Type: application/json\r\n'+
                                    'Content-Length: '+ Blob.valueOf(content).size() +'\r\n\r\n'+
                                    content + '\r\n\r\n\r\n';
                    bodyDataReq = bodyDataReq +  bodyAPI;

                    numberOfRequests = numberOfRequests + 1;
                }

            }
              
            if(BrokerMarginPound != null && BrokerMarginPound !=''){
                String content =JSON.serialize(input.get('SetTransformSetBrokerMarginPound'));
                String bodyAPI ='--'+batchIdentifierToGorila+'\r\n'+
                                    'Content-Type: application/http\r\n\r\n\r\n'+
                                    input.get('SetTransformSetBrokerMarginPoundHTTPMethodPath') + '\r\n'+
                                    'Content-Type: application/json\r\n'+
                                    'Content-Length: '+ Blob.valueOf(content).size() +'\r\n\r\n'+
                                    content + '\r\n\r\n\r\n';
                    bodyDataReq = bodyDataReq +  bodyAPI;
                    numberOfRequests = numberOfRequests + 1;
            }
            
            if(BrokerMarginPence!=null && BrokerMarginPence!=''){
                String content =JSON.serialize(input.get('SetTransformSetBrokerMarginPence'));
                String bodyAPI ='--'+batchIdentifierToGorila+'\r\n'+
                                    'Content-Type: application/http\r\n\r\n\r\n'+
                                    input.get('SetTransformSetBrokerMarginPenceHTTPMethodPath') + '\r\n'+
                                    'Content-Type: application/json\r\n'+
                                    'Content-Length: '+ Blob.valueOf(content).size() +'\r\n\r\n'+
                                    content + '\r\n\r\n\r\n';
                    bodyDataReq = bodyDataReq +  bodyAPI;
                    numberOfRequests = numberOfRequests + 1;
            }

            HttpRequest req = new HttpRequest();
            req.setMethod('POST');      
            req.setEndpoint( (hostName + 'batch'));
            req.setHeader('Authorization', AuthorizationToken);
            req.setHeader('Content-Type', 'multipart/mixed; boundary='+batchIdentifierToGorila);
            req.setTimeout(20000);         
            bodyDataReq = bodyDataReq +  '--' + batchIdentifierToGorila + '--'; 
            req.setBody(bodyDataReq);
          
            Http http = new Http();
            HTTPResponse res = http.send(req);
            /*
            String[]  apiAwnser = (res.getBody()).split('--'+batchIdentifierToGorila) ;
            List<String> lstApiAnswer = new List<String>(apiAwnser);
             
            for(String awnser : lstApiAnswer){
                
                if(awnser.indexOf('HTTP/1.1 200') > 0  ){
                    successfulAnswer=successfulAnswer+1;
                }
            }
           
            output.put('SuccessfulUpdates' , successfulAnswer );
            output.put('UnSuccessfulUpdates' , (numberOfRequests-successfulAnswer) );
			*/
            //output.put('batchReponse' , res.getBody() );
        } catch(System.CalloutException e) {
            system.debug('AWS Service Callout Exception: ' + e.getMessage());
            output.put('Exception' , e.getMessage() );
        } catch(Exception e) {
            system.debug('Exception: ' + e.getMessage());
            system.debug('Exception: ' + e.getStackTraceString());
        }
        return true;
    }

    private Boolean createClipStructureCSV(Map < String, Object > input,Map < String, Object > output,Map < String, Object > options){
        try{
       
            String formattedDateString = Datetime.now().format('EEE, dd MMM yyyy HH:mm:ss'); // Timestamp format of the file
            String requestType = 'PUT'; // The HTTP Request Type
            String contentType = 'text/csv'; // File Type

            // Get inputs
            String fileType = (string)input.get('strUploadFileType'); // Get File Type
            String filePath = (string)input.get('strUploadURL'); // Get File Name

            //Start the csvFile and add the header right away
            String csvFile = 'month,baseload_mw,peak_mw';

            //Fill in the csvFile with the data
            List<Object> lstMonthlyVolume = (List<Object>)input.get('ExtractMontlyVolumeSummary');
            for(Object obj : lstMonthlyVolume){
                Map<String, Object> mapOfMonths = new Map<String,Object>((Map<String,Object>)obj);
                String month = (String)mapOfMonths.get('Month');
                if(String.isNotBlank(month)){
                    csvFile+='\r\n'+month+','+mapOfMonths.get('BaseloadClipMW')+','+mapOfMonths.get('PeakClipMW');
                }
            }

            //Set the values
            input.put('filePath',filePath);
            input.put('csvFileUpload',csvFile);
            
            //Upload to Gorilla and return the result
            UploadFile(input,output,options); 

            //Create a log file so to be able to track it against Gorilla
            SWAN_Status_Log__c st = new SWAN_Status_Log__c();
            st.SWAN_DatacomponentId__c = String.valueOf(input.get('DataComponentId'));
            st.SWAN_Process_Name__c = 'ElecFlexReassess';
            st.SWAN_Record_Id__c = (String)input.get('ContextId');
            insert st;

            return true;

        }catch(Exception ex){
            system.debug('Exception: ' + ex.getMessage());
            system.debug('Exception: ' + ex.getStackTraceString());
            return false;
        }
    }

}