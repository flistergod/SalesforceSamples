/*
* ClassName - SWAN_OfferPackQuoteLogicHandler
* Description - Class is being invoked from Offer Pack Quote Apex trigger
*               Functionality:
*               1.  Check validation of valid Quotes under the offer pack(Method : getOfferPackQuoteError)
*               2.  Check pricing structure error in newly added offers in offer pack(Method : getOfferPackQuoteError)
*/

public without sharing class SWAN_OfferPackQuoteLogicHandler {

    /*
    * Method Name - getOfferPackQuoteError
    * Description - Check if all quotes under the offer packs have same Pricing Structure,Payment method and terms, Start date and number of sites
    *               Check if all quotes under the offer packs have Pricing error or not
    */
    public static void getOfferPackQuoteError()
    {
        
        Set<Id> setOfferPackId = new Set<Id>();
        Map<Id,Set<Id>> offerPackQuoteMap = new Map<Id,Set<Id>>();
        Map<Id,Id> quoteOfferPackMap = new Map<Id,Id>();
        Set<Id> masterQuoteWithNoError = new Set<Id>();
        Map<Id,SWAN_Offer_Pack__c> offerPackMap = new Map<ID,SWAN_Offer_Pack__c>();  
        List<SWAN_Offer_Pack__c> listOfferPackWithError = new List<SWAN_Offer_Pack__c>();
        Boolean offerPackQuoteError = false;
        Boolean offerPackPriceError = false;
        
        // Get all Offer pack Ids of associated Offer Pack Quote
        if(Trigger.isInsert || Trigger.isUpdate)
        {
            for(SWAN_Offer_Pack_Quote__c opq : (list<SWAN_Offer_Pack_Quote__c>)Trigger.new) 
            {
                if(opq.SWAN_Offer_Pack__c != null)
                {
                    setOfferPackId.add(opq.SWAN_Offer_Pack__c);
                }
                if(opq.SWAN_Quote__c != null && opq.SWAN_Offer_Pack__c != null)
                {
                    quoteOfferPackMap.put(opq.SWAN_Quote__c,opq.SWAN_Offer_Pack__c);
                    if(!offerPackQuoteMap.ContainsKey(opq.SWAN_Offer_Pack__c))
                    {
                        offerPackQuoteMap.put(opq.SWAN_Offer_Pack__c,new set<ID>{opq.SWAN_Quote__c});
                    }
                    else
                    {
                        offerPackQuoteMap.get(opq.SWAN_Offer_Pack__c).add(opq.SWAN_Quote__c);
                    }
                }
            }
        }
        
        if(Trigger.isDelete)
        {
            for(SWAN_Offer_Pack_Quote__c opq : (list<SWAN_Offer_Pack_Quote__c>)Trigger.old ) 
            {
                if(opq.SWAN_Offer_Pack__c != null)
                {
                    setOfferPackId.add(opq.SWAN_Offer_Pack__c);
                    offerPackQuoteMap.put(opq.SWAN_Offer_Pack__c,new set<ID>());
                }
               	/*if(opq.SWAN_Quote__c != null && opq.SWAN_Offer_Pack__c != null)
                {
                    quoteOfferPackMap.put(opq.SWAN_Quote__c,opq.SWAN_Offer_Pack__c);
                    if(!offerPackQuoteMap.ContainsKey(opq.SWAN_Offer_Pack__c))
                    {
                        offerPackQuoteMap.put(opq.SWAN_Offer_Pack__c,new set<ID>{opq.SWAN_Quote__c});
                    }
                    else
                    {
                        offerPackQuoteMap.get(opq.SWAN_Offer_Pack__c).add(opq.SWAN_Quote__c);
                    }
                }*/
            }
        }
        
        system.debug('setOfferPackId '+setOfferPackId);
        if(!setOfferPackId.isEmpty())
        {
            for(SWAN_Offer_Pack__c offerPack : [SELECT id,Offer_Packs_With_Error__c,SWAN_Price_Valid__c,(SELECT Id,Name,SWAN_Offer_Pack__c,SWAN_Quote__r.Status,SWAN_Quote__r.SWAN_Pricing_Structure__c,SWAN_Quote__r.SWAN_Payment_Method__c,SWAN_Quote__r.SWAN_Payment_Term__c , SWAN_Quote__r.SWAN_Offer_Start_Date__c,SWAN_Quote__r.SWAN_Number_of_Service_Points__c, SWAN_Quote__r.SWAN_Price_out_of_Date__c,SWAN_Quote__r.SWAN_Quote_for_Fuel_Type__c,SWAN_Quote__r.SWAN_Passthrough_Option__c FROM Offer_Pack_Quotes__r) FROM SWAN_Offer_Pack__c WHERE id IN :setOfferPackId])
            {
                offerPackQuoteError = false;
                offerPackPriceError = false;
                SWAN_Offer_Pack_Quote__c baseOffer = offerPack.Offer_Pack_Quotes__r[0];
               
                for(SWAN_Offer_Pack_Quote__c opq1 : offerPack.Offer_Pack_Quotes__r){
                    
                    //add quote ids that are already present into the offer pack 
                    offerPackQuoteMap.get(offerPack.Id).add(opq1.SWAN_Quote__c);
                    // update remaining quotes  
                    quoteOfferPackMap.put(opq1.SWAN_Quote__c,offerPack.Id);
                    
					//check passthrough for electricity
					if(opq1.SWAN_Quote__r.SWAN_Passthrough_Option__c != baseOffer.SWAN_Quote__r.SWAN_Passthrough_Option__c && opq1.SWAN_Quote__r.SWAN_Quote_for_Fuel_Type__c == 'Electricity')
                    {
                        offerPackQuoteError = true;
                    }
                    // Check Pricing Structure
                    if(opq1.SWAN_Quote__r.SWAN_Pricing_Structure__c != baseOffer.SWAN_Quote__r.SWAN_Pricing_Structure__c && opq1.SWAN_Quote__r.SWAN_Quote_for_Fuel_Type__c == 'Gas')
                    {
                        offerPackQuoteError = true;
                    }
                    system.debug(opq1.SWAN_Quote__r.SWAN_Payment_Method__c +' @ '+baseOffer.SWAN_Quote__r.SWAN_Payment_Method__c);
                    // Check Payment method and terms
                    if(opq1.SWAN_Quote__r.SWAN_Payment_Method__c != baseOffer.SWAN_Quote__r.SWAN_Payment_Method__c || opq1.SWAN_Quote__r.SWAN_Payment_Term__c != baseOffer.SWAN_Quote__r.SWAN_Payment_Term__c)
                    {
                        offerPackQuoteError = true;
                    }
                    system.debug(opq1.SWAN_Quote__r.SWAN_Offer_Start_Date__c +' @ '+baseOffer.SWAN_Quote__r.SWAN_Offer_Start_Date__c);
                    // Check Start Date
                    if(!opq1.SWAN_Quote__r.SWAN_Offer_Start_Date__c.isSameDay(baseOffer.SWAN_Quote__r.SWAN_Offer_Start_Date__c))
                    {
                        offerPackQuoteError = true;
                    }
                    system.debug(opq1.SWAN_Quote__r.SWAN_Number_of_Service_Points__c +' @ '+baseOffer.SWAN_Quote__r.SWAN_Number_of_Service_Points__c);
                    // Check Number of Service points
                    if(opq1.SWAN_Quote__r.SWAN_Number_of_Service_Points__c != baseOffer.SWAN_Quote__r.SWAN_Number_of_Service_Points__c)
                    {
                        offerPackQuoteError = true;
                    }
                    // Check price assessment valid or not
                    if(opq1.SWAN_Quote__r.SWAN_Price_out_of_Date__c && opq1.SWAN_Quote__r.Status != 'Submitted')
                    {
                        offerPackPriceError = true;
                    }
                }
                
                // Add Offer pack with appropriate flags
                if(offerPackPriceError && offerPackQuoteError)
                {
                    offerPack.Offer_Packs_With_Error__c = true;
                    offerPack.SWAN_Price_Valid__c = false;
                    if(offerPackQuoteMap.ContainsKey(offerPack.Id))
                    {
                    offerPackQuoteMap.remove(offerPack.Id);
                    }
                    offerPackMap.put(offerPack.Id,offerPack);
                }
                if(!offerPackPriceError && offerPackQuoteError)
                {
                    offerPack.Offer_Packs_With_Error__c = true;
                    offerPack.SWAN_Price_Valid__c = true;
                    if(offerPackQuoteMap.ContainsKey(offerPack.Id))
                    {
                    offerPackQuoteMap.remove(offerPack.Id);
                    }
                    offerPackMap.put(offerPack.Id,offerPack);
                }
                if(offerPackPriceError && !offerPackQuoteError)
                {
                    offerPack.Offer_Packs_With_Error__c = false;
                    offerPack.SWAN_Price_Valid__c = false;
                    if(offerPackQuoteMap.ContainsKey(offerPack.Id))
                    {
                    masterQuoteWithNoError = offerPackQuoteMap.get(offerPack.Id);
                    }
                    offerPackMap.put(offerPack.Id,offerPack);
                }
                if(!offerPackPriceError && !offerPackQuoteError)
                {
                    offerPack.Offer_Packs_With_Error__c = false;
                    offerPack.SWAN_Price_Valid__c = true;
                    if(offerPackQuoteMap.ContainsKey(offerPack.Id))
                    {
                      masterQuoteWithNoError = offerPackQuoteMap.get(offerPack.Id);
                    }
                    offerPackMap.put(offerPack.Id,offerPack);
                }
                
            }
             if(!offerPackQuoteMap.isEmpty())
             {
                Map<String,Date> offPackSerPoDate = new Map<String,Date>();
                
                set<Id> offerpackId = new Set<ID>();
                 for(Quote childQuote :[Select id ,vlocity_cmt__DefaultServicePointId__c,SWAN_Service_Point_Start_Date__c,vlocity_cmt__ParentQuoteId__c,(Select id,Product2Id from QuoteLineItems where Product2.vlocity_cmt__IsOrderable__c = true limit 1) from Quote where vlocity_cmt__ParentQuoteId__c IN : masterQuoteWithNoError AND Recordtype.DeveloperName != 'GroupCart'])
                 {
                     String baseProductId = childQuote.QuoteLineItems[0].Product2Id;
                     for(QuoteLineItem qLI : childQuote.QuoteLineItems)
                     {
                         if(baseProductId != qLI.Product2Id)
                         {
                                SWAN_Offer_Pack__c opack = new SWAN_Offer_Pack__c();
                                opack.Id = quoteOfferPackMap.get(childQuote.vlocity_cmt__ParentQuoteId__c);
                                opack.Offer_Packs_With_Error__c = true;
                             if(offerPackMap.containsKey(quoteOfferPackMap.get(childQuote.vlocity_cmt__ParentQuoteId__c)))
                                {
                                    offerPackMap.get(opack.Id).Offer_Packs_With_Error__c=true;
                                }
                                else{
                                     offerPackMap.put(opack.Id,opack);
                                }
                                offerpackId.add(quoteOfferPackMap.get(childQuote.vlocity_cmt__ParentQuoteId__c));
                         }
                     }
                    if(!offerpackId.contains(quoteOfferPackMap.get(childQuote.vlocity_cmt__ParentQuoteId__c)))
                    {   
                        
                     if(offerPackQuoteMap.ContainsKey(quoteOfferPackMap.get(childQuote.vlocity_cmt__ParentQuoteId__c)))
                     {
                        String uniqueKey = quoteOfferPackMap.get(childQuote.vlocity_cmt__ParentQuoteId__c) +''+childQuote.vlocity_cmt__DefaultServicePointId__c;
                        if(offPackSerPoDate.containsKey(uniqueKey))
                        {
                            if(offPackSerPoDate.get(uniqueKey) != childQuote.SWAN_Service_Point_Start_Date__c){

                                offerpackId.add(quoteOfferPackMap.get(childQuote.vlocity_cmt__ParentQuoteId__c));
                                SWAN_Offer_Pack__c op = new SWAN_Offer_Pack__c();
                                op.Id = quoteOfferPackMap.get(childQuote.vlocity_cmt__ParentQuoteId__c);
                                op.Offer_Packs_With_Error__c = true;
                                
                                if(offerPackMap.containsKey(op.Id))
                                {
                                    offerPackMap.get(op.Id).Offer_Packs_With_Error__c=true;
                                }
                                else{
                                     offerPackMap.put(op.Id,op);
                                }
                                offerPackQuoteMap.remove(quoteOfferPackMap.get(childQuote.vlocity_cmt__ParentQuoteId__c));
                            }
                            else{
                                
                            }
                        }
                        else{
                            offPackSerPoDate.put(uniqueKey,childQuote.SWAN_Service_Point_Start_Date__c);
                        }
                     }
                    }
                 }
             }
            listOfferPackWithError = offerPackMap.values();
            // Update offer packs
            if(listOfferPackWithError != null && listOfferPackWithError.size() > 0)
            {
                try
                {
                    if (Schema.sObjectType.SWAN_Offer_Pack__c.isUpdateable()) 
                    update listOfferPackWithError;  
                }
                catch (Exception e)
                {
                    system.debug('Error occurred '+e.getMessage());
                }
            }
        }
        
    }
}