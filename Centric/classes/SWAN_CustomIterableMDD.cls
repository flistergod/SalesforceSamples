public class SWAN_CustomIterableMDD implements Iterator<CSVWrapper_MDD>, Iterable<CSVWrapper_MDD>{ 
   List<CSVWrapper_MDD> lstCSVWrapper_MDD {get; set;} 
   Integer i {get; set;} 
   
   public SWAN_CustomIterableMDD (List<string> sUploadedCSVData){ 
           List<String> sCSVHeader = new List<String>();
            system.debug('AWSReadcsvFile Number of lines: ' + sUploadedCSVData.size());
             sCSVHeader = sUploadedCSVData[0].split(',');
             lstCSVWrapper_MDD  = new List<CSVWrapper_MDD>();
            for(Integer iMeterIndex = 1; iMeterIndex < sUploadedCSVData.size();iMeterIndex++){ // Loop CSV LINE
                String[] sCurrentMeterData = sUploadedCSVData[iMeterIndex].split(',');
                CSVWrapper_MDD obj=new CSVWrapper_MDD();
                for(Integer iMeterDataIndex = 0;iMeterDataIndex < sCurrentMeterData.size();iMeterDataIndex++)
                {
                    if(sCSVHeader[iMeterDataIndex] == 'mpan')
                    {
                        obj.mprn = sCurrentMeterData[iMeterDataIndex];
                    }
                    else if(sCSVHeader[iMeterDataIndex] == 'import_export')
                    {
                        obj.import_export = sCurrentMeterData[iMeterDataIndex];
                    }/*
                    else if(sCSVHeader[iMeterDataIndex] == 'prepayment_indicator')
                    {
                        obj.prepayment_indicator = Boolean.valueOf(sCurrentMeterData[iMeterDataIndex]);
                    }*/
                    else if(sCSVHeader[iMeterDataIndex] == 'voltage')
                    {
                        obj.voltage = sCurrentMeterData[iMeterDataIndex];
                    }
                    else if(sCSVHeader[iMeterDataIndex] == 'site_specific')
                    {
                        obj.site_specific = Boolean.valueOf(sCurrentMeterData[iMeterDataIndex]);
                    }
                    else if(sCSVHeader[iMeterDataIndex] == 'combination_valid')
                    {
                        obj.combination_valid = Boolean.valueOf(sCurrentMeterData[iMeterDataIndex]);
                    }
                    else if(sCSVHeader[iMeterDataIndex] == 'combination_supported')
                    {
                        obj.combination_supported = Boolean.valueOf(sCurrentMeterData[iMeterDataIndex]);
                    }
                    else if(sCSVHeader[iMeterDataIndex] == 'unsupported_reason')
                    {
                        obj.unsupported_reason = sCurrentMeterData[iMeterDataIndex];
                    }
                    else if(sCSVHeader[iMeterDataIndex] == 'distributor_id')
                    {
                        obj.distributor_id = Integer.valueOf(sCurrentMeterData[iMeterDataIndex]);
                    }
                    else if(sCSVHeader[iMeterDataIndex] == 'profile_class')
                    {
                        obj.profile_class = sCurrentMeterData[iMeterDataIndex];
                    }
                    else if(sCSVHeader[iMeterDataIndex] == 'meter_timeswitch_class')
                    {
                        obj.meter_timeswitch_class = sCurrentMeterData[iMeterDataIndex];
                    }
                    else if(sCSVHeader[iMeterDataIndex] == 'line_loss_factor_class')
                    {
                        obj.line_loss_factor_class = sCurrentMeterData[iMeterDataIndex];
                    }
                    else if(sCSVHeader[iMeterDataIndex] == 'gsp_group_id')
                    {
                        obj.gsp_group_id = sCurrentMeterData[iMeterDataIndex];
                    }
                    else if(sCSVHeader[iMeterDataIndex] == 'measurement_class')
                    {
                        obj.measurement_class = sCurrentMeterData[iMeterDataIndex];
                    }
                    else if(sCSVHeader[iMeterDataIndex] == 'standard_settlement_configuration')
                    {
                        obj.standard_settlement_configuration = sCurrentMeterData[iMeterDataIndex];
                    }
                    else if(sCSVHeader[iMeterDataIndex].equalsIgnoreCase('ssc_group_id')){
                        try{
                            obj.standard_settlement_configuration_group = sCurrentMeterData[iMeterDataIndex];
                        }catch(Exception ex){
                            obj.standard_settlement_configuration_group = null;
                        }
                    }
                }
                lstCSVWrapper_MDD.add(obj);
                system.debug('lstCSVWrapper_MDD='+lstCSVWrapper_MDD);
            }
       i = 0; 
   }   
   public boolean hasNext(){ 
       return (i >= lstCSVWrapper_MDD.size()) ? false : true; 
   }    
   public CSVWrapper_MDD next(){ 
       if(i < lstCSVWrapper_MDD.size())
        {
            i = i+1;
            return lstCSVWrapper_MDD[i-1]; 
        }
        return null;
   } 
   
   public Iterator<CSVWrapper_MDD> iterator() 
   { 
       return this; 
   } 
   
   public class CSVWrapper_MDD
   {
       public string mprn;
       public string import_export;
       //public Boolean prepayment_indicator;
       public string voltage;
       public Boolean site_specific;
       public Boolean combination_valid;
       public Boolean combination_supported;
       public string unsupported_reason;
       public integer distributor_id;
       public string profile_class;
       public string meter_timeswitch_class;
       public string line_loss_factor_class;
       public string gsp_group_id;
       public string measurement_class;
       public string standard_settlement_configuration;
       public string standard_settlement_configuration_group;
   }
}