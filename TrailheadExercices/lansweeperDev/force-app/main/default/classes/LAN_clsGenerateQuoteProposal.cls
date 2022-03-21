/**
 * @description       : 
 * @author            : Flistergod
 * @group             : 
 * @last modified on  : 11-11-2020
 * @last modified by  : Flistergod
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   11-11-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class LAN_clsGenerateQuoteProposal {
    
     public static String save(Id quoteId) {

        

        String jobId='';

         try {
             
            QuoteProposalModel context = new QuoteProposalModel(quoteId);
         jobId=SBQQ.ServiceRouter.save('SBQQ.QuoteDocumentAPI.Save', JSON.serialize(context));
        system.debug('##### LAN_clsGenerateQuoteProposal results ######');
        system.debug(jobId);
        
        

         } catch(Exception e) {
             System.debug(e.getMessage());

             /*
             docSample.DocSamplePort sample = new docSample.DocSamplePort();
        sample.endpoint_x = 'http://example.com/example/test';
        
        // This invokes the EchoString method in the generated class
        String echo = sample.EchoString(quoteId);
        
        return echo;
        
        */

         }

         return jobId;
        
    }
}