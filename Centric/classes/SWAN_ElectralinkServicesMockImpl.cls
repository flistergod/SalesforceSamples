@isTest
global class SWAN_ElectralinkServicesMockImpl implements HttpCalloutMock{
   global HTTPResponse respond(HTTPRequest req){
   
      System.debug('Begin SWAN_ElectralinkServicesMockImpl');
      
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"id": "83ffa044-f290-11ea-b654-0606f445b02f","created_at": "2020-07-28T11:31:42.946802","created_by": {"id": "fbf64622-60ef-11e9-96a6-027a01f2c9e4","name": "client"},"updated_at": "2020-07-28T11:31:42.946827","updated_by": {"id": "fbf64622-60ef-11e9-96a6-027a01f2c9e4","name": "client"},"name": "QA - Test ElectraLink Connector","status": "scheduled","connector_version": {"model_id": "004af9d2-abba-11ea-ab9c-0a05a4892f7a","version_id": "0.5.5","name": "ElectraLink MPAN HH Per Period","status": "published"},"outputs": [{"code": "summary","args": [{"id": "e95d7264-d0c5-11ea-a664-0a0f5f0012ac","version_id": 1}]},{"code": "consumption","args": [{"id": "e95ddf2e-d0c5-11ea-a664-0a0f5f0012ac","version_id": 1}]}],"modules": ["pricing_power","forecasting"]}');
      res.setStatusCode(200);
      
      System.debug('End SWAN_ElectralinkServicesMockImpl');
      
      return res; 
   }
}