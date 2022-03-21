/*
   @Author: André Cunha
   @CreatedDate: 10/07/2020
   @Description: Loyalty Program Member trigger handler. Must handle team trigger scopes
 */
public class LoyaltyProgramMember_th extends LoyaltyTriggerHandler implements LoyaltyTriggerInterface{
    private Map<Id, Loyalty_Program_Member__c> newMap;
    private Map<Id, Loyalty_Program_Member__c> oldMap;
    private LoyaltyProgramMember_tl triggerLogic;

    public LoyaltyProgramMember_th() {
        this.newMap = (Map<Id, Loyalty_Program_Member__c>) Trigger.newMap;
        this.oldMap = (Map<Id, Loyalty_Program_Member__c>) Trigger.oldMap;
        this.triggerLogic = new LoyaltyProgramMember_tl(this);
    }

    /*
	   @Description: returns trigger new Map
	 */
	public Map<Id,Loyalty_Program_Member__c> getNewMap(){
		return newMap;
	}

	/*
	   @Description: return trigger old Map
	 */
	public Map<Id,Loyalty_Program_Member__c> getOldMap(){
		return oldMap;
	}

	/*
	   @Description: call methods before insert
	 */
	public override void beforeInsert(){
        //add methods before insert
		triggerLogic.fillRecordTypeBasedOnProgram();
		triggerLogic.fillProgramMemberName();
    }
    
    /*
	@Description: call methods after insert
	 */
	public override void afterInsert(){
		//add methods after insert
		
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