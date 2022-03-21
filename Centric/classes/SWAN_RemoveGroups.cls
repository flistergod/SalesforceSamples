global with sharing class  SWAN_RemoveGroups implements vlocity_cmt.VlocityOpenInterface {

 /**
     * Top level call by a Vlocity Remote Action
     *
     * @param inputMap  - The input provided to the Remote Action
     * @param outputMap - Any output to be provided back to the Remote Action
     * @param options   - Any options to aid in the execution of this class
     *
     * @returns true if the method completes successfully, false otherwise
     */ 
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {

        Boolean result = true;
        try{

            if (methodName.equals('removeGroups')) {
                
                removeGroups(inputMap,outputMap,options);
                
            }else{
                result = false;
                
            }   
            
        }catch(Exception e){
            
            System.debug('SWAN_RemoveGroups :invokeMethod -> exception: '+e);
            result = false;
        }
        
        return result;
    
    }
    
    private Boolean removeGroups(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        
        String MasterQuoteId = String.ValueOf(inputMap.get('contextId'));
        List<String> lstGroupsToDelete =  (List<String>)json.deserialize(json.serialize(inputMap.get('groupIds')), List<String>.class);
	     
        //get quote ids
       	/*
        List<vlocity_cmt__QuoteGroup__c> vlQuoteGroup = [SELECT vlocity_cmt__QuoteId__c, Id FROM vlocity_cmt__QuoteGroup__c Where Id in : lstGroupsToDelete];
      	Set<String> lstIdsQuote =  new Set<String>();
        
        for(vlocity_cmt__QuoteGroup__c idQuote : vlQuoteGroup  ){
            lstIdsQuote.add(idQuote.vlocity_cmt__QuoteId__c);
        }
        */
        Map<String, Quote> lstQuoteGroup = new Map<String, Quote>([Select Id  from Quote Where vlocity_cmt__QuoteGroupId__c in : lstGroupsToDelete ]);
        System.debug('lstQuoteGroup::::: ' + lstQuoteGroup);
        
        List<Attachment> lstAttachment = [SELECT Id, Name, ParentId FROM Attachment Where ParentId =: MasterQuoteId ];
        
        List<Attachment> lstAttachmentToDelete = new List<Attachment>(); 
        
        // get attachments to delete 
        for(String idQuoteGroup : lstQuoteGroup.keySet() ){
            for(Attachment att : lstAttachment ){
                if(att.name.contains(idQuoteGroup)  ){
	   				lstAttachmentToDelete.add(att);
                
                }
            }
        }
        
        try{
            
            delete lstAttachmentToDelete;
            delete lstQuoteGroup.values();
                        
        }catch(Exception e){
            System.debug('lstAttachmentToDelete');
        	outputMap.put('ERROR' , e.getMessage());    
        }

        return true;
    }
    
    

 
}