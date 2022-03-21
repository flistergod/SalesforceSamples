import { LightningElement, wire, track, api  } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
export default class evPricingDetails extends OmniscriptBaseMixin(LightningElement) {
    @api price;
    connectedCallback() {

    }

    get showCard(){
        if(this.price.site.length >1){
            return true;
        } else{
            return false;
        }
    }

    get isQuoteActive(){
        if(this.price.site.combinationID === 'undefined' || this.price.site.combinationID === null || this.price.site.combinationID === ''){
            return false;
        } else{
            return true;
        }
    }

}