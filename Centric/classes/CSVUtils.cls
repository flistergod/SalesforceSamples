/**
 * This class provides some useful utilities for dealing with CSV files.
 * 
 * @author Joe McMaster (jmcmaster@vlocity.com)
 * @version 1.0
 * 
 * History
 * =======
 * v1.0 - 09-19-2018 - Initial Version
 * 
 */
global with sharing class CSVUtils implements vlocity_cmt.VlocityOpenInterface2 {

    public class ParsingException extends Exception {
    
        public override String getStackTraceString() {
            return super.getCause().getStackTraceString();
        }
    }

    /**
     * Top level call by a Vlocity Remote Action
     *
     * @param inputMap  - The input provided to the Remote Action
     * @param outputMap - Any output to be provided back to the Remote Action
     * @param options   - Any options to aid in the execution of this class
     *
     * @returns true if the method completes successfully, false otherwise
     */ 
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {

        if (methodName == 'load') return load(inputMap, outputMap, options);  
        if (methodName == 'loadv2') return loadv2(inputMap, outputMap, options);  
        
        return false;
    }
    public static Boolean isDecimal(String s){
        Boolean ReturnValue;
        try{
            Decimal.valueOf(s);
            ReturnValue = TRUE; 
        } catch (Exception e) {
            ReturnValue = FALSE;
        }
        return ReturnValue;
    }
    private Boolean loadv2(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
         
         Set<Object> distinctRows = new Set<Object>();
         
         // Get the file(s) uploaded
         Map<String, Object> files = (Map<String, Object>)options.get('vlcFilesMap');
         string EnergyType=(string)options.get('EnergyType');
         for (String key : files.keySet()) {
             
             // Load the file content
             String fileContent = String.valueOf(files.get(key));
             distinctRows.addAll(processContent(decode(fileContent)));
         }
         
         if(distinctRows.size()>0)
         {
             Map<string,object>aRow = (Map<string,object>)(new List<object>(distinctRows))[0];
             
             if(aRow.get('isError')!=null && (boolean)aRow.get('isError'))
             {
                 outputMap.put('data', new Map<string,object>{'isError'=>true,'reason' => aRow.get('Reason')});
             }
             else if((EnergyType=='GAS' && (!aRow.containskey('Registration Type') || !aRow.containskey('Corrector') || !aRow.containskey('Data Logger') || !aRow.containskey('Meter Point Reference Number'))) || (EnergyType=='ELECTRICITY' && (!aRow.containskey('Registration Type') || !aRow.containskey('Meter Point Administration Number') || !aRow.containskey('Supply Capacity'))))
             {
                 outputMap.put('data', new Map<string,object>{'isError'=>true,'reason' => 'File Headers are incorrect'});
             }
             else{
                 string SPrecordtype = (EnergyType=='GAS'?Schema.SObjectType.vlocity_cmt__ServicePoint__c.getRecordTypeInfosByDeveloperName().get('SWAN_Gas_Service_Point').getRecordTypeId():(EnergyType=='ELECTRICITY'?Schema.SObjectType.vlocity_cmt__ServicePoint__c.getRecordTypeInfosByDeveloperName().get('SWAN_Electricity_Service_point').getRecordTypeId():''));
                 List<Object> rows = new List<Object>();
                 List<Object> BadRows = new List<Object>();
                 integer rownumber=2;//As csv 1st row is header
                 for(object eachrow : distinctRows) {   
                    
                    Map<string,object> eachrowmap = (map<string,object>)eachrow;
                    if((EnergyType=='GAS' && (eachrowmap.get('Corrector')=='True' || eachrowmap.get('Corrector')=='False') && (eachrowmap.get('Data Logger')=='Unknown' || eachrowmap.get('Data Logger')=='Yes' || eachrowmap.get('Data Logger')=='No') && (string.valueof(eachrowmap.get('Meter Point Reference Number')).isNumeric()) && (string.valueof(eachrowmap.get('Registration Type')) == 'COT Flag' || string.valueof(eachrowmap.get('Registration Type')) == '' || string.valueof(eachrowmap.get('Registration Type')) == null)) || (EnergyType=='ELECTRICITY' && (string.valueof(eachrowmap.get('Meter Point Administration Number')).isNumeric()) && (string.valueof(eachrowmap.get('Meter Point Administration Number')).length()==13) && (eachrowmap.get('Supply Capacity')==null|| string.valueof(eachrowmap.get('Supply Capacity'))=='' || isDecimal(string.valueof(eachrowmap.get('Supply Capacity')))) && (string.valueof(eachrowmap.get('Registration Type')) == 'COT Flag' || string.valueof(eachrowmap.get('Registration Type')) == null || string.valueof(eachrowmap.get('Registration Type')) == '')))
                    {
                        eachrowmap.put('SPrecordtype',SPrecordtype); 
                        if(EnergyType=='ELECTRICITY' && eachrowmap.get('Supply Capacity')!=null && !String.ISBLANK(string.valueof(eachrowmap.get('Supply Capacity')))) eachrowmap.put('Supply Capacity',Decimal.valueOf(string.valueof(eachrowmap.get('Supply Capacity'))).round(System.RoundingMode.CEILING));            
                        rows.add(eachrowmap);    
                    }
                    else
                    {
                        eachrowmap.put('CSV Row Number',rownumber);
                        if(EnergyType=='ELECTRICITY' && isDecimal(string.valueof(eachrowmap.get('Supply Capacity')))) eachrowmap.put('Supply Capacity',Decimal.valueOf(string.valueof(eachrowmap.get('Supply Capacity'))).round(System.RoundingMode.CEILING));            
                        BadRows.add(eachrowmap);
                    } 
                    rownumber++;    
                 }
                 
                 outputMap.put('data', new Map<string,object>{'goodData' => rows, 'badData' => BadRows, 'badDataNumber' =>BadRows.size(),'isError'=>false});
             }
         }
         else
         {
             outputMap.put('data', new Map<string,object>{'isError'=>true,'reason' => 'File is empty'});
         }
             
         
         //system.debug('==>>>>>>>'+outputMap);
         //system.debug('==>>>>>>>'+outputMap.get('data'));
         return true;
    }
    
    /**
     * This method will attempt to parse one or more CSV files and convert them into a JSON structure
     *
     * @param inputMap  - The input provided to the Remote Action
     * @param outputMap - The output map provided to the Remote Action
     * @param options   - Any options to aid in the execution of this class
     *
     * @returns true if this method completes successfully, false otherwise
     */
     private Boolean load(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
         
         Set<Object> distinctRows = new Set<Object>();
         
         // Get the file(s) uploaded
         Map<String, Object> files = (Map<String, Object>)options.get('vlcFilesMap');
         for (String key : files.keySet()) {
             
             // Load the file content
             String fileContent = String.valueOf(files.get(key));
             distinctRows.addAll(processContent(decode(fileContent)));
         }
         List<Object> rows = new List<Object>();
         rows.addAll(distinctRows);

         outputMap.put('data', rows);
         
         return true;
     }
    
    /**
     * This method attempts to process the raw CSV file content to produce a Map structure for each row.  It assumes
     * the first row of the content is the header and those fields will be used as the keys for the cells in each row.
     * 
     * @param content - The raw content
     * 
     * @return The list of rows, each as a Map object
     * 
     * @throws Exception if there are any problems parsing the data
     */
    public List<Object> processContent(String content) {
        
        List<Object> maps = new List<Object>();
        
        if (content != null) {
            
            // Get the rows
            List<List<String>> rows = parseCSV(content);
    
            if (rows.size() > 0) {
            
                // Assume the first row is the header (If I ever need to support CSV files with no header, I'll enhance this)
                List<String> headers = new List<String>();
                for(string h : rows.get(0)){
                    if(h!=null && h!='')headers.add(h);
                }
                Set<String> mprnVal = new Set<String>();
                // Process remaining rows
                for (Integer i=1; i<rows.size(); i++) {
                    
                    // Get the values
                    List<String> values = rows.get(i);
                    //system.debug('values='+values);
                    if(!mprnVal.contains(values[0]))
                    {
                    mprnVal.add(values[0]);
                    //system.debug('values 0 ='+values[0]);
                    //system.debug(values.size() +'!='+ headers.size());
                    if(values.size() != headers.size() && headers.size() > values.size())
                    {
                        Integer remainingCount = headers.size() - values.size();
                        for(Integer z=0; z<remainingCount; z++)
                            values.add('');
                    }
                    // Check for inconsistencies 
                    if (values.size() != headers.size()) {
                        maps = new List<Object>();
                        maps.add(new map<string,object>{'isError' => true, 'Reason' => 'Number of values do not match the number of headers '});
                        //throw new ParsingException('Number of values ' + values + ' do not match the number of headers ' + headers);
                        break;
                    }
                    // Create the Map representing this row
                    Map<String, Object> entry = new Map<String, Object>();
                    for (Integer x=0; x<values.size(); x++)
                    {
                     //String val = values.get(x).tolowercase(); //SPAL
                     String val = values.get(x);
                     //system.debug(headers.get(x)+'%==>>'+ val);
                     /* //SPAL
                     if(!String.IsBlank(val))
                     {
                        val = val.substring(0,1).toUpperCase()+''+val.substring(1);
                     }*/
                     entry.put(headers.get(x), val);
                    }                   
                    maps.add(entry);
                    }
                }
            }
        }

        return maps;
    }

    /*
     * Here is a CSV parsing function that returns an array (lines) of string arrays (fields). Does not handle newlines in the content though. 
     *  
     * @param contents  The raw content
     * 
     * @return List of rows, each containing a list of values
     *
     * @see https://developer.salesforce.com/page/Code_Samples#Parse_a_CSV_with_APEX
     */    
    public static List<List<String>> parseCSV(String contents) {

        List<List<String>> allFields = new List<List<String>>();

        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
        contents = contents.replaceAll(',"""',',"_DBLQT_').replaceall('""",','_DBLQT_",');

        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        contents = contents.replaceAll('""','_DBLQT_');

        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        List<String> lines = new List<String>();

        try {
            
            lines = contents.split('\n');
        } 
        catch (System.ListException e) {
            
            System.debug('Limits exceeded?' + e.getMessage());
        }

        Integer num = 0;
        for(String line : lines) {

            // check for blank CSV lines (only commas)
            if (line.replaceAll(',','').trim().length() == 0) break;
 
            List<String> fields = line.split(',');   
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            for(String field : fields) {
                
                if (field.startsWith('"') && field.endsWith('"')) cleanFields.add(field.trim().replaceAll('_DBLQT_','"'));
                else if (field.startsWith('"')) {
                    
                    makeCompositeField = true;
                    compositeField = field;
                }
                else if (field.endsWith('"')) {
                    
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.trim().replaceAll('_DBLQT_','"'));
                    makeCompositeField = false;

                }
                else if (makeCompositeField) compositeField +=  ',' + field;
                else cleanFields.add(field.trim().replaceAll('_DBLQT_','"'));
            }
            
            allFields.add(cleanFields);
        }

        return allFields;
    }
    
    /*
     * Decodes the raw content content
     * 
     * @param content  The raw content
     * 
     * @return The decoded content as a string
     * 
     * @throws ParsingException if there are any problems decoding the content (i.e. Unsupported format, etc.);
     */
    private String decode(String content) {
        
        // The raw content of an uploaded CSV file uses the following format
        // data:text/csv;base64,QmlsbGluZ0FjY291bnQsTmFtZSxTZXJpYWx.......
        //
        // however, it may also look like this if the user has selected "Upload To Content Document" on the OmniScript File Input element
        // which causes the file to instead be uploaded into the Salesforce Files repository and the content then becomes the Id of the File
        // 0691j0000004arwAAA
        //
        // Check to make sure we can process the file in either case
        if (content.contains(',')) { 

            String metadata = content.substring(0, content.indexOf(','));
        
            // Determine the type of data we are dealing with
            if (metadata.contains('data:text/csv;')) {
            
                if (metadata.contains('base64')) return EncodingUtil.base64Decode(content.removeStart(metadata + ',')).toString();
                return content.removeStart(metadata + ',');
            }
            else throw new ParsingException('Unable to parse content with type = ' + metadata);
        }
        else {
            
            // Try to pull the file content out of Salesforce Content
            //String contWhere = 'WHERE ContentDocumentId=\'' + content + '\' AND IsLatest=true LIMIT 1';
            //List<ContentVersion> contentVersions = (List<ContentVersion>)Database.query('SELECT FileType, VersionData FROM ContentVersion '+String.valueof(contWhere) );
            List<ContentVersion> contentVersions = new List<ContentVersion>([SELECT FileType, VersionData FROM ContentVersion WHERE ContentDocumentId = :content AND IsLatest=true LIMIT 1]);
            if (!contentVersions.isEmpty()) {
                
                ContentVersion version = contentVersions.get(0);
                
                if (version.FileType.equalsIgnoreCase('CSV')) {
                
                    // Stored as a Blob, so just convert it to a String
                    return version.VersionData.toString();
                }
                else throw new ParsingException('Unable to parse file type "' + version.FileType + '".');
            }
            else throw new ParsingException('Unable to retrieve Content Document with Id=' + content + ' from Salesforce Files Repository.');
        }
    }
    
    public List<Object> SWAN_processContent(String content) {
        
        List<Object> maps = new List<Object>();
        
        if (content != null) {
            
            // Get the rows
            List<List<String>> rows = SWAN_parseCSV(content);
            //system.debug(rows.size());
            if (rows.size() > 0) {
            
                // Assume the first row is the header (If I ever need to support CSV files with no header, I'll enhance this)
                List<String> headers = new List<String>();
                for(string h : rows.get(0)){
                    if(h!=null && h!='')headers.add(h);
                }
                Set<String> mprnVal = new Set<String>();
                // Process remaining rows
                for (Integer i=1; i<rows.size(); i++) {
                    
                    // Get the values
                    List<String> values = rows.get(i);
                    //system.debug('values='+values);
                    //if(!mprnVal.contains(values[0]))
                    {
                    //mprnVal.add(values[0]);
                    //system.debug('values 0='+values[0]);
                    //system.debug(values.size() +'!='+ headers.size());
                    if(values.size() != headers.size() && headers.size() > values.size())
                    {
                        Integer remainingCount = headers.size() - values.size();
                        for(Integer z=0; z<remainingCount; z++)
                            values.add('');
                    }
                    // Check for inconsistencies 
                    if (values.size() != headers.size()) {
                        maps = new List<Object>();
                        maps.add(new map<string,object>{'isError' => true, 'Reason' => 'Number of values do not match the number of headers '});
                        //throw new ParsingException('Number of values ' + values + ' do not match the number of headers ' + headers);
                        break;
                    }
                    // Create the Map representing this row
                    Map<String, Object> entry = new Map<String, Object>();
                    for (Integer x=0; x<values.size(); x++)
                    {
                     //String val = values.get(x).tolowercase(); //SPAL
                     String val = values.get(x);
                     //system.debug(headers.get(x)+'%==>>'+ val);
                     /* //SPAL
                     if(!String.IsBlank(val))
                     {
                        val = val.substring(0,1).toUpperCase()+''+val.substring(1);
                     }*/
                     entry.put(headers.get(x), val);
                    }                   
                    maps.add(entry);
                    }
                }
            }
        }

        return maps;
    }
    
    public static List<List<String>> SWAN_parseCSV(String contents) {

        Utility_RowIterator r = New Utility_RowIterator(contents,'\n'); //Replace \n with whatever delineates your row

        //String firstRow;
        list<string>Lines=new list<string>();
        while(r.hasNext())
        {
            Lines.add(r.next());    
        }
        //if(r.hasNext()) firstRow = r.next();

        //system.debug('$%$%$'+Lines.size());    
        
        List<List<String>> allFields = new List<List<String>>();
                
        for(String line : lines) {
            List<String> fields = line.split(',');
            allFields.add(fields);
        }
        
        return allFields;
    }
}