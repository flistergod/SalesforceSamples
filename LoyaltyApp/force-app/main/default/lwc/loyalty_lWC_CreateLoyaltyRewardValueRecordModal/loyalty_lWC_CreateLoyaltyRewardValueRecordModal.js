import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//  Custom Labels import
import Loyalty_Close from '@salesforce/label/c.Loyalty_Close';
import Loyalty_Cancel from '@salesforce/label/c.Loyalty_Cancel';
import Loyalty_Save from '@salesforce/label/c.Loyalty_Save';
import Loyalty_Factor_Type_Value from '@salesforce/label/c.Loyalty_Factor_Type_Value';
import Loyalty_CreateNewRewardValue from '@salesforce/label/c.Loyalty_CreateNewRewardValue';
import Loyalty_EditRewardValue from '@salesforce/label/c.Loyalty_EditRewardValue';
import Loyalty_NewRewardValue from '@salesforce/label/c.Loyalty_NewRewardValue';


//apex functions
import getRewardValueData from '@salesforce/apex/Loyalty_Ctrl_LoyaltyRewardValuesList.getRewardValueData';
import createRewardValue from '@salesforce/apex/Loyalty_Ctrl_LoyaltyRewardValuesList.createRewardValue';
import editRewardValue from '@salesforce/apex/Loyalty_Ctrl_LoyaltyRewardValuesList.editRewardValue';

export default class Loyalty_LWC_CreateLoyaltyRewardValueNewListViewModal extends LightningElement {
   
    label = {
        Loyalty_EditRewardValue,
        Loyalty_NewRewardValue,
        Loyalty_CreateNewRewardValue,
        Loyalty_Close,
        Loyalty_Cancel,
        Loyalty_Save,
        Loyalty_Factor_Type_Value
    };

    @track ruleId;
    @api openModal = false;
    @api isedit=false;
    @api rewardvalueid;
    @track ruleName='';
    @track ruleIsDelivered=false;
    @track ruleLoyaltyReward = '';
    @track ruleLoyaltyValue = '';
    @track ruleRewardType='';
    @track isMandatoryFieldsFilled = false;

    /*----------------------------------------------------cycle methods-----------------------------------------------*/

    connectedCallback() {
      
        if (this.isedit) {
            this.editLoadRewardValueData();
            this.openModal=true;
        }  
    }

     /*----------------------------------------------------getters----------------------------------------------------*/

    get rewardValueTitle(){
        if(this.isedit){
            return Loyalty_EditRewardValue;

        }
        else{return Loyalty_NewRewardValue;}
    }

    get getMandatoryFieldsNotFilled() {
        return this.validateSetupRuleFields();
    }

     /*----------------------------------------------------modal actions-----------------------------------------------*/

    showModal() {
        this.openModal = true;
        this.dataForDynamicConditionRules = [];
        this.addInnerGroup();
        this.currentStep = 1;
        this.currentStepString = "1";
      //  this.changeStepView();
    }
    closeModal() {
        this.openModal = false;
        this.isedit=false;
        this.dispatchEvent(new CustomEvent('modalclose'));
    }

     /*----------------------------------------------------field handlers-----------------------------------------------*/

    handleRuleNameChange(event) {
        this.ruleName = event.detail.value;
    }

    handleRuleIsDeliveredChange(event) {
      
        this.ruleIsDelivered = event.detail.checked;
     
    }

    handleRuleLoyaltyRewardChange(event) {
        if (event.detail.value && event.detail.value.length > 0) {
            this.ruleLoyaltyReward = event.detail.value[0];
        }
    }

    handleRuleLoyaltyValueChange(event) {
        if (event.detail.value && event.detail.value.length > 0) {
            this.ruleLoyaltyValue = event.detail.value[0];
        }
       
    }

    handleRuleRewardTypeChange(event) {
        this.ruleRewardType = event.detail.value;

      
    }

    validateSetupRuleFields() {
        let allValid = false;
        
        if(this.ruleName=='' || this.ruleLoyaltyReward=='' || this.ruleLoyaltyValue=='' 
        ||this.ruleRewardType==''){
            allValid=true;

        }
        
        return allValid;
    }

  
   /*----------------------------------------------------data handlers-----------------------------------------------*/

    editLoadRewardValueData() {
        //console.log(this.rewardvalueid);
        getRewardValueData({rewardValueId: this.rewardvalueid})
                .then(rewardValue => {
                  
                   // console.log(rewardValue);
                   this.ruleId=rewardValue.Id;
                   this.ruleName=rewardValue.Name;
                   this.ruleIsDelivered=rewardValue.Is_Delivered__c;
                   this.ruleLoyaltyReward=rewardValue.Loyalty_Reward__c;
                   this.ruleLoyaltyValue=rewardValue.Loyalty_Value__c;
                   this.ruleRewardType=rewardValue.Reward_Type__c;

                })
                .catch((error) => {
                    console.log(error)
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error getting Program Setup Bonus Rule record',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                });
    }

    submitNewRewardValue() {
      
        if(this.validateSetupRuleFields()==false) {
        
           // console.log(rewarValueObject)
           if(this.isedit=false){
            let rewarValueObject = {
                Name: this.ruleName,
                Is_Delivered__c: this.ruleIsDelivered,
                Loyalty_Reward__c: this.ruleLoyaltyReward,
                Loyalty_Value__c: this.ruleLoyaltyValue,
                Reward_Type__c:this.ruleRewardType
            };
        
        createRewardValue({rewardValueJson: JSON.stringify(rewarValueObject)})
                .then(newRewardValue => {

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Reward Value "' + newRewardValue + '" created',
                            variant: 'success'
                        })
                    );
                    setTimeout(function() {
                        this.dispatchEvent(new CustomEvent('newrewardvalue', { detail: newRewardValue}));
                        this.closeModal();
                    }.bind(this),1000);
                    
                })
                .catch((error) => {
                    
                    console.log(error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating Reward Value record',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );  
                });
            }
            else{
                let rewarValueObject = {
                    Id:this.ruleId,
                    Name: this.ruleName,
                    Is_Delivered__c: this.ruleIsDelivered,
                    Loyalty_Reward__c: this.ruleLoyaltyReward,
                    Loyalty_Value__c: this.ruleLoyaltyValue,
                    Reward_Type__c:this.ruleRewardType
                };
            
                editRewardValue({rewardValueJson: JSON.stringify(rewarValueObject)})
                .then(newRewardValue => {
               
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Reward Value "' + newRewardValue + '" edited',
                            variant: 'success'
                        })
                    );
                    setTimeout(function() {
                        this.dispatchEvent(new CustomEvent('newrewardvalue', { detail: newRewardValue}));
                        this.closeModal();
                    }.bind(this),1000);  
                })
                .catch((error) => {
                    
                    console.log(error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error editing Reward Value record',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );    
                });
            }
            }
    }    
}