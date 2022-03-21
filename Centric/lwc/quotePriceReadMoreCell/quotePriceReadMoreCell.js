import {LightningElement, track} from 'lwc';
import dataTableCell from "vlocity_cmt/dataTableCell";
import { cloneDeep } from "vlocity_cmt/lodash";

// Declaring and Initializing constants
const PRICENAME = "PriceName";
const PRICETEXT = "PriceText";
const PRICESTRING = "";
const PRICE = "Price";
const NA = "NA";
const SPACING = " ";
const TERMSTRING = "Term";
const COLORBLUE = "#08a7df";
const COLORDARKGREEN = "#62c462";
const NORECORDS = "No records to display";


// Extending dataTableCell
export default class QuotePriceReadMoreCell extends dataTableCell {

    // Declaring and Initializing Decorators
    @track data; 
    @track isData;
    @track noRecords = NORECORDS;

    // Method to call modifyData() method and open modal on click of Expand icon button
    openModal() {
		this.modifyData();
        Promise.resolve().then(() => {
            let modal = this.template.querySelector("vlocity_cmt-modal") ? this.template.querySelector("vlocity_cmt-modal") : this.template.querySelector("c-modal");
            if(modal) {
                modal.openModal();
            } else {
                console.log("modal is undefined");
            }
        }).catch(error => console.log(error.message));
    }
    // Method to close a modal on click of a Cancel button
    closeModal() {
        Promise.resolve().then(() => {
            let modal = this.template.querySelector("vlocity_cmt-modal") ? this.template.querySelector("vlocity_cmt-modal") : this.template.querySelector("c-modal");
            if(modal) {
                modal.closeModal();
            } else {
                console.log("modal is undefined");
            }
        }).catch(error => console.log(error.message));
    }
    // Method to manipulate data
    modifyData() {
        this.data = cloneDeep(this.rowData.Prices);
        if(this.data.length > 0) {
            this.isData = true;
        } else {
            this.isData = false;
        }
        for(var item in this.data) {
            if(! this.data[item].hasOwnProperty(PRICENAME)) {
                this.data[item][PRICENAME] = NA;
            }
            if(this.data[item].hasOwnProperty(PRICE)) {
                this.data[item][PRICETEXT] = PRICESTRING;
            } else {
                this.data[item][PRICE] = NA;
                this.data[item][PRICETEXT] = PRICESTRING;
            }
        }
    }
    // Getter to set the color of the icon to blue
    get iconColorBlue() {
        return COLORBLUE;
    }
    // Getter to set the color of the icon to green
    get iconColorDarkGreen() {
        return COLORDARKGREEN;
    }
}