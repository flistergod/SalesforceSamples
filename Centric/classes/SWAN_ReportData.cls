public class SWAN_ReportData
{
	@AuraEnabled public String name{get;set;}
	@AuraEnabled public DateTime CreatedDate{get;set;}
	@AuraEnabled public String downloadLink{get;set;}
	
	public SWAN_ReportData(String Name,DateTime CreatedDate,String downloadLink)
	{
		this.name = Name;
		this.CreatedDate = CreatedDate;
		this.downloadLink = '/servlet/servlet.FileDownload?file='+downloadLink;
	}
}