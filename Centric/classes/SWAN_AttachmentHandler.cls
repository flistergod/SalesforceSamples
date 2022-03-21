public without sharing class SWAN_AttachmentHandler {
    public static void preventAttachmentDeletion(Map<id,Attachment> oldmapAttachment){
        Set<Id> attachmentIds = new Set<Id>();
        attachmentIds = oldmapAttachment.keySet();
        System.debug('attachmentIds'+attachmentIds);
        Map<Id, Attachment> att_Rec = new  Map<Id, Attachment>([SELECT Id,ParentId FROM Attachment
                                                                        WHERE Id IN :attachmentIds]);
        System.debug('att_Rec '+att_Rec);
        Map<Id,Id> parentIds = new Map<Id,Id>();
        for(Attachment aa :att_Rec.values()){
            Id attachmentId = (Id)(aa.ParentId);
            parentIds.put(aa.Id,attachmentId);
        }
        System.debug('parentIds '+parentIds);
        List<Quote> siteAdditionQuotes = new List<Quote>([SELECT Id,Name,QuoteNumber FROM Quote
                                                                        WHERE Id IN :parentIds.values() AND Recordtype.developername='Site_Addition_Quote']);
        System.debug('siteAdditionQuotes '+siteAdditionQuotes);
        Map<Id, Id> attmentQuoteErrorMap = new  Map<Id, Id>();
        for(Id att_oldmapId : parentIds.keySet()){
            for(Quote quoteId : siteAdditionQuotes){
                if(parentIds.get(att_oldmapId) == quoteId.Id){
                    attmentQuoteErrorMap.put(att_oldmapId,quoteId.ID);
                }   
            }    
        }
        System.debug('attmentQuoteErrorMap '+attmentQuoteErrorMap);
        for(Id error_att_Id : attmentQuoteErrorMap.keySet()){
            
            SObject  actualRecord = oldmapAttachment.get(error_att_Id);
            System.debug('actualRecord '+actualRecord ); 
            actualRecord.addError(Label.SiteAdditionAttachmentError); 
            
        }
    }

}