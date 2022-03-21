import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getListUi } from 'lightning/uiListApi';
import  { loadStyle } from 'lightning/platformResourceLoader';
import Loyalty_ButtonControl from '@salesforce/resourceUrl/Loyalty_ButtonControl';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

//  Custom Labels import
import Loyalty_Program_Setup_Rules from '@salesforce/label/c.Loyalty_Program_Setup_Rules';
import Loyalty_Page from '@salesforce/label/c.Loyalty_Page';
import Loyalty_Of from '@salesforce/label/c.Loyalty_Of';
import Loyalty_Items from '@salesforce/label/c.Loyalty_Items';
import Loyalty_Edit from '@salesforce/label/c.Loyalty_Edit';
import Loyalty_Deactivate from '@salesforce/label/c.Loyalty_Deactivate';
import Loyalty_Rule from '@salesforce/label/c.Loyalty_Rule';
import Loyalty_Status from '@salesforce/label/c.Loyalty_Status';
import Loyalty_Draft from '@salesforce/label/c.Loyalty_Draft';
import Loyalty_Review from '@salesforce/label/c.Loyalty_Review';
import Loyalty_Active from '@salesforce/label/c.Loyalty_Active';
import Loyalty_Inactive from '@salesforce/label/c.Loyalty_Inactive';
import Loyalty_Program_Name from '@salesforce/label/c.Loyalty_Program_Name';
import Loyalty_Assgning_Points from '@salesforce/label/c.Loyalty_Assgning_Points';
import Loyalty_Assgning_Points_Factor from '@salesforce/label/c.Loyalty_Assgning_Points_Factor';
import Loyalty_value_from_field from '@salesforce/label/c.Loyalty_value_from_field';
import Loyalty_Rule_Conditions_Object from '@salesforce/label/c.Loyalty_Rule_Conditions_Object';
import Loyalty_Activate_Deactivate from '@salesforce/label/c.Loyalty_Activate_Deactivate';
import Loyalty_Confirm from '@salesforce/label/c.Loyalty_Confirm';
import Loyalty_Activate_Program_Rule_Confirmation from '@salesforce/label/c.Loyalty_Activate_Program_Rule_Confirmation';
import Loyalty_Deactivate_Program_Rule_Confirmation from '@salesforce/label/c.Loyalty_Deactivate_Program_Rule_Confirmation';
import Loyalty_Activate_Program_Rule_Message from '@salesforce/label/c.Loyalty_Activate_Program_Rule_Message';
import Loyalty_Deactivate_Program_Rule_Message from '@salesforce/label/c.Loyalty_Deactivate_Program_Rule_Message';
import Loyalty_Program_Setup_Rule_Edited from '@salesforce/label/c.Loyalty_Program_Setup_Rule_Edited';
import Loyalty_Error_Editing_Program_Setup_Rule from '@salesforce/label/c.Loyalty_Error_Editing_Program_Setup_Rule';

import getProgramSetupListViews from '@salesforce/apex/Loyalty_Ctrl_ProgramSetupRulesList.getProgramSetupRuleListViews';
import getProgramSetupRules from '@salesforce/apex/Loyalty_Ctrl_ProgramSetupRulesList.getProgramSetupRules';
import getProgramSetupRulesCount from '@salesforce/apex/Loyalty_Ctrl_ProgramSetupRulesList.getProgramSetupRulesCount';
import editProgramSetupRule from '@salesforce/apex/Loyalty_Ctrl_ProgramSetupRulesList.editProgramSetupRule';

// import PROGRAM_SETUP_OBJECT from '@salesforce/schema/Loyalty_Program_Setup__c';
// import NAME_FIELD from '@salesforce/schema/Loyalty_Program_Setup__c.Name';

export default class loyalty_lWC_ProgramSetupRulesList extends NavigationMixin(LightningElement) {
    /* -------------------- global variables -------------------*/
    label = {
        Loyalty_Program_Setup_Rules,
        Loyalty_Page,
        Loyalty_Of,
        Loyalty_Items,
        Loyalty_Edit,
        Loyalty_Deactivate,
        Loyalty_Rule,
        Loyalty_Status,
        Loyalty_Draft,
        Loyalty_Review,
        Loyalty_Active,
        Loyalty_Inactive,
        Loyalty_Program_Name,
        Loyalty_Assgning_Points,
        Loyalty_Assgning_Points_Factor,
        Loyalty_value_from_field,
        Loyalty_Rule_Conditions_Object,
        Loyalty_Activate_Deactivate,
        Loyalty_Confirm,
        Loyalty_Activate_Program_Rule_Confirmation,
        Loyalty_Deactivate_Program_Rule_Confirmation,
        Loyalty_Activate_Program_Rule_Message,
        Loyalty_Deactivate_Program_Rule_Message,
        Loyalty_Program_Setup_Rule_Edited,
        Loyalty_Error_Editing_Program_Setup_Rule
    };

    tableActions = [
        { label: this.label.Loyalty_Edit, name: 'show_details' },
        { label: this.label.Loyalty_Activate_Deactivate, name: 'deactivate', cellAttributes: { class: { fieldName: 'cssClass' } } }
    ];

    programSetupColumns = [
        { label: this.label.Loyalty_Rule, fieldName: 'RuleName' },
        {
            label: this.label.Loyalty_Status,
            fieldName: 'RuleStatus',
            sortable: true,
            cellAttributes: { alignment: 'center' },
            type: 'customLabel',
            typeAttributes: {
                labelAttributes: {
                    class: 'slds-text-heading_small slds-text-title_caps',
                    classRules: [
                        { value: this.label.Loyalty_Draft, class: "slds-box slds-theme_info slds-text-color_inverse" },
                        { value: this.label.Loyalty_Review, class: "slds-box slds-theme_warning slds-text-color_inverse" },
                        { value: this.label.Loyalty_Active, class: "slds-box slds-theme_success slds-text-color_inverse" },
                        { value: this.label.Loyalty_Inactive, class: "slds-box slds-theme_error slds-text-color_inverse" }
                    ]
                }
            }
        },
        {
            label: this.label.Loyalty_Program_Name,
            fieldName: 'ProgramName',
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: this.label.Loyalty_Rule_Conditions_Object,
            fieldName: 'RulesObject',
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: this.label.Loyalty_Assgning_Points, fieldName: 'AssignPoints', type: 'customLabel',
            typeAttributes: {
                labelAttributes: {
                    class: 'slds-badge slds-badge_lightest',
                    useIcon: true,
                    icon: {
                        class: 'slds-badge__icon slds-badge__icon_right',
                        position: "right",
                        name: "utility:favorite",
                        title: "Points",
                        size: "xx-small"
                    }
                }
            }
        },
        {
            label: this.label.Loyalty_Assgning_Points_Factor, fieldName: 'PointsFactorColumn', type: 'customLabel',
            typeAttributes: {
                labelAttributes: {
                    class: 'slds-badge',
                    useIcon: false
                }
            }
        },
        { type: 'action', typeAttributes: { rowActions: this.tableActions } }
    ];

    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    totalpages;
    localCurrentPage = null;
    isSearchChangeExecuted = false;
    loadMoreStatus;

    /* -------------------- tracked variables -------------------*/
    @api currentpage = 1;
    @api pagesize = 10;
    @api totalrecords;
    @track searchKey = null;
    @track programSetups = [];
    @track isNoProgramSetupListViews = true;
    @track programSetupListViews;
    @track error;
    @track isEditingBonusRule = false;
    @track editingBonusRuleId = false;
    @track isConfirmActivateDeactivateRule = false;
    @track activateDeactivateRuleId;
    @track ruleNewStatus;
    @track activateDeactivateRuleTitle;
    @track activateDeactivateRuleMessage;

    /* -------------------- wired methods -------------------*/
    // @wire(getListUi, {
    //     objectApiName: PROGRAM_SETUP_OBJECT,
    //     listViewApiName: 'All',
    //     sortBy: NAME_FIELD,
    //     pageSize: 10
    // })
    // listView;

    @wire(getProgramSetupRulesCount, { searchString: '$searchKey' })
    wiredGetProgramSetupRulesCount(result) {
        if (result.data) {
            this.totalrecords = result.data;  
            this.totalpages = Math.ceil(this.totalrecords / this.pagesize);
        }
    }

    // @wire(getProgramSetupRules, { pagenumber: '$currentpage', pageSize: '$pagesize', searchString: '$searchKey' })
    // wiredGetProgramSetupRules(result) {
    //     if (result.data) {
    //         this.processProgramSetupRulesResult(result.data);
    //     }
    // }

    connectedCallback() {
        loadStyle(this, Loyalty_ButtonControl);
        this.loadBonusRulesData(false);
    }

    loadBonusRulesData(isAddedData){
        return  getProgramSetupRules({ pagenumber: this.currentpage, pageSize : this.pagesize, lastRecordPosition: this.programSetups.length, isAddedData: isAddedData, searchString: this.searchKey })
        .then(result => {
            console.log(result);
            
            console.log(this.currentpage, this.totalpages, this.currentpage < this.totalpages);
            if (this.currentpage < this.totalpages) {
                console.log(this.currentpage, this.totalpages, this.currentpage < this.totalpages);
                this.currentpage = this.currentpage+1;
            }
            this.processProgramSetupRulesResult(result);
        })
        .catch(error => {
            console.log(error);
        });
    }

    loadMoreData(event) {
        console.log('Load more JS made');
        if (this.programSetups.length < this.totalrecords) {
            const { target } = event;
            target.isLoading = true;

            this.loadBonusRulesData(false)
                .then(()=> {
                    target.isLoading = false;
                    // if (this.currentpage >= this.totalpages) {
                    //     target.enableInfiniteLoading = false;
                    // }
                });
        }
    }

    processProgramSetupRulesResult(returnedProgramSetups) {
        let preparedAssets = [];
        for (var key in returnedProgramSetups) {
            let preparedAsset = {};
            preparedAsset.Id = returnedProgramSetups[key].Id;
            preparedAsset.LoyaltyProgramId = returnedProgramSetups[key].Loyalty_Program_Setup__r.Loyalty_Program__c;
            preparedAsset.RuleName = returnedProgramSetups[key].Name;
            preparedAsset.ProgramName = returnedProgramSetups[key].Loyalty_Program_Setup__r.Loyalty_Program__r.Name;
            preparedAsset.RuleStatus = returnedProgramSetups[key].Rule_Status__c;
            preparedAsset.PointsPerValueSpent = returnedProgramSetups[key].Loyalty_Program_Setup__r.Points_Per_Value_Spent__c;
            preparedAsset.AssignPoints = returnedProgramSetups[key].Assign_Points__c;
            if (returnedProgramSetups[key].Assign_Points_Factor__c) {
                preparedAsset.PointsFactorType = returnedProgramSetups[key].Assign_Points_Factor_Type__c;
                if (returnedProgramSetups[key].Assign_Points_Field_Value_Name__c){
                    preparedAsset.PointsFactorTypeValue = returnedProgramSetups[key].Assign_Points_Field_Value_Name__c;
                    preparedAsset.PointsFactorTypeValueIsField = true;
                }
                else {
                    preparedAsset.PointsFactorTypeValue = returnedProgramSetups[key].Assign_Points_Factor_Type_Value__c;
                    preparedAsset.PointsFactorTypeValueIsField = false;
                }
                preparedAsset.PointsFactorOperator = returnedProgramSetups[key].Assign_Points_Factor_Operator__c;
                preparedAsset.PointsFactor = returnedProgramSetups[key].Assign_Points_Factor__c;
                preparedAsset = this.buildPointsFactorColumn(preparedAsset);
            }
            else {
                preparedAsset.PointsFactorColumn = "*1";
            }
            if (returnedProgramSetups[key].Object_Rules__c) {
                let temp = JSON.parse(returnedProgramSetups[key].Object_Rules__c);
                preparedAsset.RulesObject = temp.objectName;
            }
            preparedAsset.cssClass= 'hide-deactivate-button';
            preparedAssets.push(preparedAsset);
        }
        console.log('rules: ',preparedAssets);
        let updatedRecords = [...this.programSetups, ...preparedAssets];
        this.programSetups = updatedRecords;
    }

    buildPointsFactorColumn(preparedAsset) {
        preparedAsset.PointsFactorColumn = "*";
        if (preparedAsset.PointsFactorTypeValueIsField) {
            let temp = preparedAsset.PointsFactorTypeValue.split('|');
            preparedAsset.PointsFactorColumn += this.label.Loyalty_value_from_field + " '" + temp[0] + "' ";
        }
        else {
            preparedAsset.PointsFactorColumn += preparedAsset.PointsFactorTypeValue + " (" + preparedAsset.PointsFactorType + ") ";

        }
        preparedAsset.PointsFactorColumn += preparedAsset.PointsFactorOperator + " " + preparedAsset.PointsFactor;
        return preparedAsset;
    }

    @wire(getProgramSetupListViews)
    wiredGetProgramSetupListViews(result) {
        if (result.data) {
            this.programSetupListViews = result.data;
            if (this.programSetupListViews.length > 0) {
                this.isNoProgramSetupListViews = false;
            }
            else {
                this.isNoProgramSetupListViews = true;
            }
        }
        else {
            this.isNoProgramSetupListViews = true;
        }
    }

    /* -------------------- DOM functions -------------------*/
    // Used to sort the column
    sortBy(field, reverse, primer) {
        console.log(field, reverse.primer);
        const key = primer
            ? function (x) {
                return primer(x[field]);
            }
            : function (x) {
                return x[field];
            };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        console.log(event);
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.programSetups];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.programSetups = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    handleLoyaltyPrevious() {
        if (this.currentpage > 1) {
            this.currentpage = this.currentpage - 1;
        }
    }
    handleLoyaltyNext() {
        if (this.currentpage < this.totalpages)
            this.currentpage = this.currentpage + 1;
    }
    handleLoyaltyFirst() {
        this.currentpage = 1;
    }
    handleLoyaltyLast() {
        this.currentpage = this.totalpages;
    }

    /* -------------------- Data functions -------------------*/
    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'show_details':
                this.isEditingBonusRule = true;
                this.editingBonusRuleId = row.Id;
                //this.navigateToEditRulePage(row.Id);
                break;
            case 'deactivate':
                this.displayConfirmModal(row);
                break;
        }
    }

    displayConfirmModal(rowData) {
        //alert('Deactivate: ' + row.Id + row.RuleStatus);
        this.activateDeactivateRuleId = rowData.Id;
        if (rowData.RuleStatus == 'Active') {
            this.ruleNewStatus = 'Inactive';
            this.activateDeactivateRuleTitle = this.label.Loyalty_Deactivate_Program_Rule_Confirmation;
            this.activateDeactivateRuleMessage = this.label.Loyalty_Deactivate_Program_Rule_Message.replace('{0}',rowData.RuleName);
        }
        else {
            this.ruleNewStatus = 'Active';
            this.activateDeactivateRuleTitle = this.label.Loyalty_Activate_Program_Rule_Confirmation;
            this.activateDeactivateRuleMessage = this.label.Loyalty_Activate_Program_Rule_Message.replace('{0}',rowData.RuleName);
        }
        this.isConfirmActivateDeactivateRule = true;
    }

    // Navigate to Edit Account Page
    navigateToEditRulePage(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Loyalty_Program_Setup_Rules__c',
                actionName: 'view'
            },
        });
        // this[NavigationMixin.GenerateUrl]({
        //     type: 'standard__recordPage',
        //     attributes: {
        //         recordId: recordId,
        //         objectApiName: 'Loyalty_Program_Setup_Rules__c',
        //         actionName: 'view'
        //     },
        // }).then(url => {
        //     window.location.replace(url);
        // });;
    }

    handleEditBonusRuleModalClose(event) {
        console.log('closed edit modal');
        this.isEditingBonusRule = false;
        this.editingBonusRuleId = null;
    }

    handleActivateDeactivateRuleModalClose(event) {
        console.log('closed activate/deactivate modal');
        this.isConfirmActivateDeactivateRule = false;
        this.activateDeactivateRuleId = null;
        this.activateDeactivateRuleTitle = null;
        this.activateDeactivateRuleMessage = null;
    }

    handleActivateDeactivateConfirmEvent(event) {
        console.log('handleActivateDeactivateConfirmEvent', event.detail.newStatus);
        let programSetupRuleObject = {
            Id: event.detail.recordId,
            Rule_Status__c: event.detail.newStatus
        };
        this.submitEditSetupRule(programSetupRuleObject);
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
                this.currentpage = 1;
                this.pagesize = 10;
                this.programSetups = [];
                refreshApex(this.loadBonusRulesData(false)); 
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
            this.isConfirmActivateDeactivateRule = false;
            this.activateDeactivateRuleId = null;
            this.activateDeactivateRuleTitle = null;
            this.activateDeactivateRuleMessage = null;
    }

    handleNewBonusRuleCreated(event) {
        this.loadBonusRulesData(true).then(()=> {
            this.totalrecords = this.totalrecords+1;
        });
    }

    handleEditBonusRuleCreated(event) {
        this.currentpage = 1;
        this.pagesize = 10;
        this.programSetups = [];
        refreshApex(this.loadBonusRulesData(false)); 
    }
}