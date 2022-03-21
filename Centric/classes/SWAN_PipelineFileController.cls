public without sharing class SWAN_PipelineFileController {
    @AuraEnabled
    public static List <SWAN_ReportData> getReportData(Date fromDate) {
        
        system.debug(fromDate);
        Date fromDateVal = Date.today();
        if(fromDate != null)
        {
            fromDateVal = fromDate;
        }
        List<SWAN_ReportData> reportDataList = new List<SWAN_ReportData>();
        
        Map<id,SWAN_Custom_Report__c> mapPipelineReport = new Map<id,SWAN_Custom_Report__c>([SELECT Id, name, CreatedDate FROM SWAN_Custom_Report__c WHERE CreatedDate >= :fromDateVal AND SWAN_Report_Type__c ='PIPELINE' ORDER BY createdDate ASC]);
        system.debug(mapPipelineReport);

        for(Attachment att : [SELECT id,Name,CreatedDate,ParentId FROM Attachment WHERE ParentId IN :mapPipelineReport.keyset() AND CreatedDate >= :fromDateVal ORDER BY createdDate DESC])
        {
            SWAN_Custom_Report__c WINS = mapPipelineReport.get(att.ParentId);
            reportDataList.add(new SWAN_ReportData(att.name,WINS.CreatedDate,att.id));
        }
        system.debug('reportDataList='+reportDataList);
        
        return reportDataList;
    }

    @AuraEnabled
    public static void runPipelineReport(){
        Database.executeBatch(new SWAN_BatchGenerateCSVForPipeline(),2000);
        
    }

}