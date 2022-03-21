import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//  Custom Labels import
import Loyalty_New_Setup_Rule from '@salesforce/label/c.Loyalty_New_Setup_Rule';
import Loyalty_New_Program_Setup_Rule from '@salesforce/label/c.Loyalty_New_Program_Setup_Rule';
import Loyalty_Edit_Program_Setup_Rule from '@salesforce/label/c.Loyalty_Edit_Program_Setup_Rule';
import Loyalty_Close from '@salesforce/label/c.Loyalty_Close';
import Loyalty_Cancel from '@salesforce/label/c.Loyalty_Cancel';
import Loyalty_Back from '@salesforce/label/c.Loyalty_Back';
import Loyalty_Save from '@salesforce/label/c.Loyalty_Save';
import Loyalty_Next from '@salesforce/label/c.Loyalty_Next';
import Loyalty_General_Information from '@salesforce/label/c.Loyalty_General_Information';
import Loyalty_Bonus_Conditions from '@salesforce/label/c.Loyalty_Bonus_Conditions';
import Loyalty_Bonus_Actions from '@salesforce/label/c.Loyalty_Bonus_Actions';
import Loyalty_Bonus_Summary from '@salesforce/label/c.Loyalty_Bonus_Summary';
import Loyalty_Add_Inner_Group from '@salesforce/label/c.Loyalty_Add_Inner_Group';
import Loyalty_Running_Time from '@salesforce/label/c.Loyalty_Running_Time';
import Loyalty_Valid_From from '@salesforce/label/c.Loyalty_Valid_From';
import Loyalty_Valid_To from '@salesforce/label/c.Loyalty_Valid_To';
import Loyalty_Limitations from '@salesforce/label/c.Loyalty_Limitations';
import Loyalty_Custom_Behaviour_Description from '@salesforce/label/c.Loyalty_Custom_Behaviour_Description';
import Loyalty_Times_Per from '@salesforce/label/c.Loyalty_Times_Per';
import Loyalty_Assign_Points from '@salesforce/label/c.Loyalty_Assign_Points';
import Loyalty_Type from '@salesforce/label/c.Loyalty_Type';
import Loyalty_Fixed_Value from '@salesforce/label/c.Loyalty_Fixed_Value';
import Loyalty_Points from '@salesforce/label/c.Loyalty_Points';
import Loyalty_Factor from '@salesforce/label/c.Loyalty_Factor';
import Loyalty_Mandatory_Information_Not_Filled from '@salesforce/label/c.Loyalty_Mandatory_Information_Not_Filled';
import Loyalty_Without_Bonus_Conditions_Defined from '@salesforce/label/c.Loyalty_Without_Bonus_Conditions_Defined';
import Loyalty_Status from '@salesforce/label/c.Loyalty_Status';
import Loyalty_Opportunity from '@salesforce/label/c.Loyalty_Opportunity';
import Loyalty_Order from '@salesforce/label/c.Loyalty_Order';
import Loyalty_Select_Object from '@salesforce/label/c.Loyalty_Select_Object';
import Loyalty_Select_Object_Placeholder from '@salesforce/label/c.Loyalty_Select_Object_Placeholder';
import Loyalty_Times_Per_Select_Placeholder from '@salesforce/label/c.Loyalty_Times_Per_Select_Placeholder';
import Loyalty_Program_Setup from '@salesforce/label/c.Loyalty_Program_Setup';
import Loyalty_Factor_Type from '@salesforce/label/c.Loyalty_Factor_Type';
import Loyalty_Select_Factor_Type from '@salesforce/label/c.Loyalty_Select_Factor_Type';
import Loyalty_Number_of_Purchases from '@salesforce/label/c.Loyalty_Number_of_Purchases';
import Loyalty_Field_Value from '@salesforce/label/c.Loyalty_Field_Value';
import Loyalty_Factor_Operator from '@salesforce/label/c.Loyalty_Factor_Operator';
import Loyalty_Products_Quantity from '@salesforce/label/c.Loyalty_Products_Quantity';
import Loyalty_Factor_Type_Value from '@salesforce/label/c.Loyalty_Factor_Type_Value';
import Loyalty_Field from '@salesforce/label/c.Loyalty_Field';
import Loyalty_Select_Field from '@salesforce/label/c.Loyalty_Field';
import Loyalty_Program_Setup_Rule_Created from '@salesforce/label/c.Loyalty_Program_Setup_Rule_Created';
import Loyalty_Program_Setup_Rule_Edited from '@salesforce/label/c.Loyalty_Program_Setup_Rule_Edited';
import Loyalty_Error_Creating_Program_Setup_Rule from '@salesforce/label/c.Loyalty_Error_Creating_Program_Setup_Rule';
import Loyalty_Error_Editing_Program_Setup_Rule from '@salesforce/label/c.Loyalty_Error_Editing_Program_Setup_Rule';

import getProgramSetupRuleFields from '@salesforce/apex/Loyalty_Ctrl_ProgramSetupRulesList.getProgramSetupRuleFields';
import createProgramSetupRule from '@salesforce/apex/Loyalty_Ctrl_ProgramSetupRulesList.createProgramSetupRule';
import editProgramSetupRule from '@salesforce/apex/Loyalty_Ctrl_ProgramSetupRulesList.editProgramSetupRule';
import getProgramSetupRuleData from '@salesforce/apex/Loyalty_Ctrl_ProgramSetupRulesList.getProgramSetupRuleData';

export default class Loyalty_LWC_CreateLoyaltySetupRuleModal extends LightningElement {
    label = {
        Loyalty_New_Setup_Rule,
        Loyalty_New_Program_Setup_Rule,
        Loyalty_Edit_Program_Setup_Rule,
        Loyalty_Program_Setup_Rule_Created,
        Loyalty_Program_Setup_Rule_Edited,
        Loyalty_Error_Creating_Program_Setup_Rule,
        Loyalty_Error_Editing_Program_Setup_Rule,
        Loyalty_General_Information,
        Loyalty_Bonus_Conditions,
        Loyalty_Bonus_Actions,
        Loyalty_Bonus_Summary,
        Loyalty_Add_Inner_Group,
        Loyalty_Close,
        Loyalty_Cancel,
        Loyalty_Back,
        Loyalty_Save,
        Loyalty_Next,
        Loyalty_Running_Time,
        Loyalty_Valid_From,
        Loyalty_Valid_To,
        Loyalty_Limitations,
        Loyalty_Custom_Behaviour_Description,
        Loyalty_Times_Per,
        Loyalty_Assign_Points,
        Loyalty_Type,
        Loyalty_Fixed_Value,
        Loyalty_Factor,
        Loyalty_Points,
        Loyalty_Mandatory_Information_Not_Filled,
        Loyalty_Without_Bonus_Conditions_Defined,
        Loyalty_Status,
        Loyalty_Opportunity,
        Loyalty_Order,
        Loyalty_Select_Object,
        Loyalty_Select_Object_Placeholder,
        Loyalty_Times_Per_Select_Placeholder,
        Loyalty_Program_Setup,
        Loyalty_Factor_Type,
        Loyalty_Select_Factor_Type,
        Loyalty_Number_of_Purchases,
        Loyalty_Field_Value,
        Loyalty_Field,
        Loyalty_Select_Field,
        Loyalty_Factor_Operator,
        Loyalty_Products_Quantity,
        Loyalty_Factor_Type_Value
    };

    statusLabelAttributes = {
        class: 'slds-text-heading_small slds-text-title_caps',
        classRules: [
            { value: "Draft", class: "slds-box slds-theme_info slds-text-color_inverse" },
            { value: "Review", class: "slds-box slds-theme_warning slds-text-color_inverse" },
            { value: "Active", class: "slds-box slds-theme_success slds-text-color_inverse" },
            { value: "Inactive", class: "slds-box slds-theme_error slds-text-color_inverse" }
        ]
    }

    @track modalTitle = this.label.Loyalty_New_Program_Setup_Rule;
    @api openModal = false;
    @api isedit = false;
    @api bonusruleid;
    @track ruleName;
    @track ruleStatus = 'Draft';
    @track ruleProgramSetupId = '';
    ruleDescription = '';
    @track currentStep = 1;
    @track currentStepString = "1";
    lastStep = 3;
    @track dataForDynamicConditionRules = [];
    @track setupRuleFields = [];
    @track objectSelectedValue = 'Opportunity';
    @track runningTimeChecked = false;
    @track limitationsChecked = false;
    @track minValidFromDate = new Date();
    @track minValidToDate = new Date();
    validFromDate;
    validToDate;
    @track validFromDateString;
    @track validToDateString;
    @track behaviourNumber;
    @track behaviourFactor = "0";
    behaviourSelectedLabel = "Lifetime";
    assignPointsOptionValue = 'fixed';
    @track isRunningTimeRequired = false;
    @track isLimitationsRequired = false;
    @track assignPointsValue;
    @track assignPointsFactorValue;
    @track selectedFactorType = 'Number of Purchases';
    @track selectedFactorOperator = '/';
    @track assignFactorTypeValue;
    @track selectedField;
    @track isPointsFactorRequired = false;
    @track isFactorTypeFieldRequired;
    @track isFactorTypeFieldNotRequired;
    @track isPointsFactorNotRequired = !this.isPointsFactorRequired;
    @track isMandatoryFieldsFilled = false;

    connectedCallback() {
        if (this.isedit) {
            this.modalTitle = this.label.Loyalty_Edit_Program_Setup_Rule;
            this.editLoadBonusRuleData();
            this.openModal=true;
        }
    }

    @wire(getProgramSetupRuleFields, { objectName: '$objectSelectedValue' })
    wiredGetProgramSetupRuleFields(result) {
        if (result.data) {
            this.setupRuleFields = JSON.parse(result.data);
            this.dataForDynamicConditionRules = [];
            console.log(this.dataForDynamicConditionRules);
            if (!this.isedit) {
                this.addInnerGroup();
            }
        }
        else if (result.error) {
            console.log(result.error);
        }
    }

    editLoadBonusRuleData() {
        console.log(this.bonusruleid);
        getProgramSetupRuleData({setupRuleId: this.bonusruleid})
                .then(setupRule => {
                    console.log('bonus rule: ', setupRule);
                    this.ruleId = setupRule.Id;
                    this.ruleName = setupRule.Name;
                    this.ruleStatus = setupRule.Rule_Status__c;
                    this.ruleProgramSetupId = setupRule.Loyalty_Program_Setup__c;
                    this.ruleDescription = setupRule.Description__c;

                    if (setupRule.Valid_From__c || setupRule.Valid_To__c) {
                        this.runningTimeChecked = true;
                        this.handleRunningTimeChange(null);
                        this.validFromDate = new Date(setupRule.Valid_From__c);
                        this.minValidFromDate = new Date(setupRule.Valid_From__c);
                        this.validFromDateString = setupRule.Valid_From__c;
                        this.validToDate = new Date(setupRule.Valid_To__c);
                        this.minValidToDate = new Date(setupRule.Valid_From__c);
                        this.validToDateString = setupRule.Valid_To__c;
                    }
                    if (setupRule.Customer_Behaviour_Factor__c) {
                        this.limitationsChecked = true;
                        this.handleLimitationsChange(null);
                        this.behaviourNumber = setupRule.Customer_Behaviour_Count__c;
                        this.behaviourFactor = "" + setupRule.Customer_Behaviour_Factor__c;
                        this.limitationsOptions.forEach(element => {
                            if (element.value == this.behaviourFactor)
                                this.behaviourSelectedLabel = element.label;
                        });
                    }
                    if(setupRule.Assign_Points_Factor__c) {
                        this.assignPointsOptionValue = 'factor';
                        this.handleRadioTypeChange(null);
                        this.assignPointsFactorValue = setupRule.Assign_Points_Factor__c;
                        this.selectedFactorType = setupRule.Assign_Points_Factor_Type__c;
                        this.selectedFactorOperator = setupRule.Assign_Points_Factor_Operator__c;
                        if (this.selectedFactorType == 'Field Value') {
                            this.handleFactorTypeChange(null);
                            this.selectedField = setupRule.Assign_Points_Field_Value_Name__c;
                        }
                        else {
                            this.handleFactorTypeChange(null);
                            this.assignFactorTypeValue = setupRule.Assign_Points_Factor_Type_Value__c;
                        }
                    }
                    this.assignPointsValue = setupRule.Assign_Points__c;
                    if (setupRule.Object_Rules__c) {
                        try {
                            let temp = JSON.parse(setupRule.Object_Rules__c);
    
                            this.objectSelectedValue = temp.objectName;
                            this.parseDynamicBonusRule(temp.rules);
                        }
                        catch(e) {}
                    }
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

    parseDynamicBonusRule(bonusRules) {
        this.dataForDynamicConditionRules = [];
        let temp = [];
        bonusRules.forEach(element => {
            temp.push({
                requiredKey: element.groupId,
                innerGroupCondition: element.innerGroupCondition,
                innerGroupRules: element.ruleConfiguration
            });
        });
        this.dataForDynamicConditionRules = temp;
        console.log('bonus rules', this.dataForDynamicConditionRules);
    }

    showModal() {
        this.openModal = true;
        this.dataForDynamicConditionRules = [];
        console.log(this.isedit);
        if (!this.isedit) {
            this.addInnerGroup();
            this.currentStep = 1;
            this.currentStepString = "1";
            this.changeStepView();
        }
    }
    closeModal() {
        this.openModal = false;
        this.dispatchEvent(new CustomEvent('modalclose'));
    }

    handleRuleNameChange(event) {
        this.ruleName = event.detail.value;
    }

    handleRuleStatusChange(event) {
        this.ruleStatus = event.detail.value;
    }

    handleRuleProgramSetupChange(event) {
        if (event.detail.value && event.detail.value.length > 0) {
            this.ruleProgramSetupId = event.detail.value[0];
        }
    }

    handleRuleDescriptionChange(event) {
        this.ruleDescription = event.detail.value;
    }

    handleFormLoad() {
        this.changeStepView();
    }

    changeStepView() {
        let currentView = '';
        switch(this.currentStep) {
            case 1: {
                currentView = 'stepOne';
                this.template.querySelector('div.stepTwo').classList.add('slds-hide');
                this.template.querySelector('div.stepThree').classList.add('slds-hide');
            } break;
            case 2: {
                currentView = 'stepTwo';
                this.template.querySelector('div.stepOne').classList.add('slds-hide');
                this.template.querySelector('div.stepThree').classList.add('slds-hide');
            } break;
            case 3: {
                currentView = 'stepThree';
                this.template.querySelector('div.stepOne').classList.add('slds-hide');
                this.template.querySelector('div.stepTwo').classList.add('slds-hide');
            } break;
            case 4: {
                currentView = 'stepFour';
                this.template.querySelector('div.stepOne').classList.add('slds-hide');
                this.template.querySelector('div.stepTwo').classList.add('slds-hide');
                this.template.querySelector('div.stepThree').classList.add('slds-hide');
            } break;
        }
        console.log(currentView);
        this.template.querySelector('div.'+currentView).classList.remove('slds-hide');
    }

    changeProgressStep(event) {
        let direction = event.target.dataset.direction;
        let stepSelected = event.target.value;
        if (direction && direction == 'back') {
            if (this.currentStep > 1) {
                this.currentStep--;
                this.currentStepString = this.currentStep.toString();
                this.changeStepView();
            }
        }
        else if (direction && direction == 'forth') {
            if (this.currentStep < this.lastStep) {
                this.currentStep++;
                this.currentStepString = this.currentStep.toString();
                this.changeStepView();
            }
        }
        else if (stepSelected && Number(stepSelected) != this.currentStep) {
            this.currentStep = Number(stepSelected);
            this.currentStepString = this.currentStep.toString();
            this.changeStepView();
        }
    }

    get isFirstStep() {
        return this.currentStep == 1;
    }

    get isLastStep() {
        return this.currentStep == this.lastStep;
    }

    get getMinValidFromDate() {
        let month = this.minValidFromDate.getMonth()+1 < 10 ? '0'+(this.minValidFromDate.getMonth()+1) : (this.minValidFromDate.getMonth()+1);
        return this.minValidFromDate.getFullYear() + '-' + month + '-' + this.minValidFromDate.getDate();
    }

    get getMinValidToDate() {
        let month = this.minValidToDate.getMonth()+1 < 10 ? '0'+(this.minValidToDate.getMonth()+1) : (this.minValidToDate.getMonth()+1);
        return this.minValidToDate.getFullYear() + '-' + month + '-' + this.minValidToDate.getDate();
    }

    get isMandatoryDataFilled() {
        this.validateSetupRuleFields();
        return this.isMandatoryFieldsFilled;
    }

    get getMandatoryFieldsNotFilled() {
        return !this.isMandatoryFieldsFilled;
    }

    get assignPointsOptions() {
        return [
            { label: this.label.Loyalty_Fixed_Value, value: 'fixed' },
            { label: this.label.Loyalty_Factor, value: 'factor' },
        ];
    }

    get objectOptions() {
        return [
            { label: this.label.Loyalty_Opportunity, value: 'Opportunity' },
            { label: this.label.Loyalty_Order, value: 'Order' },
        ];
    }

    get limitationsOptions() {
        return [
            { label: 'Lifetime', value: '0' },
            { label: '12 Months', value: '12' },
            { label: '6 Months', value: '6' },
            { label: '3 Months', value: '3' },
            { label: '1 Months', value: '1' },
        ];
    }

    get validFromDateString() {
        if (this.validFromDate) {
            let month = this.validFromDate.getMonth()+1 < 10 ? '0'+(this.validFromDate.getMonth()+1) : (this.validFromDate.getMonth()+1);
            return this.validFromDate.getDate() + '-' + month + '-' + this.validFromDate.getFullYear();
        }
        else {
            return '';
        }
    }

    get validToDateString() {
        if (this.validToDate) {
            let month = this.validToDate.getMonth()+1 < 10 ? '0'+(this.validToDate.getMonth()+1) : (this.validToDate.getMonth()+1);
            return this.validToDate.getDate() + '-' + month + '-' + this.validToDate.getFullYear();
        }
        else {
            return '';
        }
    }

    get isAnyBonusConditionDefined() {
        let isBonusConditionDefined = false;
        this.dataForDynamicConditionRules.forEach(element => {
            if(element.innerGroupRules && element.innerGroupRules.length > 0) {
                isBonusConditionDefined = true;
            }
        });
        return isBonusConditionDefined;
    }

    get factorTypeOptions() {
        return [
            { label: this.label.Loyalty_Number_of_Purchases, value: 'Number of Purchases' },
            { label: this.label.Loyalty_Field_Value, value: 'Field Value' },
            { label: this.label.Loyalty_Products_Quantity, value: 'Products Quantity' }
        ];
    }

    get factorOperatorOptions() {
        return [
            { label: '/', value: '/' },
            { label: '*', value: '*' },
            { label: '>', value: '>' },
            { label: '<', value: '<' },
            { label: '>=', value: '>=' },
            { label: '<=', value: '<=' },
            { label: '=', value: '=' }
        ];
    }
    
    get sobjectFields() {
        let fieldsArray = [];
        for (let index in this.setupRuleFields) {
            fieldsArray.push({ label: this.setupRuleFields[index].fieldLabel, value: this.setupRuleFields[index].fieldName + '|' + this.setupRuleFields[index].fieldType })
        }
        return fieldsArray;
    }

    handleObjectSelectedChange(event) {
        this.objectSelectedValue = event.target.value;
    }

    handleDateValidFromChange(event) {
        this.validFromDate = new Date(event.target.value);
        this.minValidToDate = this.validFromDate;
    }

    handleDateValidToChange(event) {
        this.validToDate = new Date(event.target.value);
    }

    handleRadioTypeChange(event) {
        if (event) {
            this.assignPointsOptionValue = event.detail.value;
        }
        if (this.assignPointsOptionValue == 'fixed') {
            this.isPointsFactorRequired = false;
            this.isFactorTypeFieldRequired = false;
            this.isFactorTypeFieldNotRequired = false;
            this.isPointsFactorNotRequired = true;
            this.assignPointsValue = undefined;
            this.assignPointsFactorValue = undefined;
            this.selectedField = undefined;
            this.assignFactorTypeValue = undefined;
            this.template.querySelector('div.assignpointsfactor').classList.add('slds-hide');
            this.template.querySelector('div.assignpoints').classList.remove('slds-hide');
        }
        else if (this.assignPointsOptionValue == 'factor') {
            this.isPointsFactorRequired = true;
            this.isPointsFactorNotRequired = false;
            this.selectedFactorType = 'Number of Purchases';
            this.isFactorTypeFieldRequired = false;
            this.isFactorTypeFieldNotRequired = true;
            this.assignPointsValue = undefined;
            this.assignPointsFactorValue = undefined;
            this.selectedField = undefined;
            this.assignFactorTypeValue = undefined;
            
            this.template.querySelector('div.assignpointsfactor').classList.remove('slds-hide');
            this.template.querySelector('div.assignpoints').classList.add('slds-hide');
            this.template.querySelector('div.factor-type-field').classList.add('slds-hide');
            this.template.querySelector('div.factor-type-value').classList.remove('slds-hide');
            
        }
    }

    addInnerGroup() {
        let currentSize = this.dataForDynamicConditionRules.length;
        //use spread operator (immutable data structure, do not use .push() )
        this.dataForDynamicConditionRules = [
            ...this.dataForDynamicConditionRules,
            {
                requiredKey: currentSize,
                innerGroupCondition: "AND"
            }
        ];
    }

    removeInnerGroup(event) {
        const ruleGeneratorData = event.detail;
        if (ruleGeneratorData) {
            const innerGroupKey = ruleGeneratorData.iterationValue;
            if (innerGroupKey >= 0) {
                const index = this.dataForDynamicConditionRules.findIndex(obj => obj.requiredKey === innerGroupKey);
                this.dataForDynamicConditionRules.splice(index, 1);
            }
        }
    }

    innerGroupConditionChange(event) {
        const ruleGeneratorData = event.detail;
        if (ruleGeneratorData) {
            const innerGroupKey = ruleGeneratorData.iterationValue;
            if (innerGroupKey >= 0) {
                const index = this.dataForDynamicConditionRules.findIndex(obj => obj.requiredKey === innerGroupKey);
                this.dataForDynamicConditionRules[index].innerGroupCondition = ruleGeneratorData.innerGroupCondition;
            }
        }
    }

    innerGroupRulesChange(event) {
        const ruleGeneratorData = event.detail;
        if (ruleGeneratorData) {
            const innerGroupKey = ruleGeneratorData.iterationValue;
            if (innerGroupKey >= 0) {
                console.log(ruleGeneratorData.innerGroupRules);
                const index = this.dataForDynamicConditionRules.findIndex(obj => obj.requiredKey === innerGroupKey);
                this.dataForDynamicConditionRules[index].innerGroupRules = ruleGeneratorData.innerGroupRules;
            }
        }
    }

    handleRunningTimeChange(event) {
        if (event) {
            this.runningTimeChecked = event.target.checked;
        }
        if (this.runningTimeChecked) {
            this.isRunningTimeRequired = true;
            this.template.querySelector('div.runningTime').classList.remove('slds-hide');
            
        }
        else {
            this.isRunningTimeRequired = false;
            this.validFromDate = undefined;
            this.validToDate = undefined;
            this.template.querySelector('div.runningTime').classList.add('slds-hide');
        }
    }

    handleLimitationsChange(event) {
        if (event) {
            this.limitationsChecked = event.target.checked;
        }
        if (this.limitationsChecked) {
            this.isLimitationsRequired = true;
            this.template.querySelector('div.limitations').classList.remove('slds-hide');
            
        }
        else {
            this.isLimitationsRequired = false;
            this.behaviourNumber = undefined;
            this.behaviourFactor = undefined;
            this.template.querySelector('div.limitations').classList.add('slds-hide');
        }
    }

    handleBehaviourNumberChange(event) {
        this.behaviourNumber = event.detail.value;
    }
    
    handleBehaviourFactorChange(event) {
        this.behaviourSelectedLabel = event.target.options.find(opt => opt.value === event.detail.value).label;
        this.behaviourFactor = event.detail.value;
    }

    assignPointsChange(event) {
        this.assignPointsValue = event.detail.value;
    }

    assignPointsFactorChange(event) {
        this.assignPointsFactorValue = event.detail.value;
    }

    handleFactorTypeChange(event) {
        if (event) {
            this.selectedFactorType = event.detail.value;
        }
        if (this.selectedFactorType == 'Field Value') {
            this.isFactorTypeFieldRequired = true;
            this.isFactorTypeFieldNotRequired = false;
            this.template.querySelector('div.factor-type-field').classList.remove('slds-hide');
            this.template.querySelector('div.factor-type-value').classList.add('slds-hide');
        }
        else {
            this.isFactorTypeFieldRequired = false;
            this.isFactorTypeFieldNotRequired = true;
            this.selectedField = undefined;
            this.template.querySelector('div.factor-type-field').classList.add('slds-hide');
            this.template.querySelector('div.factor-type-value').classList.remove('slds-hide');
        }
    }

    handleFactorOperatorChange(event) {
        this.selectedFactorOperator = event.detail.value;
    }

    assignFactorTypeValueChange(event) {
        this.assignFactorTypeValue = event.detail.value;
    }

    handleFieldChange(event) {
        this.selectedField = event.detail.value;
    }

    getFieldValueType(fieldValue) {
        let fieldValueType = Number.isNaN(Number(fieldValue)) && fieldValue != 'true' && fieldValue != 'false' ? 'String' : (Number.isNaN(Number(fieldValue)) ? 'Boolean' : 'Number');
        if (fieldValueType === 'Number') {
            if (fieldValue % 1 === 0) {
                fieldValueType = 'Integer';
            }
            else if (fieldValue % 1 !== 0) {
                fieldValueType = 'Decimal';
            }
        }
        return fieldValueType;
    }

    processBonusRulesToJson() {
        let bonusRulesObject = {};
        bonusRulesObject.objectName = this.objectSelectedValue;
        bonusRulesObject.rules = [];
        
        this.dataForDynamicConditionRules.forEach(element => {
            if(element.innerGroupRules && element.innerGroupRules.length > 0) {
                let innerGroupRulesCombined = '';
                let innerRules = [];
                element.innerGroupRules.forEach(rule => {
                    let fieldValueType = this.getFieldValueType(rule.fieldValue);
                    innerRules.push({ 
                        fieldName: rule.fieldName,
                        fieldValueType: rule.fieldType ? rule.fieldType : rule.fieldValueType,
                        fieldOperator: rule.fieldOperator,
                        fieldValue: (fieldValueType == 'String' || fieldValueType == 'Time' || fieldValueType == 'DateTime' || fieldValueType == 'Date') ? '\\\'' + rule.fieldValue + '\\\'' : rule.fieldValue
                    });
                });
                bonusRulesObject.rules
                    .push({
                        groupId: element.requiredKey,
                        innerGroupCondition: element.innerGroupCondition,
                        ruleConfiguration: innerRules
                    });
            }
        });
        return bonusRulesObject;
    }

    validateSetupRuleFields() {
        let allValid = true;
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            allValid = allValid && element.reportValidity();
        });
        this.template.querySelectorAll('lightning-input').forEach(element => {
            allValid = allValid && element.reportValidity();
        });
        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            allValid = allValid && element.reportValidity();
        });
        this.isMandatoryFieldsFilled = allValid;
        return allValid;
    }

    getDatePartOnly(dateValue) {
        let month = dateValue.getMonth()+1 < 10 ? '0'+(dateValue.getMonth()+1) : (dateValue.getMonth()+1);
        return dateValue.getFullYear() + '-' + month + '-' + dateValue.getDate();
    }

    submitSetupRule() {
        if(this.validateSetupRuleFields()) {
            let bonusRulesObject = this.processBonusRulesToJson();
            console.log(bonusRulesObject);
            let programSetupRuleObject = {
                Name: this.ruleName,
                Rule_Status__c: this.ruleStatus,
                Loyalty_Program_Setup__c: this.ruleProgramSetupId,
                Description__c: this.ruleDescription,
                Assign_Points__c: this.assignPointsValue,
                Object_Rules__c: JSON.stringify(bonusRulesObject)
            };
            if (this.isedit) {
                programSetupRuleObject.Id = this.ruleId;
            }
            if (this.isRunningTimeRequired) {
                programSetupRuleObject.Valid_From__c = this.getDatePartOnly(this.validFromDate);
                programSetupRuleObject.Valid_To__c = this.getDatePartOnly(this.validToDate);
            }
            if (this.isLimitationsRequired) {
                programSetupRuleObject.Customer_Behaviour_Count__c = this.behaviourNumber;
                programSetupRuleObject.Customer_Behaviour_Factor__c = this.behaviourFactor;
            }
            if(this.assignPointsOptionValue == 'factor') {
                programSetupRuleObject.Assign_Points_Factor__c = this.assignPointsFactorValue;
                programSetupRuleObject.Assign_Points_Factor_Type__c = this.selectedFactorType;
                programSetupRuleObject.Assign_Points_Factor_Operator__c = this.selectedFactorOperator;
                if (this.selectedFactorType == 'Field Value') {
                    programSetupRuleObject.Assign_Points_Field_Value_Name__c = this.selectedField;
                }
                else {
                    programSetupRuleObject.Assign_Points_Factor_Type_Value__c =this.assignFactorTypeValue;
                }
            }
            if (this.isedit) {
                this.submitEditSetupRule(programSetupRuleObject);
            }
            else {
                this.submitNewSetupRule(programSetupRuleObject);
            }
        }
    }

    submitEditSetupRule(programSetupRuleObject) {
        editProgramSetupRule({programSetupRuleJson: JSON.stringify(programSetupRuleObject)})
            .then(setupBonus => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: this.label.Loyalty_Program_Setup_Rule_Edited.replace('{0}',setupBonus),
                        variant: 'success'
                    })
                );
                setTimeout(function() {
                    this.dispatchEvent(new CustomEvent('editbonusrule', { detail: setupBonus}));
                    this.closeModal();
                }.bind(this),1000);
            })
            .catch((error) => {
                console.log(error)
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.Loyalty_Error_Editing_Program_Setup_Rule,
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    submitNewSetupRule(programSetupRuleObject) {
        createProgramSetupRule({programSetupRuleJson: JSON.stringify(programSetupRuleObject)})
            .then(setupBonus => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: this.label.Loyalty_Program_Setup_Rule_Created.replace('{0}',setupBonus),
                        variant: 'success'
                    })
                );
                setTimeout(function() {
                    this.dispatchEvent(new CustomEvent('newbonusrule', { detail: setupBonus}));
                    this.closeModal();
                }.bind(this),1000);
            })
            .catch((error) => {
                console.log(error)
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.Loyalty_Error_Creating_Program_Setup_Rule,
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
}