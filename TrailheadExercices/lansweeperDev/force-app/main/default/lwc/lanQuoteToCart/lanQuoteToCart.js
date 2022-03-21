import { LightningElement, track, api, wire } from 'lwc';
import getQtCUrl from '@salesforce/apex/LAN_ctrlQuoteToCart.getQtCUrl';
import {updateRecord} from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {getRecord} from 'lightning/uiRecordApi';
import FIELD_ID from '@salesforce/schema/SBQQ__Quote__c.Id';
import FIELD_CTQURL from '@salesforce/schema/SBQQ__Quote__c.LAN_Quote_to_Cart__c';
import FIELD_CUSTOMER_CURRENCY_RENEWAL from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.SBQQ__Opportunity__r.LAN_Customer_Currency__c';
import FIELD_CUSTOMER_CURRENCY_AMENDMENT from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Opportunity2__r.SBQQ__AmendedContract__r.SBQQ__Opportunity__r.LAN_Customer_Currency__c';
import FIELD_CURRENCY from '@salesforce/schema/SBQQ__Quote__c.CurrencyIsoCode';
import FIELD_QTC_ENABLED from '@salesforce/schema/SBQQ__Quote__c.LAN_Quote_to_Cart_Enabled__c';

export default class LAN_QuoteToCart extends LightningElement {
    /* API vars */
    @api recordId;

    /* Track vars */
    @track qtcURL;
    @track error;
    @track isLoading = true;
    @track currentRecordId;
    @track hasURL;
    @track enableQTC = false;

    /* Wire methods */
    @wire(getRecord, { recordId: '$recordId', fields: [FIELD_QTC_ENABLED, FIELD_CTQURL, FIELD_CUSTOMER_CURRENCY_RENEWAL, FIELD_CUSTOMER_CURRENCY_AMENDMENT, FIELD_CURRENCY]})
    getQuote({error, data}) {
        if(error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading quote',
                    message,
                    variant: 'error',
                }),
            );

            this.error = message;
            this.toggleButton(false);
        } else if(data) {
            let customerCurrency;
            this.enableQTC = data.fields.LAN_Quote_to_Cart_Enabled__c.value;

            if(data.fields.SBQQ__Opportunity2__r.value.fields.SBQQ__RenewedContract__r.value !== null && data.fields.SBQQ__Opportunity2__r.value.fields.SBQQ__RenewedContract__r.value.fields.SBQQ__Opportunity__r.value != null && data.fields.SBQQ__Opportunity2__r.value.fields.SBQQ__RenewedContract__r.value.fields.SBQQ__Opportunity__r.value.fields.LAN_Customer_Currency__c) {
                customerCurrency = data.fields.SBQQ__Opportunity2__r.value.fields.SBQQ__RenewedContract__r.value.fields.SBQQ__Opportunity__r.value.fields.LAN_Customer_Currency__c.value
            } else if(data.fields.SBQQ__Opportunity2__r.value.fields.SBQQ__AmendedContract__r.value != null && data.fields.SBQQ__Opportunity2__r.value.fields.SBQQ__AmendedContract__r.value.fields.SBQQ__Opportunity__r.value != null && data.fields.SBQQ__Opportunity2__r.value.fields.SBQQ__AmendedContract__r.value.fields.SBQQ__Opportunity__r.value.fields.LAN_Customer_Currency__c) {
                customerCurrency = data.fields.SBQQ__Opportunity2__r.value.fields.SBQQ__AmendedContract__r.value.fields.SBQQ__Opportunity__r.value.fields.LAN_Customer_Currency__c.value;
            }

            // US SICCP-1306 - the quote lines are now recalculated to the new currency
            if(data.fields.SBQQ__Type__c === 'Renewal' && customerCurrency && customerCurrency !== data.fields.CurrencyIsoCode.value) {
                this.enableQTC = true;
            }
            // if(customerCurrency && customerCurrency !== data.fields.CurrencyIsoCode.value) {
                // Block
                // this.error = 'Renewal with exotic currency. Please handle as Direct Invoicing.';
                // this.enableQTC = false;
            // } else
            else if (data.fields.LAN_Quote_to_Cart__c.value) {
                this.qtcURL = data.fields.LAN_Quote_to_Cart__c.value;
                this.enableQTC = false
            } 
            
            this.toggleButton(!this.enableQTC);
        }

        this.isLoading = false;
    }

    /* Click Handlers */
    generateQTCURL() {
        const recId = this.recordId;
        this.isLoading = true;
        getQtCUrl({quoteId: recId})
            .then(result => {
                this.qtcURL = result;
                this.error = undefined;
                this.isLoading = false;
                this.toggleButton(true);
                this.setQuoteURL(result);
            })
            .catch(error => {
                this.error = JSON.stringify(error);
                this.qtcURL = undefined;
                this.isLoading = false;
                this.toggleButton(false);
            });
    }

    /* Utilities */
    setQuoteURL(url) {
        const fields = {};
        fields[FIELD_ID.fieldApiName] = this.recordId;
        fields[FIELD_CTQURL.fieldApiName] = url;

        const recordInput = {fields};

        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Quote-to-Cart link created!',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating Quote-to-Cart link',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });

    }

    toggleButton(disabled) {
        let qtcButton = this.template.querySelector('lightning-button');
        qtcButton.disabled = disabled;
    }

}