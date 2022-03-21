trigger SWAN_OfferPackQuote on SWAN_Offer_Pack_Quote__c (after insert,after update,after delete) {
    if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)
    {
        SWAN_OfferPackQuoteLogicHandler.getOfferPackQuoteError();   
    }
}