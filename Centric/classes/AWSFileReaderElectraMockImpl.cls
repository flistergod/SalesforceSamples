global class AWSFileReaderElectraMockImpl implements HttpCalloutMock{
      global HTTPResponse respond(HTTPRequest req){
   
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('mpan,meter_Id,Total_EAC,number_of_days,error' + '\n' + '12345,12345,12,12,error');
      res.setStatusCode(200);
                  
      return res; 
   }
}