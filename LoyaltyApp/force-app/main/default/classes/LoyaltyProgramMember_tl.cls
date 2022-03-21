/*
   @Author: André Cunha
   @CreatedDate: 10/07/2020
   @Description: Loyalty program member trigger logic. Implemented methods with logic
 */
public class LoyaltyProgramMember_tl {
    private LoyaltyProgramMember_th handler;

    public LoyaltyProgramMember_tl(LoyaltyProgramMember_th handler) {
        this.handler = handler;
    }

    public void fillRecordTypeBasedOnProgram(){

        Set<String> programTypes = new Set<String>();
        Set<Id> programIds = new Set<Id>();
        
        for(Loyalty_Program_Member__c programMember : (List<Loyalty_Program_Member__c>)Trigger.new){
            if(programMember.Loyalty_Program__c != null){
                programIds.add(programMember.Loyalty_Program__c);    
            }
        }

        Map<Id,Loyalty_Program__c> programs = new Map<Id,Loyalty_Program__c>([SELECT id,Type__C FROM Loyalty_Program__c WHERE ID IN :programIds]);
        for(Loyalty_Program_Member__c programMember : (List<Loyalty_Program_Member__c>)Trigger.new){
            if(programs.containsKey(programMember.Loyalty_Program__c)){
                String loyaltyMemberType = programs.get(programMember.Loyalty_Program__c).Type__c + ' Member';
                programTypes.add(loyaltyMemberType.replaceAll(' ','_'));
            }
        }

        Map<String,RecordType> mapRecordTypes = new Map<String,RecordType>();

        for(RecordType rt : [SELECT id,Name,DeveloperName,SobjectType From RecordType WHERE DeveloperName IN :programTypes AND IsActive = TRUE]){
            mapRecordTypes.put(rt.name,rt);    
        }

        for(Loyalty_Program_Member__c programMember : (List<Loyalty_Program_Member__c>)Trigger.new){
            if(programs.containsKey(programMember.Loyalty_Program__c)){
                String loyaltyMemberType = programs.get(programMember.Loyalty_Program__c).Type__c + + ' Member';
                programMember.RecordTypeId = mapRecordTypes.get(loyaltyMemberType).id;
            }
		}
    }

    public void fillProgramMemberName(){
        
        Set<Id> accMemberIds = new Set<Id>();
        for(Loyalty_Program_Member__c programMember : (List<Loyalty_Program_Member__c>)Trigger.new){
            if(programMember.Member__c != null){
                accMemberIds.add(programMember.Member__c);    
            }
        }

        Map<Id,Account> members = new Map<Id,Account>([SELECT id,Name FROM Account WHERE ID IN :accMemberIds]);

        for(Loyalty_Program_Member__c programMember : (List<Loyalty_Program_Member__c>)Trigger.new){
            if(programMember.Member__c != null){
                programMember.Name = members.get(programMember.Member__c).Name;
            }
        }

    }
}