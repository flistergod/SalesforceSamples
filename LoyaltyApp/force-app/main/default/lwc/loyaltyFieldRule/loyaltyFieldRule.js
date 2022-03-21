import { LightningElement, api } from 'lwc';

//  Custom Labels import
import Loyalty_Remove_Field_Rule from '@salesforce/label/c.Loyalty_Remove_Field_Rule';
import Loyalty_Field from '@salesforce/label/c.Loyalty_Field';
import Loyalty_Select_Field from '@salesforce/label/c.Loyalty_Select_Field';
import Loyalty_Operator from '@salesforce/label/c.Loyalty_Operator';
import Loyalty_Select_Operator from '@salesforce/label/c.Loyalty_Select_Operator';
import Loyalty_Value from '@salesforce/label/c.Loyalty_Value';

export default class LoyaltyFieldRule extends LightningElement {
    @api iterationkey;
    @api sobjectfields;
    @api iseditting=false;
    @api iterationdata;
    operatorValue = '=';
    selectedFieldValue;
    selectedValue;

    label = {
        Loyalty_Remove_Field_Rule,
        Loyalty_Field,
        Loyalty_Select_Field,
        Loyalty_Operator,
        Loyalty_Select_Operator,
        Loyalty_Value
    };

    connectedCallback() {
        if (this.iseditting) {
            this.editLoadConditionData();
        }
    }

    editLoadConditionData() {
        if (this.iterationdata) {
            this.selectedValue = this.iterationdata.fieldValue;
            this.selectedFieldValue = this.iterationdata.fieldName + '|' + this.iterationdata.fieldType;
            this.operatorValue = this.iterationdata.fieldOperator;
        }
    }

    get isFirstElement() {
        return Number(this.iterationkey) == 0;
    }

    get operatorOptions() {
        return [
            { label: '=', value: '=' },
            { label: '>=', value: '>=' },
            { label: '<=', value: '<=' },
            { label: '>', value: '>' },
            { label: '<', value: '<' },
            { label: '!=', value: '!=' },
        ];
    }

    get sobjectFields() {
        let fieldsArray = [];
        for (let index in this.sobjectfields) {
            fieldsArray.push({ label: this.sobjectfields[index].fieldLabel, value: this.sobjectfields[index].fieldName + '|' + this.sobjectfields[index].fieldType })
        }
        return fieldsArray;
    }

    removeFieldRule(event) {
        this.dispatchEvent(new CustomEvent('loyaltyremovefieldrule', { detail: { iterationValue: this.iterationkey }}));
    }

    handleOperatorChange(event) {
        this.operatorValue = event.detail.value;
        this.dispatchEvent(new CustomEvent('loyaltyoperatorchange',
            { 
                detail: { 
                    iterationValue: this.iterationkey,
                    fieldOperator: this.operatorValue
                }
            })
        );
    }
    
    handleFieldChange(event) {
        this.selectedFieldValue = event.detail.value;
        let fieldValue = null;
        let fieldType = null;
        if (this.selectedFieldValue) {
            let splittedFieldValueType = this.selectedFieldValue.split('|');
            fieldValue = splittedFieldValueType[0];
            fieldType = splittedFieldValueType[1];
        }
        this.dispatchEvent(new CustomEvent('loyaltyfieldchange',
            { 
                detail: { 
                    iterationValue: this.iterationkey,
                    fieldName: fieldValue,
                    fieldType: fieldType
                }
            })
        );
    }

    handleValueChange(event) {
        this.selectedValue = event.target.value;
        if (this.selectedValue && this.selectedValue != '') {
            this.dispatchEvent(new CustomEvent('loyaltyvaluechange',
            { 
                detail: { 
                    iterationValue: this.iterationkey,
                    fieldValue: this.selectedValue
                }
            })
        );
        }
    }
}