import { LightningElement, track } from 'lwc';
import { BaseState } from 'vlocity_cmt/baseState';
import template from "./quotePriceList.html";

// Declaring and Initializing constants
const COLUMNSDATA = "columnsData";
const COLUMNSELEC = "columnsElec";
const COLUMNSGAS = "columnsGas";
const SERVICEPOINTLIST = "ServicePointList";
const NORECORDS = "No records to display";
const ISGAS = "isGas";
const NUMOLIS = "NumOLIs";

// Extending baseState
export default class QuotePriceList extends BaseState(LightningElement) {

  // Declaring and Initializing Decorators
  @track noRecords = NORECORDS;

  // Render html template
  render() {
    return template;
  }
  // Getter to return true if below conditions are satisfied otherwise return false
  get isServicePointList() {
    //console.log(this.obj[ISGAS]);
    /*if(typeof this.obj !== undefined && this.obj.hasOwnProperty(SERVICEPOINTLIST)) { //&& this.obj.hasOwnProperty(COLUMNSDATA) 
      return true;
    }*/
    if(this.obj[NUMOLIS]>0) {
      return true;
    }
    return false;
  }
  
  get isGasList() {
    if(this.obj[ISGAS]==true) {
      return true;
    }
    return false;
  }
  get quoteTypeFlex() {
    if(this.obj["quoteType"]=="Flex") {
      return true;
    }
    return false;
  }
  // Getter to return COLUMNS (data table columns)
  get ServicePointColElec() {
    return this.obj[COLUMNSDATA][COLUMNSELEC];
  }

  get ServicePointColGas() {
    return this.obj[COLUMNSDATA][COLUMNSGAS];
  }

  // Getter to return Quote Prices (data table records)
  get ServicePointRec() {
    //console.log(this.obj[SERVICEPOINTLIST][0].ServicePointNumber);
    return this.obj[SERVICEPOINTLIST];
  }

  // Style for header
  renderedCallback() {
    //console.log(this.isRendered);
    if (this.isRendered) {
        return; 
    }
    this.isRendered = true;

    /*let style = document.createElement('style');
    style.innerText = '.slds-th__action{color: #0070d2;}';
    this.template.querySelector('vlocity_cmt-data-table').appendChild(style);*/

    let style = document.createElement('style');
		style.innerText = '.slds-th__action{justify-content: left;align-content: left;align-items: left; margin: auto;color: #0070d2 !important;}';
    //this.template.querySelector('.ElecTable').appendChild(style);
    if(this.template.querySelector('.SPElec')){
        let elecTable = this.template.querySelector('.SPElec');
        elecTable.appendChild(style);
    }

    let style2 = document.createElement('style');
    style2.innerText = '.slds-th__action{justify-content: left;align-content: left;align-items: left; margin: auto;color: #0070d2 !important;}';
    //this.template.querySelector('.GasTable').appendChild(style2);
    if(this.template.querySelector('.SPGas')){
        let gasTable = this.template.querySelector('.SPGas');
        gasTable.appendChild(style2);
    }


}
}