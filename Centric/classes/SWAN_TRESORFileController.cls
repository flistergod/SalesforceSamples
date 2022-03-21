public without sharing class SWAN_TRESORFileController {
    @AuraEnabled
    public static List <SWAN_ReportData> getReportData(Date fromDate) {
        
        system.debug(fromDate);
        Date fromDateVal = Date.today();
        if(fromDate != null)
        {
            fromDateVal = fromDate;
        }
        List<SWAN_ReportData> reportDataList = new List<SWAN_ReportData>();
        
        Map<id,SWAN_Custom_Report__c> TRESORReportMap = new Map<id,SWAN_Custom_Report__c>([SELECT Id, name, CreatedDate FROM SWAN_Custom_Report__c WHERE CreatedDate >= :fromDateVal AND (SWAN_Report_Type__c ='TRESOR' OR SWAN_Report_Type__c = 'INCA') ORDER BY createdDate ASC]);
        system.debug(TRESORReportMap);
        //List<Attachment> attachmentList = [SELECT id,Name,CreatedDate,ParentId FROM Attachment WHERE ParentId IN :WINSReportMap.keyset() AND CreatedDate >= :fromDateVal ORDER BY createdDate DESC];
        //system.debug(attachmentList);
        for(Attachment att : [SELECT id,Name,CreatedDate,ParentId FROM Attachment WHERE ParentId IN :TRESORReportMap.keyset() AND CreatedDate >= :fromDateVal ORDER BY createdDate DESC])
        {
            SWAN_Custom_Report__c TRESOR = TRESORReportMap.get(att.ParentId);
            reportDataList.add(new SWAN_ReportData(TRESOR.name,TRESOR.CreatedDate,att.id));
        }
        system.debug('reportDataList='+reportDataList);
        
        return reportDataList;
    }

    @AuraEnabled
    public static void runTRESORReport(){
        SWAN_GenerateCSVForTRESOR.generateCSVForTRESOR();
        
    }

}