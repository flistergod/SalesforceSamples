global class AWSFileReaderMeterCalloutMockImpl implements HttpCalloutMock{
      global HTTPResponse respond(HTTPRequest req){
   
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');     
      res.setBody('cost_component,cost_component_parent,days,errors,kwh,mprn,pence_per_day,pence_per_khw,pence_per_therm,pounds' + '\n' + 'Unit Rate,,30,,10,12345,99,99,99,999' + '\n' + 'Standing Charge,,30,,10,12345,99,99,99,999' + '\n' + 'Total Revenue,,30,,10,12345,99,99,99,999' + '\n' + 'Error,"3,0",,10,12345,99,99,99,999,1' + '\n' + 'Total Revenue,,30,,10,12345,99,99,99,999');
      res.setStatusCode(200);
                  
      return res; 
   }
}