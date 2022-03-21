trigger SWAN_Quote on Quote (after insert,after update,after delete,before delete, before update, before insert) {
    
    if(!SWAN_Constants.QuoteTriggerExecuted && !(Trigger.isUpdate  &&  Trigger.isBefore) )
    {
        //SWAN_Constants.QuoteTriggerExecuted = true;
        if((Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) && Trigger.isAfter)
        {
            SWAN_QuoteLogicHandler.calculateNumberOfSites();  
            if(Trigger.isUpdate && Trigger.isAfter)
            {
                SWAN_QuoteLogicHandler.generateBCRFile();  
                SWAN_QuoteLogicHandler.priceAndValidateNotif();  
                SWAN_QuoteLogicHandler.runFlexQuoteValidation2Time();
            }  
                 
            if(Trigger.isUpdate  && Trigger.isAfter){
                SWAN_QuoteLogicHandler.cloneChildQuotesForCarbonQuote();
                SWAN_QuoteLogicHandler.checkValidatedSPs();
                SWAN_QuoteLogicHandler.cloneQLIForCarbonQuote();
            } 
      
        }    
        
        if((Trigger.isUpdate && Trigger.isAfter) || (Trigger.isDelete && Trigger.isBefore))
        {
            SWAN_QuoteLogicHandler.pricingStatusUpdateOnOfferPack();   
            if(Trigger.isDelete && Trigger.isBefore)
            {
                SWAN_QuoteLogicHandler.restrictQuoteDelete(); 
                SWAN_QuoteLogicHandler.restrictDeleteForQuoteWithOfferPack();
            }  
        }
    } /*else if( !SWAN_Constants.QuoteTriggerExecuted && (Trigger.isUpdate  &&  Trigger.isBefore)){
        
        SWAN_QuoteLogicHandler.enableCheckBoxPriceOutOfDate();
        
    }*/
    
    if(Trigger.isBefore && Trigger.isInsert)
    {
      SWAN_QuoteLogicHandler.beforeInsertMethod();
    }   
    
    
}