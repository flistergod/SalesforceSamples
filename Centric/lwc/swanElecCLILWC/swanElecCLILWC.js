import { LightningElement, track, api} from 'lwc';
import { BaseState } from 'vlocity_cmt/baseState';
import { NavigationMixin } from 'lightning/navigation';
import template from "./swanElecCLILWC.html";

const QUOTELISTElec = "ServicePointList";
const COLUMNSDATA = "columnsData";
const COLUMNSELEC = "columnsElec";
const COLUMNSGAS = "columnsGas";
const ISGAS = "isGas";

export default class SwanElecCLILWC extends BaseState (NavigationMixin (LightningElement)){
    // Render html template
    render() {
        return template;
    }

    get QUOTELISTElecRec() {
        console.log(this.obj[QUOTELISTElec][0].Fieldname);
        return this.obj[QUOTELISTElec];
    }

    get QUOTELISTElecCol() {
        return this.obj[COLUMNSDATA][COLUMNSELEC];
    }

    get ServicePointColGas() {
    return this.obj[COLUMNSDATA][COLUMNSGAS];
    }

    // Getter to return Quote Prices (data table records)
    get ServicePointRec() {
        //console.log(this.obj[SERVICEPOINTLIST][0].ServicePointNumber);
        return this.obj[QUOTELISTElec];
    }

    get isGasList() {
        if(this.obj[ISGAS]==true) {
            return true;
        }
        return false;
    }

    renderedCallback() {
        console.log(this.isRendered);
        if (this.isRendered) {
            return; 
        }
        this.isRendered = true;
        let style = document.createElement('style');
        style.innerText = '.slds-th__action{color: #0070d2;}';
        this.template.querySelector('vlocity_cmt-data-table').appendChild(style);
    }  
}