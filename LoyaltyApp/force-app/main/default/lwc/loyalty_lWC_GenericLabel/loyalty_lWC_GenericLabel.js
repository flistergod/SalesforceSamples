import { LightningElement, api } from 'lwc';

export default class Loyalty_lWC_GenericLabel extends LightningElement {
    @api value;
    @api labelAttributes;
    @api labeldefinitions;

    isIconDefined = false;

    iconPosition = 'right';

    get labelClass() {
        let classes = this.labelAttributes && this.labelAttributes.class ? this.labelAttributes.class : 'slds-badge';
        if (this.labelAttributes && this.labelAttributes.classRules) {
            for (var k in this.labelAttributes.classRules) {
                if (this.labelAttributes.classRules[k].value && this.labelAttributes.classRules[k].value == this.value) {
                    classes += " " + this.labelAttributes.classRules[k].class;
                }
            }
        }
        return classes;
    }

    get iconSize() {
        return this.labelAttributes && this.labelAttributes.icon && this.labelAttributes.icon.size ? this.labelAttributes.icon.size : 'xx-small';
    }

    get iconName() {
        return this.labelAttributes && this.labelAttributes.icon && this.labelAttributes.icon.name ? this.labelAttributes.icon.name : 'utility:edit';
    }

    get iconTitle() {
        return this.labelAttributes && this.labelAttributes.icon && this.labelAttributes.icon.title ? this.labelAttributes.icon.title : 'title';
    }

    get iconClass() {
        return this.labelAttributes && this.labelAttributes.icon && this.labelAttributes.icon.class ? this.labelAttributes.icon.class : 'slds-badge__icon slds-badge__icon_right';
    }

    get isIconPositionLeft() {
        return this.iconPosition == 'left' ? true : false;
    }

    get isIconPositionRight() {
        return this.iconPosition == 'right' ? true : false;
    }

    connectedCallback() {
        if (!this.labelAttributes) {
            this.labelAttributes = this.labeldefinitions;
        }
        if (this.labelAttributes) {
            if (this.labelAttributes.useIcon) {
                this.isIconDefined = true;
                if (this.labelAttributes.icon.position) {
                    this.iconPosition = this.labelAttributes.icon.position;
                }
            }
        }
    }
}