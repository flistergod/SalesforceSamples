/**
 * @description       : 
 * @author            : Nelson Andrade
 * @group             : 
 * @last modified on  : 02-02-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   02-01-2021   Nelson Andrade                       Initial Version
**/
public with sharing class Loyalty_Test_Mock_GenericListviewDml implements System.StubProvider   {
    

    public  Object handleMethodCall(Object stubbedObject, String stubbedMethodName, 
        Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames, 
        List<Object> listOfArgs) {
        

        System.debug('Name of stubbed method: ' + stubbedMethodName);
        System.debug('Return type of stubbed method: ' + returnType.getName());
        
        for (integer i =0; i < listOfParamNames.size(); i++) {
            System.debug('parameter name: ' + listOfParamNames.get(i));
            System.debug('  parameter type: ' + listOfParamTypes.get(i).getName());
        }

        System.debug('number of parameters passed into the mocked call: ' + 
            listOfArgs.size());
        System.debug('parameter(s) sent into the mocked call: ' + listOfArgs);


        switch on stubbedMethodName{
            when  'getSessionIdFromVFPage'{return 'a001SaaABG0X12';}

            when  'createMetadataService'{
                return  new MetadataService.MetadataPort();
            }

            when  'getListviewsLabels'{
                
                return new List<String> {
                    'All Reward Values.AllRewardValues',
                    'My Reward Values.MyRewardValues',
                    'New This Week.NewThisWeek',
                    'New Last Week.NewLastWeek',
                    'Recently Viewed Reward Values.RecentlyViewedRewardValues'
                };
            
            }
            when  'createListview'{return 'listview created';}

            when  'deleteListView'{return 'listview deleted';}

            when  'getListviewColumns'{
                
                return new List<String> {
                      'Name',
                      'CreatedbyUserAlias',
                      'CreatedDate',
                      'UpdatedbyUserAlias',
                      'LastUpdate',
                      'Is_Delivered__c',
                      'Reward_Type__c',
                      'Loyalty_Reward_Value_Code__c',
                      'Loyalty_Reward__c',
                      'Loyalty_Value__c'
                    };
            }

            when  'getListviewFilters'{
                
                return new List<MetadataService.ListViewFilter>();
            }
            
            when  'editListViewName'{return 'newListviewName';}

            when  'editListViewSharingSettings'{return 'newSharingSettings';}

            when  'editListViewFilters'{ return 'Success';}

            when  'editListViewFields'{

               return 'Success';
            }

            when  'handleSaveResults'{return 'saveSuccess';}

            when  'handleDeleteResults'{return 'deleteSuccess';}

            when else {}
        }

        return '';
    }

 
}