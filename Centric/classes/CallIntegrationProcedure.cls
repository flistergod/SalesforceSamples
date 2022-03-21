public class CallIntegrationProcedure implements Queueable,Database.AllowsCallouts{
    public String inputString; 
   
    public void execute(QueueableContext qc){
        system.debug('ssss='+inputString);
        Map <String, Object> ipOutput = new Map <String, Object> ();
        List<Contract> contrList = new List<Contract>();
        List<IntegrationProcedureInvocable.IntegrationProcedureInput> iopList = (List<IntegrationProcedureInvocable.IntegrationProcedureInput>) JSON.deserialize( inputString , List<IntegrationProcedureInvocable.IntegrationProcedureInput>.class);
        system.debug('ddddd='+iopList);
        IntegrationProcedureInvocable.IntegrationProcedureOutput result = new IntegrationProcedureInvocable.IntegrationProcedureOutput();

        List<Id> lstContractIds = new List<Id>();
        for(IntegrationProcedureInvocable.IntegrationProcedureInput iop : iopList){
            lstContractIds.add(iop.ContractId);
        }
        set<String> contractIdset = new Set<String>();
        List<Contract> lstContractQuotes = [Select Id, vlocity_cmt__QuoteId__c,vlocity_cmt__QuoteId__r.SWAN_Quote_Type__c from Contract where Id in :lstContractIds and vlocity_cmt__QuoteId__c != NULL];
        List<Id> quoteIds = new List<Id>();
         for(Contract c : lstContractQuotes){
            if(c.vlocity_cmt__QuoteId__r.SWAN_Quote_Type__c == 'Fixed')
            {
               contractIdset.add(c.Id);
            }
            quoteIds.add(c.vlocity_cmt__QuoteId__c);
        }

        Map<Id, Quote> mapQuotes = new Map<Id, Quote>([Select Id, SWAN_Price_out_of_Date__c from Quote where id in : quoteIds]);
        

        Map<Id, Quote> mapQuoteByContractId = new Map<Id, Quote>();
        for(Contract c : lstContractQuotes){
            mapQuoteByContractId.put(c.Id, mapQuotes.get(c.vlocity_cmt__QuoteId__c));
        }

        List<Quote> lstQuotes = new List<Quote>();

        for(IntegrationProcedureInvocable.IntegrationProcedureInput iop : iopList){

            ipOutput = (Map <String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(
            iop.IPName,
            new Map < String, Object >
            {
            'ContextId' => iop.ContextId,
            'SkipUpdate' => iop.SkipUpdate,
            'CommodityObject' => iop.CommodityObject
            },
            new Map < String, Object > ());

            Contract contr = new Contract();
            contr.Id =iop.ContractId;
            contr.Status = 'Contract Signed';

            if(ipOutput.get('IsExpired') == true && contractIdset.contains(iop.ContractId)){
                contr.Status = 'Reviewed Pricing';
                mapQuoteByContractId.get(iop.ContractId).SWAN_Price_out_of_Date__c = true;
            }

            contrList.add(contr);
        }

        if(!contrList.isEmpty() && Schema.sObjectType.Contract.isUpdateable()){
            Database.update(contrList, false); 
            Database.update(mapQuoteByContractId.values(), false);
        }
        
    }  
}