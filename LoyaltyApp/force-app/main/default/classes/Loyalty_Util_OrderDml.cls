/*
   @Author: João Almeida
   @CreatedDate: 16/09/2020
   @Description: Contains the CRUD methods for Order SObject
 */
public with sharing class Loyalty_Util_OrderDml extends Loyalty_Util_GenericDML {
    private class OrderDmlException extends Exception {}

    public Loyalty_Util_OrderDml() {
		super('Order');
    }

    /*
	   @Description: gets the orders related to a customer
	   @param1: account ID
	   @param2: if true, it will not return the orders that are related to opportunities
	   @param2: if defined, it will filter the order by the status code
	   @Return: the product items records formated related to the order ID
	   @Exception: thrown when no orders found for the account ID
	 */
    public List<Order> getOrdersByAccountId(Id accountId, boolean notOpptyRelated, string status) {
        List<Order> orders = new List<Order>();

        try {
			List<String> selectableFields = new List<String> {'Id', 'AccountId', 'OpportunityId','TotalAmount', 'EndDate', 'ContractId', 'ContractEndDate',
				                                          'ActivatedDate', 'ActivatedById', 'OrderNumber', 'EffectiveDate', 'Type', 'Status'};
			List<String> orderBy = new List<String> {'EffectiveDate'};
            List<String> whereClauses = new List<String> {'AccountId=\'' + accountId +'\''};
            if (notOpptyRelated) {
                whereClauses.add('and OpportunityId = null');
            }
            if (status != null && !String.isEmpty(status)) {
                whereClauses.add('and Status = \'' + status + '\'');
            }
			orders = (Order[])this.selectRecords(0, 0, null, null, selectableFields,whereClauses, orderBy, null, false, false);
			if (orders == null || orders.isEmpty()) {
				throw new OrderDmlException('getOrdersByAccountId Error: ' + 'no orders found for account Id ' + accountId);
			}
		}
		catch (Exception ex) {
			throw ex;
		}
        return orders;
    }
    
    /*
	   @Description: gets the quantity of orders related to a customer
	   @param1: account ID
	   @param2: if true, it will not return the orders that are related to opportunities
	   @param2: if defined, it will filter the order by the status code
	   @Return: the product items records formated related to the order ID
	   @Exception: thrown when no orders found for the account ID
	 */
    public integer getCountOrdersByAccountId(Id accountId, boolean notOpptyRelated, string status) {
        integer quantityOrders = 0;

        try {
			List<String> selectableFields = new List<String> {'COUNT(Id)quantityOrders'};
            List<String> whereClauses = new List<String> {'AccountId=\'' + accountId +'\''};
            List<String> orderBy = new List<String>{'AccountId'};
            if (notOpptyRelated) {
                whereClauses.add('and OpportunityId = null');
            }
            if (status != null && !String.isEmpty(status)) {
                whereClauses.add('and Status = \'' + status + '\'');
            }
            String groupByClauses = 'group by AccountId';
			List<AggregateResult> aggregatedValues = (AggregateResult[])this.selectRecords(0, 0, null, null, selectableFields,whereClauses, orderBy, groupByClauses, null, false, false);
			if (aggregatedValues == null || aggregatedValues.isEmpty()) {
				throw new OrderDmlException('getCountOrdersByAccountId Error: ' + 'no orders found for account Id ' + accountId);
            }
            else {
                quantityOrders = (integer)aggregatedValues[0].get('quantityOrders');
            }
		}
		catch (Exception ex) {
            System.debug(ex);
		}
        return quantityOrders;
    }

    /*
      @Description: gets the list of fields related to Order SObject
      @Return: the list of fields
	 */
    public List<Loyalty_Util_GenericDML.GenericFieldMapper> getOrderFieldsList() {
        List<Loyalty_Util_GenericDML.GenericFieldMapper> fields = this.getSObjectFieldsList();

        return fields;
    }
}