public without sharing class SWAN_SiteAdditionFileDeletionHandler {

    public void restrictFileDeletion(Map<id,ContentDocument> mapContentDocument){
            
        
            Set<Id> oldContentDocIds = new Set<Id>();
            Set<Id> errorContentDocIds = new Set<Id>();
            oldContentDocIds = mapContentDocument.keySet();
            List<Id> linkIds = new List<Id>();
            List<ContentDocumentLink> doclinks = new List<ContentDocumentLink>();
            Map<Id, Id> contentDocAndLinkMap = new  Map<Id, Id>();
            //get doc links by trigger records on ContentDocmentLink.
            if (Schema.sObjectType.ContentDocumentLink.isAccessible()){
                doclinks = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink 
                                                      WHERE ContentDocumentId IN: oldContentDocIds ];
            }                                                                           
            if(!doclinks.isEmpty() || doclinks != null){                                      
                for(ContentDocumentLink doclink : doclinks){
                    linkIds.add(doclink.LinkedEntityId);
                    contentDocAndLinkMap.put(doclink.Id,doclink.ContentDocumentId);
                }
            }
            System.debug('contentDocAndLinkMap '+contentDocAndLinkMap );
            //get Site Addition Quotes and User records linked to ContentDocumentLink via LinkedEntityId as User records are also linked
            if (Schema.sObjectType.Quote.isAccessible()){
                Map<Id, Quote> site_Addition_Quotes= new  Map<Id, Quote>([SELECT Name,QuoteNumber FROM Quote
                                                                                    WHERE Id IN :linkIds AND Recordtype.developername='Site_Addition_Quote']);
                System.debug('site_Addition_Quotes'+site_Addition_Quotes);
                
                Map<Id, User> user_Rec = new  Map<Id, User>([SELECT Name FROM User
                                                                                WHERE Id IN :linkIds]);
                System.debug('user_Rec '+user_Rec );  
                
                if(!doclinks.isEmpty() || doclinks != null){
                    for(ContentDocumentLink doclink : doclinks){
                        if(site_Addition_Quotes.get(doclink.LinkedEntityId) != null || user_Rec.get(doclink.LinkedEntityId) != null  ){
                            
                            Id contentDocRecord = contentDocAndLinkMap.get(doclink.Id);
                            System.debug('contentDocRecord '+contentDocRecord ); 
                            errorContentDocIds.add(contentDocRecord);
                        }
                    }
                }
            }   
            System.debug('errorContentDocIds '+errorContentDocIds ); 
            
            //Iterate over ContentDocumentLinks under SiteAddition Quotes 
            for(Id doc : errorContentDocIds){
                
                SObject  actualRecord = mapContentDocument.get(doc);
                System.debug('actualRecord '+actualRecord ); 
                actualRecord.addError(Label.SiteAdditionAttachmentError); 
                
            }
        
    }

}