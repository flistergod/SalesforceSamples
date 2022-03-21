@isTest
global class AWSS3UploadCalloutMockImpl implements HttpCalloutMock{
   global HTTPResponse respond(HTTPRequest req){
   
      System.debug('Begin AWSS3UploadCalloutMockImpl');
      
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      //res.setBody('{"example":"test"}');
      res.setStatusCode(200);
      
      System.debug('End AWSS3UploadCalloutMockImpl');
      
      return res; 
   }
}