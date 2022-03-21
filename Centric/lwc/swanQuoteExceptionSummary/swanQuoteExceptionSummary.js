import { LightningElement } from "lwc";
import { BaseState } from "vlocity_cmt/baseState";
import template from "./swanQuoteExceptionSummary.html";

//const ISGAS = "isGas";

export default class swanQuoteExceptionSummary extends BaseState(LightningElement) {
    
    datalist = [];
    // Columns must be dynamically constructed?
    cols = [];
    

    gasCols = [
        {
            fieldName: "Priority1IssueResult",
            label: "XoServe Validation Check",
            cellAttributes: { iconName: { fieldName: "dynamicIconP1" }, alignment: 'center'},
            hideDefaultActions: true
        },
        {
            fieldName: "AQValidationIssueResult",
            label: "AQ Validation Issues",
            cellAttributes: { iconName: { fieldName: "dynamicIconAQ" }, alignment: 'center'},
            hideDefaultActions: true
        },
        {
            fieldName: "OverlapSupplyPointsResults",
            label: "Overlapping Supply Points",
            cellAttributes: { iconName: { fieldName: "dynamicIconOSP" }, alignment: 'center'},
            hideDefaultActions: true
        }
    ];

    ElecCols = [
        {
            fieldName: "SupplyCapacityIssueResult",
            label: "Supply Capacity Issues",
            cellAttributes: { iconName: { fieldName: "dynamicIconSC" }, alignment: 'center'},
            hideDefaultActions: true
        },
        {
            fieldName: "ECOESIssueResult",
            label: "ECOES Issues",
            cellAttributes: { iconName: { fieldName: "dynamicIconEcoes" }, alignment: 'center'},
            hideDefaultActions: true
        },
        {
            fieldName: "OverlapSupplyPointsResults",
            label: "Overlapping Supply Points",
            cellAttributes: { iconName: { fieldName: "dynamicIconOSP" }, alignment: 'center'},
            hideDefaultActions: true
        },
        {
            fieldName: "MDDValidationIssueResult",
            label: "MDD Validation Issues",
            cellAttributes: { iconName: { fieldName: "dynamicIconMDD" }, alignment: 'center'},
            hideDefaultActions: true
        },
        {
            fieldName: "ConsumptionIssueResult",
            label: "Consumption Issues",
            cellAttributes: { iconName: { fieldName: "dynamicIconConsIssue" }, alignment: 'center'},
            hideDefaultActions: true
        }
    ];

    get isGasList() {
        if (this.obj.ServicePointList.isGas == "true") {
            console.log ("returning true for gas");
            return true;
        }
        return false;
    }

    connectedCallback() {
		//this.obj.ServicePointList.forEach((element) => {
            var icon;
            var aqValidIcon;
            var overlaspSpIcon;
            var mddValidIcon;
            var suppCapIcon;
            var ecoesIcon;
            var consumptionIssueIcon;
 
			if (this.obj.ServicePointList.Priority1IssueResult == "false") {
                icon = "action:close";
                console.log("this.obj.ServicePointList.Priority1IssueResult True "+this.obj.ServicePointList.Priority1IssueResult);
			} else {
                icon = "action:approval";
                console.log("this.obj.ServicePointList.Priority1IssueResult False "+this.obj.ServicePointList.Priority1IssueResult);

            }

            if (this.obj.ServicePointList.AQValidationIssueResult == "false") {
                aqValidIcon = "action:close";
            } else {
                aqValidIcon = "action:approval";
            }
            
            if (this.obj.ServicePointList.OverlapSupplyPointsResults == "false") {
                overlaspSpIcon = "action:close";
            } else {
                overlaspSpIcon = "action:approval";
            }
 
            if (this.obj.ServicePointList.MDDValidationIssueResult == "false") {
                mddValidIcon = "action:close";
            } else {
                mddValidIcon = "action:approval";
            }
           
            if (this.obj.ServicePointList.SupplyCapacityIssueResult == "false") {
                suppCapIcon = "action:close";
            } else {
                suppCapIcon = "action:approval";
            }
 
            if (this.obj.ServicePointList.ECOESIssueResult == "false") {
                ecoesIcon = "action:close";
            } else {
                ecoesIcon = "action:approval";
            }
 
            if (this.obj.ServicePointList.ConsumptionIssueResult == "false") {
                consumptionIssueIcon = "action:close";
            } else {
                consumptionIssueIcon = "action:approval";
            }
 
            
		/*	var aqValiditem = {
				dynamicIcon: icon
            };*/
            if(this.obj.ServicePointList.isGas == "true"){
                var item = {
                    dynamicIconP1: icon,
                    dynamicIconAQ:aqValidIcon,
                    dynamicIconOSP:overlaspSpIcon,
                    dynamicIconMDD:mddValidIcon,
                };
                this.datalist.push(item);

            }else {
                var item = {
                    dynamicIconOSP:overlaspSpIcon,
                    dynamicIconMDD:mddValidIcon,
                    dynamicIconSC:suppCapIcon,
                    dynamicIconConsIssue:consumptionIssueIcon,
                    dynamicIconEcoes:ecoesIcon
                };
                this.datalist.push(item);
            }
           

           // this.datalist.push(aqValiditem);
          console.log("aqValidIcon >>"+aqValidIcon);
          console.log("icon >> aqValidIcon >> overlaspSpIcon>> mddValidIcon"+icon+aqValidIcon+ overlaspSpIcon+ mddValidIcon);
		//});
	}

    render() {
        return template;
    }



    // Getter to return true if below conditions are satisfied otherwise return false
    get isServicePointList() {
        console.log("IsGasIndicator" + this.obj[ISGAS]);
        console.log("IsNumOli" + this.obj[NUMOLIS]);
        /*if(typeof this.obj !== undefined && this.obj.hasOwnProperty(SERVICEPOINTLIST)) { //&& this.obj.hasOwnProperty(COLUMNSDATA) 
          return true;
        }*/
        if (this.obj[NUMOLIS] > 0) {
            return true;
        }
        return false;
    }

    // Style for header
  renderedCallback() {
    //console.log(this.isRendered);
    if (this.isRendered) {
        return; 
    }
    this.isRendered = true;

    let style = document.createElement('style');
    style.innerText = '.slds-th__action{justify-content: center;align-content: center;align-items: center; margin: auto;color: #0070d2 !important;}';
    //this.template.querySelector('.ElecTable').appendChild(style);
    if(this.template.querySelector('.ElecTable')){
        let elecTable = this.template.querySelector('.ElecTable');
        elecTable.appendChild(style);
    }

    let style2 = document.createElement('style');
    style2.innerText = '.slds-th__action{justify-content: center;align-content: center;align-items: center; margin: auto;color: #0070d2 !important;}';
    //this.template.querySelector('.GasTable').appendChild(style2);
    if(this.template.querySelector('.GasTable')){
        let gasTable = this.template.querySelector('.GasTable');
        gasTable.appendChild(style2);
    }
}
}