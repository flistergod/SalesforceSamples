/**
 * This class is used to clone subquotes and quote line items
 * 
 * @author Gagandeep Bansal
 * @version 1.0
 * 
 * History
 * =======
 * v1.0 - 12-07-2020 - Initial Version
 * 
 */
 
public class CloneQuoteAndQLI {

    
    public static List<QuoteLineItem> CloneQuoteLineItem(Quote clonedQuote, FixFailedSubQuotes.SubQuoteMetadata quoteRequest) {
 
          List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>();
            Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map <String, Schema.SObjectField> fieldMap = schemaMap.get('QuoteLineItem').getDescribe().fields.getMap();
            List<Schema.DescribeFieldResult> fields = new List<Schema.DescribeFieldResult>();

            List<Schema.SObjectField>tempFields = fieldMap.values();
            for(Schema.SObjectField sof : tempFields)
            {
                fields.add(sof.getDescribe()); 
            } 
        

            String getAllQuery = buildQueryAllString(fields,'QuoteLineItem', '', quoteRequest.referencedQuote);
            List<QuoteLineItem> templateQuoteLineItems = Database.query(getAllQuery);

        for (QuoteLineItem templateQuoteLineItem : templateQuoteLineItems) {
            QuoteLineItem clonedQuoteLineItem = templateQuoteLineItem.clone(false, true);
            clonedQuoteLineItem.QuoteId=clonedQuote.Id;
            quoteLineItems.add(clonedQuoteLineItem);                    
        }
 
            insert quoteLineItems;
            
            return quoteLineItems;
        }

        public static Quote CloneQuoteAndQLI(FixFailedSubQuotes.SubQuoteMetadata quoteRequest) {
                
            Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map <String, Schema.SObjectField> fieldMap = schemaMap.get('Quote').getDescribe().fields.getMap();
            List<Schema.DescribeFieldResult> fields = new List<Schema.DescribeFieldResult>();            
            
            List<Schema.SObjectField> tempFields = fieldMap.values();
            for(Schema.SObjectField sof : tempFields)
            {
                fields.add(sof.getDescribe());
            } 
            
            String getAllQuery = buildQueryAllString(fields, 'Quote', 'GroupId', quoteRequest.groupId);
            Quote templateQuote = null;
            Quote clonedQuote = null;
            
            try{
                templateQuote = Database.query(getAllQuery);
                clonedQuote = templateQuote.clone(false, true);                 
                System.debug('Created clone using group id  :'+quoteRequest+' cloned Quote :'+clonedQuote);
            } catch (Exception e) {
                getAllQuery = buildQueryAllString(fields, 'Quote', 'GroupCartId', quoteRequest.groupcartId);
                templateQuote = Database.query(getAllQuery); 
                clonedQuote = templateQuote.clone(false, true);
                
                System.debug('Create clone using group cart id  :'+quoteRequest+' cloned Quote :'+clonedQuote);

                RecordType recordType = [Select Id from RecordType where DeveloperName='SubQuote' LIMIT 1];
                clonedQuote.RecordTypeId = recordType.Id;
                System.debug('After assigning variables  :'+clonedQuote+' :'+quoteRequest);
            }
 
            quoteRequest.referencedQuote = String.valueOf(templateQuote.Id);
            clonedQuote.vlocity_cmt__DefaultServicePointId__c = quoteRequest.servicePoint;
            clonedQuote.Name = 'Quote_'+ quoteRequest.servicePoint;  

            
            insert clonedQuote;
            
            return clonedQuote;                
    }
    
    //Build the Query String
    public static String buildQueryAllString(List<Schema.DescribeFieldResult> queryFields,String obj, String creteria, object idObject)
    {
        String query = 'Select ';
        for(Schema.DescribeFieldResult dfr : queryFields)
        {
            query = query + dfr.getName() + ',';
        }
        query = query.subString(0,query.length() - 1);
        query = query + ' FROM '+obj;
        
        if (obj.equals('Quote')) {
            if (creteria.equals('GroupId')) {
                
                query = query + ' WHERE vlocity_cmt__QuoteGroupId__c=\'';
                query = query + (String)idObject + '\' AND recordtype.developername =\'SubQuote\' LIMIT 1';                   
            } else {
                query = query + ' where Id=\'';
                query = query + (String)idObject + '\' LIMIT 1';                  
            }
         
        } else {
            query = query + ' where QuoteId=\'';
            query = query + (String)idObject + '\'';           
        }


        system.debug('Build Query == ' + query);
        return query;
    }
}