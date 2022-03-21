public without sharing class LAN_ctrlQuoteDocument {

    private class LAN_QuoteDocumentModel {
        public String documentId {get; set;}
        public String filename {get; set;}
        public String fileData {get; set;}
    }

    @AuraEnabled(Cacheable=true)
    public static String getQuoteDocument(string quoteDocumentId) {
        try {
            LAN_QuoteDocumentModel quoteDocModel = new >();
            List<SBQQ__QuoteDocument__c> quoteDocData= [select SBQQ__DocumentId__c from SBQQ__QuoteDocument__c where Id =:quoteDocumentId];
            if (quoteDocData != null && !quoteDocData.isEmpty()) {
                List<Document> quoteMainDoc = [SELECT Id, Body, BodyLength, ContentType, DeveloperName, Name, Url, Type FROM Document WHERE Id = :quoteDocData[0].SBQQ__DocumentId__c];

                if (quoteMainDoc != null && !quoteMainDoc.isEmpty()) {
                    quoteDocModel.documentId = quoteMainDoc[0].Id;
                    quoteDocModel.filename= quoteMainDoc[0].Name;
                    quoteDocModel.fileData= EncodingUtil.base64Encode( quoteMainDoc[0].body );
                    return JSON.serialize(quoteDocModel);
                }
                else {
                    return 'NOT_FOUND';
                }
            }
            else {
                return 'NOT_FOUND';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}