global class AWSFileReaderCalloutMDDMockImpl implements HttpCalloutMock{
      global HTTPResponse respond(HTTPRequest req){
   
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('mpan,import_export,prepayment_indicator,voltage,site_specific,combination_valid,combination_supported,unsupported_reason,distributor_id,profile_class,meter_timeswitch_class,line_loss_factor_class,gsp_group_id,measurement_class,standard_settlement_configuration' + '\n' + '12345,import,false,LVN,false,true,false,1234,78,01,abc,abc,ac,A,abc');
      res.setStatusCode(200);
                  
      return res; 
   }
}