import { LightningElement, track, api } from 'lwc';
import pubsub from 'vlocity_cmt/pubsub';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
//import getrecords from '@salesforce/apex/recordTableContoller.getrecordortunities';

const columns = [
    { label: 'Company name', fieldName: 'recordLink', type: 'url', typeAttributes: { label:{ fieldName: "companyName"}, target: '_blank'} },
	{ label: 'Contact Name', fieldName: 'name', type: 'text', cellAttributes: { alignment: 'left' } },    
	{ label: 'Phone', fieldName: 'phone', type: 'text', cellAttributes: { alignment: 'left' } },    
	{ label: 'Email', fieldName: 'email', type: 'email', cellAttributes: { alignment: 'left' } },    
	{ label: 'Marketing Preferences', fieldName: 'marketingPreferences', type: 'text', cellAttributes: { alignment: 'left' } },
	{ label: 'Contact Type', fieldName: 'contactType', type: 'text', cellAttributes: { alignment: 'left' } },
	{ label: 'Line of Business', fieldName: 'businessLine', type: 'text', cellAttributes: { alignment: 'left' } }
];

let preselectedrows = [];

export default class evDisplayListContacts extends OmniscriptBaseMixin(LightningElement) {
    @api listcontacts;
    @api selectedoption;
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

        console.log('List Contacts: ', this.listcontacts);
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

            console.log('LWC: '+JSON.stringify(this.listcontacts));

            let varRecords;
            
            if(Array.isArray(this.listcontacts)){
                varRecords = this.listcontacts;        
            } else{
                varRecords = [this.listcontacts];        
            }

            console.log('LWC: '+JSON.stringify(this.listcontacts));
            
            if(varRecords){
                let recs = [];

                for(let i=0; i<varRecords.length; i++){
                    let record = {};
                    record.rowNumber = ''+(i+1);
                    record.recordLink = '/'+varRecords[i].id;
                    record = Object.assign(record, varRecords[i]);
                    recs.push(record);
                }

                console.log('selectedoption', data.selectedoption);
                console.log('preselectedrows', this.preselectedrows);

                if(data.selectedoption != 'NOT SET') {
                    let my_ids = [];
                    let elementOption = {id: data.selectedoption};
                    my_ids.push(elementOption);
                    this.preselectedrows = my_ids;
                    
                    console.log('preselectedrows', this.preselectedrows);
            

                    // this.preSelectedRows = JSON.parse(JSON.stringify(listSelected));
                    // this.preSelectedRows = data.selectedoption;
                    // this.omniUpdateDataJson(data.selectedoption);
                }

                this.records = recs;

                this.showTable = true;

            } else {
                this.showTable = false;
                this.error = 'Error';
            }          
    }

    //Action Event to rerender the List
    handleOmniAction(data) {
        this.listdata = JSON.stringify(this.listcontacts);
        console.log(data);

        this.listcontacts = data.listcontacts;
        
        if(data.rendertable){            
            this.showSearchBar = false;
            this.numberRowSelection = 1;
            let varRecords;
console.log('1')
            if(Array.isArray(this.listcontacts)){
                console.log('2')
                varRecords = this.listcontacts;        
            } else{
                console.log('3')
                varRecords = [this.listcontacts];        
            }

console.log('4')
            console.log('LWC: '+JSON.stringify(this.listcontacts));
            
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
                this.recordsToDisplay = recs;
                
                console.log('After Records Display: ',JSON.parse(JSON.stringify(this.records)));
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