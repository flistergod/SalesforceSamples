import LightningDatatable from 'lightning/datatable';
import loyaltyGenericLabelColumn from './loyaltyGenericLabelColumn.html';

export default class LoyaltyLightningDatatable extends LightningDatatable {
    static customTypes = {
        customLabel: {
            template: loyaltyGenericLabelColumn,
            typeAttributes: ['labelAttributes'],
        }
    };
}