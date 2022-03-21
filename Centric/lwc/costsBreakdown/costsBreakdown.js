import { track, wire, LightningElement } from 'lwc';
import { BaseState } from 'vlocity_cmt/baseState';
import template from "./costsBreakdown.html";
const QUOTELISTGas = "QUOTELISTGas";
const QUOTELISTElec = "QUOTELISTElec";
const QUOTELISTGas_Flex = "QUOTELISTGas_Flex";
const QUOTELISTElec_Flex = "QUOTELISTElec_Flex";
const isGas = "isGasList";
const columnsGas = [
    { "label": "Costs Breakdown", "fieldName": "Fieldname", "type": "text" , "visible": "true"},
    { "label": "Total Value (£)", "fieldName": "TotalValue", "type": "text" , "visible": "true"},
    { "label": "Percentage (%)", "fieldName": "Percentage", "type": "text" , "visible": "true"}
];
const columnsElec = [
  { "label": "Costs Breakdown", "fieldName": "Fieldname", "type": "text" , "visible": "true"},
  { "label": "Total Value (£)", "fieldName": "TotalValue", "type": "text" , "visible": "true"},
  { "label": "Percentage (%)", "fieldName": "Percentage", "type": "text" , "visible": "true"},
  { "label": "Pass Through Y/N", "fieldName": "PassThrough", "type": "text" , "visible": "true"}
];
const columnsGas_Flex = [
    { "label": "Component", "fieldName": "Component", "type": "text" , "visible": "true" },
    { "label": "", "fieldName": "ChildComponent", "type": "text" , "visible": "true" },
    { "label": "Recovery", "fieldName": "Recovery", "type": "text" , "visible": "true" },
    { "label": "Cost End Date", "fieldName": "CostEndDate", "type": "text" , "visible": "true"},
	{ "label": "Value(£)", "fieldName": "Value_£", "type": "text" , "visible": "true"},
	{ "label": "Unit Rate(£/MWh)", "fieldName": "URate_£/MWh", "type": "text" , "visible": "true"},
	{ "label": "Unit Rate(p/kWh)", "fieldName": "URate_p/kWh", "type": "text" , "visible": "true"},
	{ "label": "Unit Rate(p/th)", "fieldName": "URate_p/th", "type": "text" , "visible": "true"},
	{ "label": "Standing Charge(p/day)", "fieldName": "StandingCharge", "type": "text" , "visible": "true"}
];
const columnsElec_Flex = [
  { "label": "Component", "fieldName": "Component", "type": "text" , "visible": "true" },
  { "label": "Cost End Date", "fieldName": "CostEndDate", "type": "text" , "visible": "true" },
  { "label": "Value(£)", "fieldName": "Value_£", "type": "text" , "visible": "true"},
  { "label": "Price @ NBP(£/MWh)", "fieldName": "NBP_£/MWh", "type": "text" , "visible": "true"},
  { "label": "Price @ GSP(£/MWh)", "fieldName": "GSP_£/MWh", "type": "text" , "visible": "true"},
  { "label": "Price @ MSP(£/MWh)", "fieldName": "MSP_£/MWh", "type": "text" , "visible": "true"},
  { "label": "Pass Through", "fieldName": "PassThrough", "type": "text" , "visible": "true"}
];

export default class costsBreakdown extends BaseState(LightningElement) {
    @track columnsGas = columnsGas;
    @track columnsElec = columnsElec;
    @track columnsGas_Flex = columnsGas_Flex;
    @track columnsElec_Flex = columnsElec_Flex;
    @track isGas = isGas;


    // Render html template
    render() {
        return template;
    }

    // Getter to return Quote Prices (data table records)
  get QUOTELISTElecRec() {
    console.log(this.obj[QUOTELISTElec][0].Fieldname);
    return this.obj[QUOTELISTElec];
  }

    // Getter to return Quote Prices (data table records)
  get QUOTELISTGasRec() {
    console.log(this.obj[QUOTELISTGas][0].Fieldname);
    return this.obj[QUOTELISTGas];
  }

  get QUOTELISTGasCol() {
    console.log(columnsGas);
    return columnsGas;
  }

  get QUOTELISTElecCol() {
    console.log(columnsElec); 
    return columnsElec;
  }

  get QUOTELISTElecRec_Flex() {
    return this.obj[QUOTELISTElec_Flex];
  }

    // Getter to return Quote Prices (data table records)
  get QUOTELISTGasRec_Flex() {
    return this.obj[QUOTELISTGas_Flex];
  }

  get QUOTELISTGasCol_Flex() {
    return columnsGas_Flex;
  }

  get QUOTELISTElecCol_Flex() {
    return columnsElec_Flex;
  }

  get isGaslist() {
        if(this.obj[isGas]!=undefined && this.obj[isGas]==true) {
          return true;
        }
        return false;
      } 

  get quoteTypeFlex() {
    if(this.obj["QuoteType"]=="Flex") {
      return true;
    }
    return false;
  }
  
  renderedCallback() {
          console.log(this.isRendered);
		  console.log('is in Costs');
          if (this.isRendered) {
              return; 
          }
          this.isRendered = true;
			console.log(this.template);
          /*let style = document.createElement('style');
          style.innerText = '.slds-th__action{color: #0070d2;}';
          this.template.querySelector('vlocity_cmt-data-table').appendChild(style);*/
	  
		let style = document.createElement('style');
		style.innerText = '.slds-th__action{justify-content: left;align-content: left;align-items: left; margin: auto;color: #0070d2 !important;}';
    //this.template.querySelector('.ElecTable').appendChild(style);
    if(this.template.querySelector('.CostsBreakdownElec')){
        let elecTable = this.template.querySelector('.CostsBreakdownElec');
        elecTable.appendChild(style);
		console.log('is in CostsElec');
    }
	

    let style2 = document.createElement('style');
    style2.innerText = '.slds-th__action{justify-content: left;align-content: left;align-items: left; margin: auto;color: #0070d2 !important;}';
    //this.template.querySelector('.GasTable').appendChild(style2);
    if(this.template.querySelector('.CostsBreakdownGas')){
        let gasTable = this.template.querySelector('.CostsBreakdownGas');
        gasTable.appendChild(style2);
		console.log('is in CostsGas');
    }
    }  
}