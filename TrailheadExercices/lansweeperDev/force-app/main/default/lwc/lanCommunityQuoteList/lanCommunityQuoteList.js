import { api, track, wire, LightningElement } from 'lwc';

import getOpptyQuotes from '@salesforce/apex/LAN_ctrlQuote.getOpptyQuotes';
import getOpptyQuotesCount from '@salesforce/apex/LAN_ctrlQuote.getOpptyQuotesCount';

export default class LanCommunityQuoteList extends LightningElement {

    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    totalpages;
    localCurrentPage = null;
    isSearchChangeExecuted = false;
    loadMoreStatus;

    /* -------------------- tracked variables -------------------*/
    @api recordId;
    @api currentpage = 1;
    @api pagesize = 10;
    @api totalrecords;
    @track searchKey = null;
    @track opptyQuotes = [];
    @track error;
    totalrecordsText = '0';

    tableActions = [
        { label: 'Quote PDF Download', name: 'pdf_download' }
    ];

    opptyQuoteColumns = [
        { label: 'Quote Number', fieldName: 'QuoteNumber' },
        { label: 'List Price', fieldName: 'ListAmount', type: 'currency', typeAttributes: { currencyCode: 'EUR'} },
        { label: 'Partner Discount', fieldName: 'PartnerDiscount', type: 'percent' },
        { label: 'Net Amount', fieldName: 'NetAmount', type: 'currency', typeAttributes: { currencyCode: 'EUR'} },
        { label: 'Subscription Term (in years)', fieldName: 'SubscriptionTermYears', type: 'number' },
        { label: 'Expiration Date', fieldName: 'ExpirationDate', type: "date-local",
            typeAttributes:{
                day: "2-digit",
                month: "2-digit"
            }
        },
        { label: 'Quote-to-Cart Link', fieldName: 'QtCLink', type: 'url' },
        { type: 'action', typeAttributes: { rowActions: this.tableActions } }
    ];

    @wire(getOpptyQuotesCount, { opptyId: '$recordId', searchString: '$searchKey' })
    wiredGetOpptyQuotesCount(result) {
        if (result.data) {
            this.totalrecords = result.data;  
            this.totalpages = Math.ceil(this.totalrecords / this.pagesize);
            if (this.totalrecords > 6) {
                this.totalrecordsText = '6+';
            }
            else {
                this.totalrecordsText = '' + this.totalrecords;
            }
        }
    }

    connectedCallback() {
        console.log(this.recordId)
        this.loadOpptyQuotes();
    }

    loadMoreData(event) {
        console.log('Load more JS made');
        if (this.opptyQuotes.length < this.totalrecords) {
            const { target } = event;
            target.isLoading = true;

            this.loadOpptyQuotes()
                .then(()=> {
                    target.isLoading = false;
                });
        }
    }

    loadOpptyQuotes(){
        return  getOpptyQuotes({ opptyId: this.recordId, pagenumber: this.currentpage, pageSize : this.pagesize, lastRecordPosition: this.opptyQuotes.length, searchString: this.searchKey })
        .then(result => {
            let quotes = JSON.parse(result);
            console.log(quotes);
            console.log(this.currentpage, this.totalpages, this.currentpage < this.totalpages);
            if (this.currentpage < this.totalpages) {
                console.log(this.currentpage, this.totalpages, this.currentpage < this.totalpages);
                this.currentpage = this.currentpage+1;
            }
            this.processOpptyQuotesResult(quotes);
        })
        .catch(error => {
            console.log(error);
        });
    }

    processOpptyQuotesResult(returnedOpptyQuotes) {
        let preparedAssets = [];
        for (var key in returnedOpptyQuotes) {
            let preparedAsset = {};
            preparedAsset.Id = returnedOpptyQuotes[key].Id;
            preparedAsset.QuoteNumber = returnedOpptyQuotes[key].LAN_Quote_Number__c;
            preparedAsset.ListAmount = returnedOpptyQuotes[key].SBQQ__ListAmount__c ? returnedOpptyQuotes[key].SBQQ__ListAmount__c : 0;
            preparedAsset.PartnerDiscount = returnedOpptyQuotes[key].SBQQ__PartnerDiscount__c ? returnedOpptyQuotes[key].SBQQ__PartnerDiscount__c : 0;
            preparedAsset.NetAmount = returnedOpptyQuotes[key].SBQQ__NetAmount__c ? returnedOpptyQuotes[key].SBQQ__NetAmount__c : 0;
            preparedAsset.SubscriptionTermYears = returnedOpptyQuotes[key].LAN_Subscription_term_in_years__c;
            preparedAsset.ExpirationDate = returnedOpptyQuotes[key].SBQQ__ExpirationDate__c;
            preparedAsset.QtCLink = returnedOpptyQuotes[key].LAN_Quote_to_Cart__c;

            preparedAssets.push(preparedAsset);
        }
        let updatedRecords = [...this.opptyQuotes, ...preparedAssets];
        this.opptyQuotes = updatedRecords;
        console.log(this.opptyQuotes);
    }

    onHandleSort(event) {
        console.log(event);
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.opptyQuotes];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.opptyQuotes = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    /* -------------------- Data functions -------------------*/
    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'show_details':
                this.navigateToEditRulePage(row.Id);
                break;
            case 'pdf_download':
                alert('pdf_download: ' + row.Id);
                break;
        }
    }

    // Navigate to Edit Account Page
    navigateToEditRulePage(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Loyalty_Program_Setup_Rules__c',
                actionName: 'view'
            },
        });
        // this[NavigationMixin.GenerateUrl]({
        //     type: 'standard__recordPage',
        //     attributes: {
        //         recordId: recordId,
        //         objectApiName: 'Loyalty_Program_Setup_Rules__c',
        //         actionName: 'view'
        //     },
        // }).then(url => {
        //     window.location.replace(url);
        // });;
    }
}