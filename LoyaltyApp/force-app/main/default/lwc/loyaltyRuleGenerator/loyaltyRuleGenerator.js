import { LightningElement, api, track } from 'lwc';

//  Custom Labels import
import Loyalty_And from '@salesforce/label/c.Loyalty_And';
import Loyalty_Or from '@salesforce/label/c.Loyalty_Or';
import Loyalty_Remove_Inner_Group from '@salesforce/label/c.Loyalty_Remove_Inner_Group';
import Loyalty_Add_Field_Rule from '@salesforce/label/c.Loyalty_Add_Field_Rule';

export default class LoyaltyRuleGenerator extends LightningElement {
    @api iterationkey;
    @api sobjectfields;
    @track fieldRulesData = [];
    @api iseditting = false;
    @api editingcondition;
    @api editingrules;
    innerGroupOperator = 'AND';
    
    label = {
        Loyalty_And,
        Loyalty_Or,
        Loyalty_Remove_Inner_Group,
        Loyalty_Add_Field_Rule
    };

    get isFirstElement() {
        return Number(this.iterationkey) == 0;
    }

    addFieldRule() {
        let currentSize = this.fieldRulesData.length;
        //use spread operator (immutable data structure, do not use .push() )
        this.fieldRulesData = [
            ...this.fieldRulesData,
            {
                requiredKey: currentSize,
                fieldOperator: '=',
                fieldValue: ''
            }
        ];
    }

    changeInnerGroupCondition(event) {
        event.target.variant="brand";
        if (event.target.label == "AND") {
            this.innerGroupOperator = 'AND';
            this.template.querySelector('.or-button').variant='outline-brand';
        }
        else {
            this.innerGroupOperator = 'OR';
            this.template.querySelector('.and-button').variant='outline-brand';
        }
        this.dispatchEvent(new CustomEvent('loyaltyinnergroupcondition',
            {
                detail: { 
                    iterationValue: this.iterationkey,
                    innerGroupCondition: this.innerGroupOperator
                }
            })
        );
    }

    connectedCallback() {
        console.log('connectedCallback',this.editingrules)
        if (this.iseditting && this.editingrules) {
            this.editLoadRulesData();
        }
        else {
            this.addFieldRule();
        }
    }

    editLoadRulesData() {
        console.log(this.editingcondition);
        console.log(this.iterationkey);
        if (this.editingcondition == "AND") {
            this.innerGroupOperator = 'AND';
            //this.template.querySelector('.or-button').variant='outline-brand';
        }
        else {
            this.innerGroupOperator = 'OR';
            //this.template.querySelector('.and-button').variant='outline-brand';
        }
        if (this.editingrules) {
            let index = 0;
            let temp = [];
            this.editingrules.forEach(rule => {
                temp.push(
                    {
                        requiredKey: index,
                        fieldName: rule.fieldName,
                        fieldOperator: rule.fieldOperator,
                        fieldValue: rule.fieldValue,
                        fieldType: rule.fieldValueType
                    }
                );
                index++;
            });
            this.fieldRulesData = temp;
        }
    }

    removeInnerGroup() {
        this.dispatchEvent(new CustomEvent('loyaltyremoveinnergroup', { detail: { iterationValue: this.iterationkey }}));
    }

    removeInnerGroupFieldRule(event) {
        const ruleFieldData = event.detail;
        if (ruleFieldData) {
            const fieldRuleKey = ruleFieldData.iterationValue;
            if (fieldRuleKey >= 0) {
                const index = this.fieldRulesData.findIndex(obj => obj.requiredKey === fieldRuleKey);
                this.fieldRulesData.splice(index, 1);
            }
        }
    }

    loyaltyFieldOperatorChange(event) {
        const ruleFieldData = event.detail;
        if (ruleFieldData) {
            const fieldRuleKey = ruleFieldData.iterationValue;
            if (fieldRuleKey >= 0) {
                const index = this.fieldRulesData.findIndex(obj => obj.requiredKey === fieldRuleKey);
                this.fieldRulesData[index].fieldOperator = ruleFieldData.fieldOperator;
            }
        }
        this.dispatchEvent(new CustomEvent('loyaltyinnergrouprules',
            {
                detail: { 
                    iterationValue: this.iterationkey,
                    innerGroupRules: this.fieldRulesData
                }
            })
        );
        
    }

    loyaltyFieldNameChange(event) {
        const ruleFieldData = event.detail;
        if (ruleFieldData) {
            const fieldRuleKey = ruleFieldData.iterationValue;
            if (fieldRuleKey >= 0) {
                const index = this.fieldRulesData.findIndex(obj => obj.requiredKey === fieldRuleKey);
                this.fieldRulesData[index].fieldName = ruleFieldData.fieldName;
                this.fieldRulesData[index].fieldType = ruleFieldData.fieldType;
            }
        }
        
        this.dispatchEvent(new CustomEvent('loyaltyinnergrouprules',
            {
                detail: { 
                    iterationValue: this.iterationkey,
                    innerGroupRules: this.fieldRulesData
                }
            })
        );
    }
    
    loyaltyFieldValueChange(event) {
        const ruleFieldData = event.detail;
        if (ruleFieldData) {
            const fieldRuleKey = ruleFieldData.iterationValue;
            if (fieldRuleKey >= 0) {
                const index = this.fieldRulesData.findIndex(obj => obj.requiredKey === fieldRuleKey);
                this.fieldRulesData[index].fieldValue = ruleFieldData.fieldValue;
            }
        }
       
        this.dispatchEvent(new CustomEvent('loyaltyinnergrouprules',
            {
                detail: { 
                    iterationValue: this.iterationkey,
                    innerGroupRules: this.fieldRulesData
                }
            })
        );
    }
}