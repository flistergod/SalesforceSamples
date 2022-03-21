public class QuoteProposalModel {
    public String name;
    public Id quoteId;
    public String language;
    public String outputFormat;
    public String paperSize;
    public Id templateId;
    public Id id;

    public QuoteProposalModel(Id quote_Id) {
          quoteId=quote_Id;
            try {
            templateId=[select Id, SBQQ__QuoteTemplateId__c from SBQQ__Quote__c where Id=:quote_Id].SBQQ__QuoteTemplateId__c;
          
          if(string.isBlank(templateId)) {
               templateId=[select Id from SBQQ__QuoteTemplate__c where SBQQ__Default__c=true].Id;
          }
              
} catch(Exception e) {
    System.debug('The following exception has occurred: ' + e.getMessage());
}
    }
     }