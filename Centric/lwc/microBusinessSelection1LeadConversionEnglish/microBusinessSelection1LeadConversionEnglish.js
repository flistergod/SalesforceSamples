import { LightningElement, wire, track, api } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_cmt/omniscriptBaseMixin";
import { getPicklistValues, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class microBusinessSelection1LeadConversionEnglish extends OmniscriptBaseMixin(LightningElement) {
    
    // Reactive variables
    @track optionsSegment = [];
    @track optionsMicroBusiness = [];
    @track valueSegment;
    @track valueMicroBusiness;
    @track isEmpty = false;
    @track error;
    controlValues;
    totalDependentValues = [];

    @api objectApiName;

    @wire(getObjectInfo, { objectApiName: 'Lead' })
    objectInfo;

    connectedCallback(){
        if(sessionStorage.getItem('Segment') !== null && sessionStorage.getItem('Segment') !== 'undefined'){
            this.valueSegment = sessionStorage.getItem('Segment');
            this.valueMicroBusiness = sessionStorage.getItem('MicroBusiness');
        }
    }

    @wire(getPicklistValuesByRecordType, { objectApiName: 'Lead', recordTypeId: '$objectInfo.data.defaultRecordTypeId'})
    segmentPicklistValues({error, data}) {
        if(data) {
            this.error = null;

            let segmentOptions = [{label:'-- Clear --', value:'-- Clear --'}];

            data.picklistFieldValues.SWAN_Customer_Segment__c.values.forEach(key => {
                if(key.value != 'NEP'){
                    segmentOptions.push({
                        label : key.label,
                        value: key.value
                    })
                }
            });

            this.optionsSegment = segmentOptions;

            let microBusinessOptions = [{label:'-- Clear --', value:'-- Clear --'}];

            this.controlValues = data.picklistFieldValues.SWAN_Micro_Business_Selection__c.controllerValues;
            this.totalDependentValues = data.picklistFieldValues.SWAN_Micro_Business_Selection__c.values;

            this.totalDependentValues.forEach(key => {
                microBusinessOptions.push({
                    label : key.label,
                    value: key.value
                })
            });

            this.optionsMicroBusiness = microBusinessOptions;
        }
        else if(error) {
            this.error = JSON.stringify(error);
        }
    }

    handleChangeSegment(event) {
        this.valueSegment = event.target.value;
        this.isEmpty = false;
        let dependValues = [];

        if(this.valueSegment) {
            if(this.valueSegment === '-- Clear --') {
                this.isEmpty = true;
                dependValues = [{label:'-- Clear --', value:'-- Clear --'}];
                this.valueSegment = null;
                this.valueMicroBusiness = null;
                this.microBusinessReadOnly = false;

                let myData = {
                    "customerSegmentLWC" : {
                        "segmentSelection" : null,
                        "microSelection" : null
                    }
                }
                 
                this.omniApplyCallResp(myData);
                return;
            }
            
            dependValues = [{label:'-- Clear --', value:'-- Clear --'}];

            this.totalDependentValues.forEach(conValues => {
                conValues.validFor.forEach(key => {
                    if(key === this.controlValues[this.valueSegment]) {
                        dependValues.push({
                            label: conValues.label,
                            value: conValues.value
                        })
                    }
                })
            })
            
            sessionStorage.setItem('Segment', this.valueSegment);
            
            if(sessionStorage.getItem('Segment') === 'Enterprise'){
                sessionStorage.setItem('MicroBusiness', 'Non_Micro_Business');

                this.valueMicroBusiness = sessionStorage.getItem('MicroBusiness');
                this.microBusinessReadOnly = true;

            } else {
                sessionStorage.setItem('MicroBusiness', 'Non_Micro_Business');

                this.valueMicroBusiness = sessionStorage.getItem('MicroBusiness');
                this.microBusinessReadOnly = true;
            }

            this.optionsMicroBusiness = dependValues;
        }

        let myData = {
            "customerSegmentLWC" : {
                "segmentSelection" : sessionStorage.getItem('Segment'),
                "microSelection" : sessionStorage.getItem('MicroBusiness')
            }
        }

        this.omniApplyCallResp(myData);
    }

    handleChangeMicroBusiness(event) {
        this.valueMicroBusiness = event.target.value;

        let myData = {
            "customerSegmentLWC" : {
                "microSelection" : sessionStorage.getItem('MicroBusiness')
            }
        }
        
        this.omniApplyCallResp(myData);
    }
}