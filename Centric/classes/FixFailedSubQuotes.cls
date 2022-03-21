/**
 * This class is used to create missing subquote and quote line items
 * 
 * @author Gagandeep Bansal
 * @version 1.0
 * 
 * History
 * =======
 * v1.0 - 12-07-2020 - Initial Version
 * 
 */

global class FixFailedSubQuotes implements Database.Batchable<SubQuoteMetadata>  {

    global String masterQuoteId;
    
    global FixFailedSubQuotes(String masterQuoteId) {
        this.masterQuoteId = masterQuoteId;
    }
    
    global Iterable<SubQuoteMetadata> start(Database.BatchableContext bc) {
        return new SubQuoteMetadataItearable(masterQuoteId);
    }
    global void execute(Database.BatchableContext bc, List<Object> quotesToBeCreated){
        for (Object metadata : quotesToBeCreated) {
           System.debug('Make clone for  :'+metadata);
            Quote clonedQuote = CloneQuoteAndQLI.CloneQuoteAndQLI((SubQuoteMetadata)metadata);
            CloneQuoteAndQLI.CloneQuoteLineItem(clonedQuote, (SubQuoteMetadata)metadata);
        }
    }    
    global void finish(Database.BatchableContext bc){
    }    

    public static List<SubQuoteMetadata> prepareDataForBatchJob(String masterQuoteId) {
        Map<String, Object> masteQuoteMetadata = getMasteQuoteMetadata(masterQuoteId);
        Set<SubQuoteMetadata> quotesToBeCreated = (Set<SubQuoteMetadata>)masteQuoteMetadata.get('quotesToBeCreated');
        Set<String> groupIds = (Set<String>)masteQuoteMetadata.get('groupIds');
        
        System.debug('All quotes :'+quotesToBeCreated);
        System.debug('uniqueGroupIds :'+groupIds);

        removeAlreadyCreatedSubQuotes(quotesToBeCreated, groupIds);
        System.debug('quotesToBeCreated :'+quotesToBeCreated);

       /* for (SubQuoteMetadata metadata : quotesToBeCreated) {
           System.debug('Make clone for  :'+metadata);

            Quote clonedQuote = CloneQuote.CloneQuote(metadata);
            CloneQuote.CloneQuoteLineItem(clonedQuote, metadata);
        }*/
        return new List<SubQuoteMetadata>(quotesToBeCreated);
    }
        
        public static Set<SubQuoteMetadata> removeAlreadyCreatedSubQuotes(Set<SubQuoteMetadata> quotesToBeCreated, Set<String> groupIds) {

            List<Quote> subQuotes = [SELECT Id, Name, vlocity_cmt__QuoteGroupId__c, vlocity_cmt__DefaultServicePointId__c FROM Quote WHERE vlocity_cmt__QuoteGroupId__c = :groupIds AND recordtype.developername = 'SubQuote'];
            for (Quote quote: subQuotes) {
                SubQuoteMetadata alreadyCreatedSubQuote = new SubQuoteMetadata(quote.vlocity_cmt__QuoteGroupId__c,  quote.vlocity_cmt__DefaultServicePointId__c);
                if (quotesToBeCreated.contains(alreadyCreatedSubQuote)) {
                    quotesToBeCreated.remove(alreadyCreatedSubQuote);
                }
            } 
        return quotesToBeCreated;
    }

    
    public static Map<String, Object> getMasteQuoteMetadata(String masterQuote) {
        Map<String, Object> output = new Map<String, Object>();
        Set<SubQuoteMetadata> subQuotesMetadata = new Set<SubQuoteMetadata>();
        Set<String> groupIds = new Set<String>();
            
        List<Attachment> masterQuoteAttachments = [Select Id,Body from Attachment where ParentId=:masterQuote];
        for (Attachment masterQuoteAttachment : masterQuoteAttachments) {
            Blob body = masterQuoteAttachment.Body;
            
            if (null != body.toString()) {
               GroupCartAttachment groupCartAssignment = 
                   (GroupCartAttachment)JSON.deserialize(body.toString(), GroupCartAttachment.class);
                
                if (null != groupCartAssignment && 
                        null != groupCartAssignment.groupId && 
                            null != groupCartAssignment.servicePoints && !groupCartAssignment.servicePoints.isEmpty()) {
                                
                    for (String servicePoint : groupCartAssignment.servicePoints) {
                        SubQuoteMetadata subQuoteMetadata = new SubQuoteMetadata(groupCartAssignment.groupId, groupCartAssignment.groupName, groupCartAssignment.groupcartId, servicePoint);
                        subQuotesMetadata.add(subQuoteMetadata);
                        groupIds.add(groupCartAssignment.groupId);
                    }

                }
            }
        }
        output.put('quotesToBeCreated', subQuotesMetadata);
        output.put('groupIds', groupIds);
        return output;
    }

    public class GroupCartAttachment {
        String groupId;
        String groupName;
        String groupcartId;
        List<String> servicePoints;
    }
                                 
     public class SubQuoteMetadata {
        public String groupId;
        public String groupName;
        public String groupcartId;
        public String servicePoint;
        public String referencedQuote;

        SubQuoteMetadata(String groupId, String groupName, String groupcartId, String servicePoint) {
            this.groupId = groupId;
            this.groupName = groupName;
            this.groupcartId = groupcartId;
            this.servicePoint = servicePoint;
        }
         
        SubQuoteMetadata(String groupId,  String servicePoint) {
            this.groupId = groupId;
            this.servicePoint = servicePoint;
        }
         
        public Integer hashCode() {
            return (7 * groupId.hashCode() + 13* servicePoint.hashCode());
        }
        
        public Boolean equals(Object obj) {
            if (obj instanceof SubQuoteMetadata) {
                SubQuoteMetadata p = (SubQuoteMetadata)obj;
                return (groupId.equals(p.groupId)) && (servicePoint.equals(p.servicePoint));
            }
            return false;
        }
    }
    
    public class CustomIterator 
       implements Iterator<SubQuoteMetadata>{ 
    
       List<SubQuoteMetadata> subQuotesRequests {get; set;} 
       String masterQuoteId;
       Integer i {get; set;} 
    
       public CustomIterator(String masterQuoteId){ 
           this.subQuotesRequests = prepareDataForBatchJob(masterQuoteId); 
           i = 0; 
       }   
    
       public boolean hasNext(){ 
           return (i < subQuotesRequests.size());
       }    
    
       public SubQuoteMetadata next(){ 
           if(++i > subQuotesRequests.size()){return null;} 
           return subQuotesRequests[i-1]; 
       } 
    }
       
    public class SubQuoteMetadataItearable implements iterable<SubQuoteMetadata>{
        
        public String  masterQuoteId;
        public SubQuoteMetadataItearable(String masterQuoteId) {
            this.masterQuoteId = masterQuoteId;
        }
        
       public Iterator<SubQuoteMetadata> Iterator(){
          return new CustomIterator(this.masterQuoteId);
       }
    }
}