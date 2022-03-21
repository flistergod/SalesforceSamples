/*
   @Author: João Almeida
   @CreatedDate: 11/09/2020
   @Description: Contains the CRUD methods for Loyalty_Program_Setup_Level__c SObject
 */
public with sharing class Loyalty_Util_ProgramSetupLevelDml extends Loyalty_Util_GenericDML {
	public class ProgramSetupLevelDmlException extends Exception {}

	public Loyalty_Util_ProgramSetupLevelDml() {
		super('Loyalty_Program_Setup_Level__c');
	}

	/*
	   @Description: gets the program setup levels pagination definitions
       @param1: current page number
       @param2: page size - quantity of records per page
       @param3: optional search keyword value
	   @Return: program setup level records
	 */
	public List<Loyalty_Program_Setup_Level__c> getProgramSetupLevels(Integer pagenumber, Integer pageSize, String searchString) {
		List<Loyalty_Program_Setup_Level__c> programSetupLevels = null;
		try {
			List<String> selectableFields = new List<String> {'Id','Loyalty_Level__c', 'Loyalty_Reward_Achievable__c', 'Is_Bought_Items_Mandatory__c', 'Is_Points_Manadatory__c',
				                                          'Is_Purchases_Mandatory__c', 'Achievable_Bought_Items__c', 'Achievable_Points__c', 'Achievable_Purchases__c'};
			List<String> orderBy = new List<String> {'Program_Setup_Level_Code__c'};
			programSetupLevels = (Loyalty_Program_Setup_Level__c[])this.selectRecords(pagenumber, pageSize, searchString, null, selectableFields,null, orderBy, null, false, false);
		}
		catch (Exception ex) {
			throw ex;
		}

		return programSetupLevels;
	}

	/*
	   @Description: gets the program setup levels related to the program setup
	   @param1: program setup ID
	   @Return: all program setup levels
	   @Exception: thrown when there is no record related
	 */
	public List<Loyalty_Program_Setup_Level__c> getProgramSetupLevelsByProgramSetupId(Id programSetupId) {
		List<Loyalty_Program_Setup_Level__c> programSetupLevels = null;
		try {
			List<String> selectableFields = new List<String> {'Id','Loyalty_Level__c', 'Loyalty_Reward_Achievable__c', 'Is_Bought_Items_Mandatory__c', 'Is_Points_Manadatory__c',
				                                          'Is_Purchases_Mandatory__c', 'Achievable_Bought_Items__c', 'Achievable_Points__c', 'Achievable_Purchases__c'};
			List<String> orderBy = new List<String> {'Program_Setup_Level_Code__c'};
			List<String> whereClauses = new List<String> {'Loyalty_Program_Setup__c=\'' + programSetupId +'\''};
			programSetupLevels = (Loyalty_Program_Setup_Level__c[])this.selectRecords(0, 0, null, null, selectableFields,whereClauses, orderBy, null, false, false);
			if (programSetupLevels == null || programSetupLevels.isEmpty()) {
				throw new ProgramSetupLevelDmlException('getProgramSetupLevelsByProgramSetupId Error: ' + 'no program setup levels found for program setup Id ' + programSetupId);
			}
		}
		catch (Exception ex) {
			throw ex;
		}

		return programSetupLevels;
	}

	/*
	         @Description: gets the program setup level by loyalty level ID
	         @param1: loyalty level ID
	         @Return: the current loyalty level related to the account ID
	         @Exception: thrown when there is no record related
	 */
	public Loyalty_Program_Setup_Level__c getProgramSetupLevelByLoyaltyLevelId(Id loyaltyLevelId) {
		Loyalty_Program_Setup_Level__c programSetupLevel = null;
		try {
			List<String> selectableFields = new List<String> {'Id','Loyalty_Level__c', 'Loyalty_Reward_Achievable__c', 'Is_Bought_Items_Mandatory__c', 'Is_Points_Manadatory__c',
				                                          'Is_Purchases_Mandatory__c', 'Achievable_Bought_Items__c', 'Achievable_Points__c', 'Achievable_Purchases__c'};
			List<String> orderBy = new List<String> {'Program_Setup_Level_Code__c'};
			List<String> whereClauses = new List<String> {'Loyalty_Level__c=\'' + loyaltyLevelId +'\''};
			List<Loyalty_Program_Setup_Level__c> programSetupLevels = (Loyalty_Program_Setup_Level__c[])this.selectRecords(0, 0, null, null, selectableFields,whereClauses, orderBy, null, false, false);
			if (programSetupLevels != null && !programSetupLevels.isEmpty()) {
				programSetupLevel = programSetupLevels[0];
			}
			else {
				throw new ProgramSetupLevelDmlException('getProgramSetupLevelByLoyaltyLevelId Error: ' + 'no program setup level found for loyalty level Id ' + loyaltyLevelId);
			}
		}
		catch (Exception ex) {
			throw ex;
		}

		return programSetupLevel;
	}

	/*
	         @Description: gets the next program setup levels related to the program setup of the member program
	         @param1: program setup ID
	         @param1: program setup level record related to the program member level
	         @Return: all possible next member program setup levels
	         @Exception: thrown when there is no record related
	 */
	public List<Loyalty_Program_Setup_Level__c> getNextProgramSetupLevels(Id programSetupId, Loyalty_Program_Setup_Level__c currentMemberLevelSetup) {
		List<Loyalty_Program_Setup_Level__c> programSetupLevels = null;
		try {
			List<String> selectableFields = new List<String> {'Id','Loyalty_Level__c', 'Loyalty_Reward_Achievable__c', 'Is_Bought_Items_Mandatory__c', 'Is_Points_Manadatory__c',
														  'Is_Purchases_Mandatory__c', 'Achievable_Bought_Items__c', 'Achievable_Points__c', 'Achievable_Purchases__c',
														  'Loyalty_Level__r.Name'};
			List<String> orderBy = new List<String> {'Achievable_Points__c', 'Achievable_Purchases__c', 'Achievable_Bought_Items__c'};
			List<String> whereClauses = new List<String> {'Loyalty_Program_Setup__c=\'' + programSetupId +'\''};
			if (currentMemberLevelSetup != null) {
				whereClauses.add('and Id !=\'' + currentMemberLevelSetup.Id +'\'');
				whereClauses.add('and ((Is_Points_Manadatory__c=true and Achievable_Points__c > ' + (currentMemberLevelSetup.Achievable_Points__c != null ? currentMemberLevelSetup.Achievable_Points__c : 0) + ')');
				whereClauses.add(' or (Is_Bought_Items_Mandatory__c=true and Achievable_Bought_Items__c > ' + (currentMemberLevelSetup.Achievable_Bought_Items__c != null ? currentMemberLevelSetup.Achievable_Bought_Items__c : 0) + ')');
				whereClauses.add(' or (Is_Purchases_Mandatory__c=true and Achievable_Purchases__c > ' + (currentMemberLevelSetup.Achievable_Purchases__c != null ? currentMemberLevelSetup.Achievable_Purchases__c : 0) + '))');
			}
			programSetupLevels = (Loyalty_Program_Setup_Level__c[])this.selectRecords(0, 0, null, null, selectableFields,whereClauses, orderBy, null, false, false);
			if (programSetupLevels == null || programSetupLevels.isEmpty()) {
				throw new ProgramSetupLevelDmlException('getNextProgramSetupLevels Error: ' + 'no program setup levels found for program setup Id ' + programSetupId);
			}
		}
		catch (Exception ex) {
			throw ex;
		}

		return programSetupLevels;
	}
}