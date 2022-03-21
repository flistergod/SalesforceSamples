/*
   @Author: André Cunha
   @CreatedDate: 07/07/2020
   @Description: Loyalty Program trigger handler. Must handle team trigger scopes
 */
public class LoyaltyProgram_th extends LoyaltyTriggerHandler implements LoyaltyTriggerInterface{
    private Map<Id, Loyalty_Program__c> newMap;
    private Map<Id, Loyalty_Program__c> oldMap;
    private LoyaltyProgram_tl triggerLogic;

    public LoyaltyProgram_th() {
        this.newMap = (Map<Id, Loyalty_Program__c>) Trigger.newMap;
        this.oldMap = (Map<Id, Loyalty_Program__c>) Trigger.oldMap;
        this.triggerLogic = new LoyaltyProgram_tl(this);
    }

    /*
	   @Description: returns trigger new Map
	 */
	public Map<Id,Loyalty_Program__c> getNewMap(){
		return newMap;
	}

	/*
	   @Description: return trigger old Map
	 */
	public Map<Id,Loyalty_Program__c> getOldMap(){
		return oldMap;
	}

	/*
	   @Description: call methods before insert
	 */
	public override void beforeInsert(){
        //add methods before insert
    }
    
    /*
	@Description: call methods after insert
	 */
	public override void afterInsert(){
        //add methods after insert
        triggerLogic.createLoyaltyProgramSetup();
    }

	/*
	   @Description: call methods before update
	 */
	public override void beforeUpdate(){
        //add methods before update
		
	}
	/*
	   @Description: call methods after update
	 */
	public override void afterUpdate(){
        //add methods after update
		
	}
}