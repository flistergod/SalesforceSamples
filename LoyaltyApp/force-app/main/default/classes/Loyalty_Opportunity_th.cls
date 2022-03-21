/*
   @Author: João Almeida
   @CreatedDate: 08/09/2020
   @Description: Opportunity trigger handler. Must handle team trigger scopes
 */
public class Loyalty_Opportunity_th extends LoyaltyTriggerHandler implements LoyaltyTriggerInterface {
    private Map<Id, Opportunity> newMap;
    private Map<Id, Opportunity> oldMap;
    private Loyalty_Opportunity_tl triggerLogic;

    public Loyalty_Opportunity_th() {
        this.newMap = (Map<Id, Opportunity>) Trigger.newMap;
        this.oldMap = (Map<Id, Opportunity>) Trigger.oldMap;
        this.triggerLogic = new Loyalty_Opportunity_tl(this);
    }

    /*
	   @Description: returns trigger new Map
	 */
	public Map<Id,Opportunity> getNewMap(){
		return newMap;
	}

	/*
	   @Description: return trigger old Map
	 */
	public Map<Id,Opportunity> getOldMap(){
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
        //triggerLogic.createLoyaltyProgramSetup();
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
		triggerLogic.processCustomerLoyaltyValues();
	}
}