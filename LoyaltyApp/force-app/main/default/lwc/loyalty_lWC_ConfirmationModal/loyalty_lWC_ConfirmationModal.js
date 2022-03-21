import { LightningElement, api } from 'lwc';

//  Custom Labels import
import Loyalty_Close from '@salesforce/label/c.Loyalty_Close';
import Loyalty_Cancel from '@salesforce/label/c.Loyalty_Cancel';
import Loyalty_Confirm from '@salesforce/label/c.Loyalty_Confirm';

export default class Loyalty_lWC_ConfirmationModal extends LightningElement {
    label = {
        Loyalty_Close,
        Loyalty_Cancel,
        Loyalty_Confirm
    }

    @api modaltitle = 'Title';
    @api modalmessage = 'Message';
    @api confirmbuttonlabel = this.label.Loyalty_Confirm;
    @api openmodal = false;
    @api recordid;
    @api newstatus;

    showModal() {
        this.openmodal = true;
    }

    closeModal() {
        this.openmodal = false;
        this.dispatchEvent(new CustomEvent('modalclose'));
    }

    confirmClick() {
        this.dispatchEvent(new CustomEvent('confirm', { detail: {recordId: this.recordid, newStatus: this.newstatus}}));
    }
}