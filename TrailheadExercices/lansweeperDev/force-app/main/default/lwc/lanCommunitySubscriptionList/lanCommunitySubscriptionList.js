import { api, track, wire, LightningElement } from 'lwc';

import getOpptySubscriptions from '@salesforce/apex/LAN_ctrlSubscription.getOpptySubscriptions';
import getOpptySubscriptionsCount from '@salesforce/apex/LAN_ctrlSubscription.getOpptySubscriptionsCount';

export default class LanCommunitySubscriptionList extends LightningElement {
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
    @track opptySubscriptions = [];
    @track error;
    totalrecordsText = '0';

    tableActions = [
        { label: 'Quote PDF Download', name: 'pdf_download' }
    ];

    opptySubscriptionColumns = [
        { label: 'Subscription', fieldName: 'SubscriptionNumber' },
        { label: 'Product Name', fieldName: 'ProductName' },
        { label: 'Start Date', fieldName: 'StartDate', type: "date-local",
            typeAttributes:{
                day: "2-digit",
                month: "2-digit"
            }
        },
        { label: 'End Date', fieldName: 'EndDate', type: "date-local",
            typeAttributes:{
                day: "2-digit",
                month: "2-digit"
            }
        },
        { label: 'License key location', fieldName: 'LicenseKeyLink', type: 'url' }
    ];

    @wire(getOpptySubscriptionsCount, { opptyId: '$recordId', searchString: '$searchKey' })
    wiredGetOpptySubscriptionsCount(result) {
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
        this.loadOpptySubscriptions();
    }

    loadMoreData(event) {
        console.log('Load more JS made');
        if (this.opptySubscriptions.length < this.totalrecords) {
            const { target } = event;
            target.isLoading = true;

            this.loadOpptySubscriptions()
                .then(()=> {
                    target.isLoading = false;
                });
        }
    }

    loadOpptySubscriptions(){
        return  getOpptySubscriptions({ opptyId: this.recordId, pagenumber: this.currentpage, pageSize : this.pagesize, lastRecordPosition: this.opptySubscriptions.length, searchString: this.searchKey })
        .then(result => {
            let subscriptions = JSON.parse(result);
            console.log(subscriptions);
            console.log(this.currentpage, this.totalpages, this.currentpage < this.totalpages);
            if (this.currentpage < this.totalpages) {
                console.log(this.currentpage, this.totalpages, this.currentpage < this.totalpages);
                this.currentpage = this.currentpage+1;
            }
            this.processOpptySubscriptionsResult(subscriptions);
        })
        .catch(error => {
            console.log(error);
        });
    }

    processOpptySubscriptionsResult(returnedOpptySubscriptions) {
        let preparedAssets = [];
        for (var key in returnedOpptySubscriptions) {
            let preparedAsset = {};
            
            preparedAsset.Id = returnedOpptySubscriptions[key].Id;
            preparedAsset.SubscriptionNumber = returnedOpptySubscriptions[key].Name;
            preparedAsset.ProductName = returnedOpptySubscriptions[key].SBQQ__ProductName__c;
            preparedAsset.StartDate = returnedOpptySubscriptions[key].SBQQ__StartDate__c;
            preparedAsset.EndDate = returnedOpptySubscriptions[key].SBQQ__EndDate__c;
            preparedAsset.LicenseKeyLink = returnedOpptySubscriptions[key].LAN_License_Key_Location__c;

            preparedAssets.push(preparedAsset);
        }
        let updatedRecords = [...this.opptySubscriptions, ...preparedAssets];
        this.opptySubscriptions = updatedRecords;
        console.log(this.opptySubscriptions);
    }

    onHandleSort(event) {
        console.log(event);
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.opptySubscriptions];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.opptySubscriptions = cloneData;
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