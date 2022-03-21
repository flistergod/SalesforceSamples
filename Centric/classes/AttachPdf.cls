global without sharing class AttachPdf implements vlocity_cmt.VlocityOpenInterface{
global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
     Boolean result = true;
        try
        {
            if (methodName.equals('attachPdf'))
            {
                attachPdf(inputMap,outMap);
            }
               
            else 
            {
                result = false;
            }   
        } 
        catch(Exception e)
        {
            System.debug('exception: '+e);
            result = false;  outMap.put('ErrorAgreement','Error');
        }
        return result;
    }
    
private static void attachPdf(Map<String,Object> inputMap,Map<String,Object> outMap)
{
	/*
    String agreementId=(String)inputMap.get('ContextId');
    SWAN_Offer_Pack__c opack=[select Name,SWAN_Opportunity__r.Account.Name from SWAN_Offer_Pack__c where id=:agreementId];
    String num = opack.SWAN_Opportunity__r.Account.Name;
    ContentDocumentLink link=[SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:agreementId order by systemModStamp desc limit 1]; 
    
    HttpRequest req=new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Authorization', 'OAuth '+UserInfo.getSessionId());
        req.setEndpoint(System.URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v45.0/connect/files/'+link.ContentDocumentId+'/rendition?type=PDF');
    HttpResponse response=new Http().send(req);
    
    ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; 
            conVer.PathOnClient = 'OfferPack '+num+'.pdf'; 
            conVer.Title = 'OfferPack '+num;
            conVer.VersionData = response.getBodyAsBlob(); 
    insert conVer;
            
    Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
            
    ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = conDoc;
            cDe.LinkedEntityId = agreementId; 
            cDe.ShareType = 'I'; 
    insert cDe; 
    delete link;
	*/
}
}