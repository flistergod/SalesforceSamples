global class AWSFileReaderCalloutMockImpl implements HttpCalloutMock{
      global HTTPResponse respond(HTTPRequest req){
   
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('cost_component,MWh,percentage_of_spend,pounds' + '\n' + 'Standing Charge,99,999,9999' + '\n' + 'Unit Rate,99,999,9999' + '\n' + 'Contract Spend,99,999,9999' + '\n' + 'Annual Spend,99,999,9999' + '\n' + 'Cost to Serve,99,999,9999' + '\n' + 'Contribution Margin,99,999,9999' + '\n' + 'Commodity,99,999,9999' + '\n' + 'Non-Commodity,99,999,9999' + '\n' + 'Metering,99,999,9999'+'\n'+'Unidentified Gas Cost,100,12,123'+'\n'+'Other External,12,33,33'+'\n'+'Other Internal,12,2,2'+'\n'+'Transportation,22,2,2'+'\n'+'Broker Commission,12,23,22');
      res.setStatusCode(200);
                  
      return res; 
   }
}