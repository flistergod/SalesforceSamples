import { LightningElement, api } from 'lwc';

export default class LanInfoBanner extends LightningElement {
    @api title;
    @api icon;
    @api bannerStyle = 'success';

    styleClass;
    connectedCallback() {
        if (this.bannerStyle=='white') {
            this.styleClass = 'slds-notify slds-notify_alert slds-theme_alert-texture slds-theme_default';
        } else {        
            this.styleClass = 'slds-notify slds-notify_alert slds-theme_alert-texture slds-theme_' + this.bannerStyle;
        }
    }
}