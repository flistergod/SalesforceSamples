import { LightningElement, track, api } from 'lwc';
import pubsub from 'vlocity_cmt/pubsub';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
//import getrecords from '@salesforce/apex/recordTableContoller.getrecordortunities';

const columns = [
    /*{ label: 'Name', fieldName: 'recordLink', type: 'url', typeAttributes: { label:{ fieldName: "name"}, target: '_blank'} },
    { label: 'Company Number', fieldName: 'companyCharityNumber', type: 'text', typeAttributes: { label:{ fieldName: "name"}, target: '_blank'} },
    { label: 'VAT Number', fieldName: 'vatNumber', type: 'text', typeAttributes: { label:{ fieldName: "name"}, target: '_blank'} },
    { label: 'Address', fieldName: 'billingAddress', type: 'text', typeAttributes: { label:{ fieldName: "name"}, target: '_blank'} },
    { label: 'BP Number', fieldName: 'businessPartnerNumber', type: 'text', typeAttributes: { label:{ fieldName: "name"}, target: '_blank'} },
    { label: 'Account Number', fieldName: 'companyCharityNumber', type: 'text', typeAttributes: { label:{ fieldName: "name"}, target: '_blank'} }
    */
     { label: 'Name', fieldName: 'recordLink', type: 'url', typeAttributes: { label:{ fieldName: "name"}, target: '_blank'} },
    { label: 'Company Number', fieldName: 'companyCharityNumber', type: 'text', typeAttributes: { label:{ fieldName: "name"}, target: '_blank'} },
    { label: 'VAT Number', fieldName: 'vatNumber', type: 'text', typeAttributes: { label:{ fieldName: "name"}, target: '_blank'} },
    { label: 'Building No.', fieldName: 'sWAN_Billing_Building_Number__c', type: 'text', typeAttributes: { label:{ fieldName: "name"}, target: '_blank'} },
    { label: 'Street', fieldName: 'billingStreet', type: 'text', typeAttributes: { label:{ fieldName: "name"}, target: '_blank'} },
    { label: 'City', fieldName: 'billingCity', type: 'text', typeAttributes: { label:{ fieldName: "name"}, target: '_blank'} },
    { label: 'Postcode', fieldName: 'billingPostalCode', type: 'text', typeAttributes: { label:{ fieldName: "name"}, target: '_blank'} },
    { label: 'BP Number', fieldName: 'businessPartnerNumber', type: 'text', typeAttributes: { label:{ fieldName: "name"}, target: '_blank'} },
    { label: 'Account Number', fieldName: 'accountId', type: 'text', typeAttributes: { label:{ fieldName: "name"}, target: '_blank'} }
];

let preselectedrows = [];

export default class evDisplaylistaccounts extends OmniscriptBaseMixin(LightningElement) {
    @api listaccounts;
    @api selectedoptionaccount;
    @api rendertable;
    @track listdata;
    @track error;
    @track columns = columns;
    @track records; //All recordortunities available for data table    
    @track showTable = false; //Used to render table after we get the data from apex controller    
    @track recordsToDisplay = []; //Records to be displayed on the page
    @track showSearchBar; //Row number
    @track rowNumberOffset; //Row number
    @track numberRowSelection;
    //@track preselectedrows = [];
    /*
        JSON Text

    */

    connectedCallback(){
        //After DataRaptor Action LWC render Register Event
        pubsub.register('omniscript_action', {
            data: this.handleOmniAction.bind(this),
        }); 

        //After Step render Register Event
        pubsub.register('omniscript_step', {
            data: this.handleOmniStepLoadData.bind(this),
        });

        console.log('List Contacts: ', this.listaccounts);
        console.log('Render Table: ', this.rendertable);        

    }    

    //Step Event to rerender the List
    handleOmniStepLoadData(data) {
        /*switch(data.name) {
            case 'FirstStep':
                this.handleOmniFirstStepLoadData(data);
            break;
        */
        //Rendered First Time
            console.log('DataRaptor Data: ', data);
            this.showSearchBar = false;
            this.numberRowSelection = 1;

            console.log('LWC: '+JSON.stringify(this.listaccounts));

            let varRecords;
            
            if(Array.isArray(this.listaccounts)){
                varRecords = this.listaccounts;        
            } else{
                varRecords = [this.listaccounts];        
            }

            console.log('LWC: '+JSON.stringify(this.listaccounts));
            
            if(varRecords){
                let recs = [];

                for(let i=0; i<varRecords.length; i++){
                    let record = {};
                    record.rowNumber = ''+(i+1);
                    record.recordLink = '/'+varRecords[i].id;
                    record = Object.assign(record, varRecords[i]);
                    recs.push(record);
                }

                console.log('selectedoptionaccount', data.selectedoptionaccount);
                console.log('preselectedrows', this.preselectedrows);

                if(data.selectedoptionaccount != 'NOT SET') {
                    let my_ids = [];
                    let elementOption = {id: data.selectedoptionaccount};
                    my_ids.push(elementOption);
                    this.preselectedrows = my_ids;
                    
                    console.log('preselectedrows', this.preselectedrows);
            

                    // this.preSelectedRows = JSON.parse(JSON.stringify(listSelected));
                    // this.preSelectedRows = data.selectedoptionaccount;
                    // this.omniUpdateDataJson(data.selectedoptionaccount);
                }

                this.records = recs;
                //this.recordsToDisplay = recs;
                this.showTable = true;

            } else {
                this.showTable = false;
                this.error = 'Error';
            }          
    }

    //Action Event to rerender the List
    handleOmniAction(data) {
        this.listdata = JSON.stringify(this.listaccounts);
        this.listaccounts = data.listaccounts;
        
        if(data.rendertable){            
            this.showSearchBar = false;
            this.numberRowSelection = 1;
            let varRecords;

            if(Array.isArray(this.listaccounts)){
                varRecords = this.listaccounts;        
            } else{
                varRecords = [this.listaccounts];        
            }
            
            if(varRecords){
                let recs = [];
                for(let i=0; i<varRecords.length; i++){
                    let record = {};
                    record.rowNumber = ''+(i+1);
                    record.recordLink = '/'+varRecords[i].id;
                    record = Object.assign(record, varRecords[i]);
                    recs.push(record);
                }
                this.records = recs;
                console.log(JSON.parse(JSON.stringify(this.records)));
                this.recordsToDisplay = recs;
                
                this.showTable = true;
            }else{
                this.showTable = false;
                this.error = 'Error';
            }  
        }
    }

    //Capture the event fired from the paginator component
    handlePaginatorChange(event){
        this.recordsToDisplay = event.detail;
        this.rowNumberOffset = this.recordsToDisplay[0].rowNumber-1;
    }

    getSelectedRow(event) {
        var selectedRow = event.detail.selectedRows;
        console.log('selectedRow', JSON.parse(JSON.stringify(selectedRow)));
        
        if(selectedRow.length > 0){
            this.omniUpdateDataJson(selectedRow[0].id);
        }
        /*
        this.omniUpdateDataJson(event.target.value);
        */
    }
}