public with sharing class QUOTE_ANNEX{
    @AuraEnabled
    public static wrapper insertAttachment(string OfferPackId)
    {	
        SWAN_Offer_Pack__c ofp_type = null;
        if(!OfferPackId.startswithignorecase('0Q0')){
        	ofp_type = [SELECT id,SWAN_Offer_Type__c from SWAN_Offer_Pack__c where id=:OfferPackId];
        }
        
        if(ofp_type!= null && ofp_type.SWAN_Offer_Type__c == 'Flex'){
            wrapper wrp = new wrapper();
            wrp.AttList=null;
            wrp.isAllowed=false;
            wrp.msg='Only fixed offer packs can generate quote annexe';    
            return wrp;
        }
        else {
            wrapper wrp = new wrapper();
            if(OfferPackId.startswithignorecase('0Q0')){
                quote siteadditionquote = [select id,status,(SELECT id from attachments where contenttype='application/vnd.ms-excel' and name like '%.xls') from quote where recordtype.developername='Site_Addition_Quote' and id =:OfferPackId];    
                if(siteadditionquote.attachments.size()>0)
                {
                    wrp.AttList=null;
                    wrp.isAllowed=false;
                    wrp.msg='You have already generated the quote annexes, which can be found in the attachments section';    
                }
                else if(siteadditionquote.status!='Issued')
                {
                    wrp.AttList=null;
                    wrp.isAllowed=false;
                    wrp.msg='Only issued site addition can generate quote annexe';
                }
                else{
                    List<attachment>ListofAtt=new List<attachment>();
                    
                    OfferPackExcelGeneratorController run=new OfferPackExcelGeneratorController();
                    run.OfferPackId=null;
                    run.Mquoteid=siteadditionquote .id;
                    ListofAtt.addall(run.OfferPackExcelGeneratorController1());

                    insert(ListofAtt);
                    wrp.AttList=ListofAtt;
                    wrp.isAllowed=true;
                    wrp.msg=ListofAtt.size()+' quote annexe generated';
                }
            }
            else{
            SWAN_Offer_Pack__c offer = [SELECT id,SWAN_IsNotAmendable__c,SWAN_Opportunity__r.StageName,(SELECT id from attachments where contenttype='application/vnd.ms-excel' and name like '%.xls') from SWAN_Offer_Pack__c where id=:OfferPackId];
            
            
            if(!offer.SWAN_IsNotAmendable__c)
            {
                wrp.AttList=null;
                wrp.isAllowed=false;
                wrp.msg='You cannot generate quote annexes now as the offer pack is still amendable';
            }
            else if(offer.SWAN_Opportunity__r.StageName=='Closed Lost' || offer.SWAN_Opportunity__r.StageName=='Closed Won')
            {
                wrp.AttList=null;
                wrp.isAllowed=false;
                wrp.msg='You cannot generate quote annexes, because related opportunity is in '+offer.SWAN_Opportunity__r.StageName+ ' stage.';    
            }
            else if(offer.attachments.size()>0)
            {
                wrp.AttList=null;
                wrp.isAllowed=false;
                wrp.msg='You have already generated the quote annexes, which can be found in the attachments section';    
            }
            else
            {
                List<attachment>ListofAtt=new List<attachment>();
                for(SWAN_Offer_Pack_Quote__c opq : [Select id,SWAN_Quote__c from SWAN_Offer_Pack_Quote__c where SWAN_Offer_Pack__c =:OfferPackId])
                {   
                    OfferPackExcelGeneratorController run=new OfferPackExcelGeneratorController();
                    run.OfferPackId=OfferPackId;
                    run.Mquoteid=opq.SWAN_Quote__c;
                    ListofAtt.addall(run.OfferPackExcelGeneratorController1());
                }
                insert(ListofAtt);
                wrp.AttList=ListofAtt;
                wrp.isAllowed=true;
                wrp.msg=ListofAtt.size()+' quote annexe generated';
            }
            }
            return wrp;
        }
    }
    
    public class wrapper{
        @AuraEnabled public List<attachment>AttList{get;set;}
        @AuraEnabled public boolean isAllowed{get;set;}
        @AuraEnabled public string msg{get;set;}    
    }
}