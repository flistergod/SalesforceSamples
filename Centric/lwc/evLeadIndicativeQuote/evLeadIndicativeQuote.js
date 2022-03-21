import { LightningElement, track, api } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
//import getOpps from '@salesforce/apex/OppTableContoller.getOpportunities';

const columns = [
    { label: 'Unique Reference Number', fieldName: 'oppLink', type: 'url', typeAttributes: { label:{ fieldName: "uniqueReferenceNumber"}, target: '_blank'} },
    { label: 'Aggregated Uplift Spot Price', fieldName: 'aggregatedUpliftSpotPrice', type: 'currency', cellAttributes: { alignment: 'left' }  },
    { label: 'Aggregated Uplift Lower Range Price', fieldName: 'aggregatedUpliftLowerRangePrice', type: 'currency', cellAttributes: { alignment: 'left' } },
    { label: 'Aggregated Uplift Higher Range Price', fieldName: 'aggregatedUpliftHigherRangePrice', type: 'currency', cellAttributes: { alignment: 'left' } }
];

export default class evLeadIndicativeQuote extends OmniscriptBaseMixin(LightningElement) {
    @api indicativequote;
    @api selectedoption;
    @track error;
    @track columns = columns;
    @track opps; //All opportunities available for data table    
    @track showTable = false; //Used to render table after we get the data from apex controller    
    @track recordsToDisplay = []; //Records to be displayed on the page
    @track showSearchBar; //Row number
    @track rowNumberOffset; //Row number
    @track numberRowSelection;
    @track preSelectedRows;
    /*
        JSON Text

    */

    connectedCallback(){
        this.showSearchBar = false;
        this.numberRowSelection = 1;
        
        //this.preSelectedRows = ["a6V2500000063zfEAA"];
        //console.log(this.preSelectedRows);

        let varRecords = this.indicativequote;        
        if(varRecords){
            let recs = [];
            for(let i=0; i<varRecords.length; i++){
                let opp = {};
                opp.rowNumber = ''+(i+1);
                opp.oppLink = '/'+varRecords[i].id;
                opp = Object.assign(opp, varRecords[i]);
                recs.push(opp);
            }
            this.opps = recs;
            this.showTable = true;
            //this.preSelectedRows = [this.selectedoption];
            //console.log(this.preSelectedRows);
        }else{
            this.error = 'Error';
        }      
    }

    //Capture the event fired from the paginator component
    handlePaginatorChange(event){
        this.recordsToDisplay = event.detail;
        this.rowNumberOffset = this.recordsToDisplay[0].rowNumber-1;
    }

    getSelectedRow(event) {
        var selectedRow = event.detail.selectedRows;
        //console.log(JSON.parse(JSON.stringify(selectedRow)));
        
        if(selectedRow.length>0){
            console.log(selectedRow[0].quoteOutcome);
            this.omniUpdateDataJson(selectedRow[0].id);
        }
        /*
        this.omniUpdateDataJson(event.target.value);
        */
    }
}