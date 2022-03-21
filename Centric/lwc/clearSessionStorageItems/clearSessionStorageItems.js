import { LightningElement, wire, track, api } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_cmt/omniscriptBaseMixin";
 
export default class ClearSessionStorageItems extends OmniscriptBaseMixin(LightningElement) {
    connectedCallback(){
        if(sessionStorage.getItem('Segment') !== null && sessionStorage.getItem('Segment') !== 'undefined'){
            sessionStorage.clear();
        }
    }
}