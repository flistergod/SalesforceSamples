import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//  Custom Labels import

import Loyalty_Close from '@salesforce/label/c.Loyalty_Close';
import Loyalty_Cancel from '@salesforce/label/c.Loyalty_Cancel';
import Loyalty_Save from '@salesforce/label/c.Loyalty_Save';
import Loyalty_NewListview from '@salesforce/label/c.Loyalty_New_ListView';
import Loyalty_List_Name from '@salesforce/label/c.Loyalty_List_Name';
import Loyalty_List_API_Name from '@salesforce/label/c.Loyalty_List_API_Name';
import Loyalty_HelpText_APIListName from '@salesforce/label/c.Loyalty_HelpText_APIListName';
import Loyalty_HelpText_ListViewVisibility from '@salesforce/label/c.Loyalty_HelpText_ListViewVisibility';
import Loyalty_RadioGroupVisibilityListview from '@salesforce/label/c.Loyalty_RadioGroupVisibilityListview';
import Loyalty_CloneListView from '@salesforce/label/c.Loyalty_CloneListView';
import Loyalty_RenameListview from '@salesforce/label/c.Loyalty_RenameListview';
import Loyalty_onlyISeeOptionRadioGroup from '@salesforce/label/c.Loyalty_onlyISeeOptionRadioGroup';
import Loyalty_optionAllUsersRadioGroup from '@salesforce/label/c.Loyalty_optionAllUsersRadioGroup';
import Loyalty_HelpTextChangeShareSettings from '@salesforce/label/c.Loyalty_HelpTextChangeShareSettings';
import Loyalty_SharingSettings from '@salesforce/label/c.Loyalty_SharingSettings';
import Loyalty_FieldsToDisplay from '@salesforce/label/c.Loyalty_FieldsToDisplay';
import Loyalty_DeleteListview from '@salesforce/label/c.Loyalty_DeleteListview';
import Loyalty_DeleteListviewBody from '@salesforce/label/c.Loyalty_DeleteListviewBody';


export default class loyalty_lWC_CreateLoyaltyRewardValueListviewModal extends LightningElement {
    options = [];
    values = [];
  
        _selected = [];
    
        get options() {
            return [
                { label: 'English', value: 'en' },
                { label: 'German', value: 'de' },
                { label: 'Spanish', value: 'es' },
                { label: 'French', value: 'fr' },
                { label: 'Italian', value: 'it' },
                { label: 'Japanese', value: 'ja' },
            ];
        }

        optionsSelected= [
                { label: 'English', value: 'en' },
                { label: 'German', value: 'de' },
                { label: 'Spanish', value: 'es' },
                { label: 'French', value: 'fr' },
                { label: 'Italian', value: 'it' },
                { label: 'Japanese', value: 'ja' },
            ];
        
    
        get selected() {
            return this._selected.length ? this._selected : 'none';
        }
    
        handleChange(e) {
            this._selected = e.detail.value;
        }
    
    
    label = {
        Loyalty_DeleteListviewBody,
        Loyalty_DeleteListview,
        Loyalty_FieldsToDisplay,
        Loyalty_SharingSettings,
        Loyalty_HelpTextChangeShareSettings,
        Loyalty_optionAllUsersRadioGroup,
        Loyalty_onlyISeeOptionRadioGroup,
        Loyalty_RenameListview,
        Loyalty_CloneListView,
        Loyalty_RadioGroupVisibilityListview,
        Loyalty_HelpText_ListViewVisibility,
        Loyalty_HelpText_APIListName,
        Loyalty_List_API_Name,
        Loyalty_List_Name,
        Loyalty_NewListview,
        Loyalty_Close,
        Loyalty_Cancel,
        Loyalty_Save,
    
    };

    @api currentlistviewAPI;
    @api currentlistview;
    @api typeofmodal;
    @api newListView=false;
    @api cloneListView=false;
    @api renameListView=false;
    @api sharingListView=false;
    @api displayFields=false;
    @api deleteListview=false;
    @api openModal = false;
    @track isMandatoryFieldsFilled = false;

    connectedCallback() {
        this.openModal=true;
        const items = [];
        for (let i = 1; i <= 10; i++) {
            items.push({
                label: `Option ${i}`,
                value: `opt${i}`,
            });
        }
        this.options.push(...items);
        this.values.push(...['opt2', 'opt4', 'opt6']);
       
        console.log(this.typeofmodal);

        switch(this.typeofmodal){
            
            case "new": this.newListView=true;  break;

            case "clone": this.cloneListView=true;
            
            this.currentlistview='Copy of '+this.currentlistview;
            const search = ' ';
            const replaceWith = '_';
    
            const result = this.currentlistview.replaceAll(search, replaceWith);
            this.currentlistviewAPI=result;
            break;

            case "rename": this.renameListView=true; break;

            case "sharing": this.sharingListView=true; break;

            case "displayFields": this.displayFields=true; break;

            case "delete": this.deleteListview=true; break;
        }  

        /*
        constructor(){}

        disconnectedCallback(){}

        render(){}

        renderedCallback(){}

        */
      //  console.log(this.newListView+" "+this.cloneListView);
    }

    showModal() {
        this.openModal = true;
        this.dataForDynamicConditionRules = [];
        this.addInnerGroup();
        this.currentStep = 1;
        this.currentStepString = "1";
        this.changeStepView();
    }
    closeModal() {
        this.openModal = false;
        this.dispatchEvent(new CustomEvent('modalclose'));
        this.typeofmodal='';
    }


    get isMandatoryDataFilled() {
        this.validateSetupRuleFields();
        return this.isMandatoryFieldsFilled;
    }

    get getMandatoryFieldsNotFilled() {
        return !this.isMandatoryFieldsFilled;
    }

    get visibilityOptions() {
        return [
            { label: this.label.Loyalty_onlyISeeOptionRadioGroup, value: this.label.Loyalty_onlyISeeOptionRadioGroup },
            { label: this.label.Loyalty_optionAllUsersRadioGroup, value: this.label.Loyalty_optionAllUsersRadioGroup },
           
        ];
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
}