import { LightningElement, api, track, wire } from 'lwc'; 
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { NavigationMixin } from 'lightning/navigation';
import * as _ from 'vlocity_cmt/lodash'; 
import { OmniscriptActionCommonUtil } from 'vlocity_cmt/omniscriptActionUtils';
import { getNamespaceDotNotation } from 'vlocity_cmt/omniscriptInternalUtils'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const _actionUtilClass = new OmniscriptActionCommonUtil();
export default class SWAN_Amend_Elec_Volume_Summary extends OmniscriptBaseMixin(NavigationMixin(LightningElement))  {
    @api omniJsonDef;
    @api omniJsonData;
    @api tabledata;
    @track hasdata;

    @api jsonvar;
	@api isQuoteChanged;
	@api LWCHasError;

	constructor(){
        super();
	}
	
    connectedCallback()
    {
        console.log(this.tabledata);
        console.log('$$$$$$$');
        
         this.hasdata=(this.tabledata && this.tabledata!=null?true:false);
         console.log(this.hasdata);
         this.jsonvar= JSON.parse(JSON.stringify(this.omniJsonData.volumeSummaryDetails));
       
    }

    
    changeNumber(event){  
              
        for(let i = 0; i < this.tabledata.length; i++){            
            if(this.tabledata[i]['Id']===event.target.name){
				this.jsonvar[i].BaseloadClipMW= event.target.value;  
				break;
            }        
        }
		for(let i = 0; i < this.tabledata.length; i++){
			if(this.jsonvar[i].CurrentBaseloadClipMW != this.jsonvar[i].BaseloadClipMW || this.jsonvar[i].CurrentPeakClipMW != this.jsonvar[i].PeakClipMW)
			{
				this.isQuoteChanged=true;
				break;
			}
			else
			{
				this.isQuoteChanged=false;
			}
		}
		for(let i = 0; i < this.tabledata.length; i++){ 
			if(this.jsonvar[i].BaseloadClipMW == null || this.jsonvar[i].BaseloadClipMW == '' || this.jsonvar[i].PeakClipMW == null || this.jsonvar[i].PeakClipMW == '')
			{
				this.LWCHasError=true;
				break;
			}
			else if((this.jsonvar[i].BaseloadClipMW.split(".")[1] != null && this.jsonvar[i].BaseloadClipMW.split(".")[1].length > 1) || (this.jsonvar[i].PeakClipMW.split(".")[1] != null && this.jsonvar[i].PeakClipMW.split(".")[1].length > 1))
			{
				this.LWCHasError=true;
				break;
			}
			else{
				this.LWCHasError=false;
			}
		}
        console.log("!!!!!!!");
        console.log(this.jsonvar[0]);
		this.updateJsonVariable = {
			volumeSummaryDetails: this.jsonvar,
			isQuoteChanged: this.isQuoteChanged,
			LWCHasError: this.LWCHasError
		}
        super.omniApplyCallResp(this.updateJsonVariable);
    }
    changeNumber1(event){  
              
        for(let i = 0; i < this.tabledata.length; i++){            
            if(this.tabledata[i]['Id']===event.target.name){
				this.jsonvar[i].PeakClipMW= event.target.value;  
				break;
            }    
        }
		for(let i = 0; i < this.tabledata.length; i++){
			if(this.jsonvar[i].CurrentPeakClipMW != this.jsonvar[i].PeakClipMW || this.jsonvar[i].CurrentBaseloadClipMW != this.jsonvar[i].BaseloadClipMW)
			{
				this.isQuoteChanged=true;
				break;
			}
			else
			{
				this.isQuoteChanged=false;
			}
		}
		for(let i = 0; i < this.tabledata.length; i++){ 
			if(this.jsonvar[i].BaseloadClipMW == null || this.jsonvar[i].BaseloadClipMW == '' || this.jsonvar[i].PeakClipMW == null || this.jsonvar[i].PeakClipMW == '')
			{
				this.LWCHasError=true;
				break;
			}
			else if((this.jsonvar[i].BaseloadClipMW.split(".")[1] != null && this.jsonvar[i].BaseloadClipMW.split(".")[1].length > 1) || (this.jsonvar[i].PeakClipMW.split(".")[1] != null && this.jsonvar[i].PeakClipMW.split(".")[1].length > 1))
			{
				this.LWCHasError=true;
				break;
			}
			else{
				this.LWCHasError=false;
			}
		}
        console.log("|||||||");
        console.log(this.jsonvar[0]);
        this.updateJsonVariable = {
			volumeSummaryDetails: this.jsonvar,
			isQuoteChanged: this.isQuoteChanged,
			LWCHasError: this.LWCHasError
		}
        super.omniApplyCallResp(this.updateJsonVariable);
    }
}