import { LightningElement, api } from 'lwc';

//  Custom Labels import
import Loyalty_First from '@salesforce/label/c.Loyalty_First';
import Loyalty_Last from '@salesforce/label/c.Loyalty_Last';
import Loyalty_Next from '@salesforce/label/c.Loyalty_Next';
import Loyalty_Previous from '@salesforce/label/c.Loyalty_Previous';


export default class Loyalty_LWC_LoyaltyPaginator extends LightningElement {
    label = {
        Loyalty_First,
        Loyalty_Last,
        Loyalty_Previous,
        Loyalty_Next
    };

    // Api considered as a reactive public property.  
    @api totalrecords;
    @api currentpage;
    @api pagesize;
    // Following are the private properties to a class.  
    lastpage = false;
    firstpage = false;

    // getter  
    get showFirstButton() {
        if (this.currentpage === 1) {
            return true;
        }
        return false;
    }
    // getter  
    get showLastButton() {
        if (Math.ceil(this.totalrecords / this.pagesize) === this.currentpage) {
            return true;
        }
        return false;
    }
    //Fire events based on the button actions  
    handlePrevious() {
        this.dispatchEvent(new CustomEvent('loyaltyprevious'));
    }
    handleNext() {
        this.dispatchEvent(new CustomEvent('loyaltynext'));
    }
    handleFirst() {
        this.dispatchEvent(new CustomEvent('loyaltyfirst'));
    }
    handleLast() {
        this.dispatchEvent(new CustomEvent('loyaltylast'));
    }
}