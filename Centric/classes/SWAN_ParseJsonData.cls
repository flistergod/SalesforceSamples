global with sharing class SWAN_ParseJsonData implements vlocity_cmt.VlocityOpenInterface {
  global Boolean invokeMethod(
    String methodName,
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    if (methodName == 'ParseJsonData') {
      return ParseJsonData(input, output, options);
    }
    return false;
  }

  public Boolean ParseJsonData(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    try{
    system.debug('json input =' + input.get('GetCalculationParameters'));
    system.debug('input parameter name=' + input.get('paraName'));
    Map<String, Object> CalParam = (Map<String, Object>) input.get(
      'GetCalculationParameters'
    );
    List<Object> dataObjList = (List<Object>) CalParam.get('data');
    system.debug('json Deserial =' + dataObjList[0]);

    for (Object obj : dataObjList) {
      //system.debug('Object obj: '+obj);
      Map<String, Object> dataObj = (Map<String, Object>) obj;
      String parameterName = String.valueOf(dataObj.get('name')).toLowerCase();
      String pName = 'ParaId_' + parameterName.replace(' ', '_');
      String valName = 'Validator_' + parameterName.replace(' ', '_');
      String args = 'Args_' + parameterName.replace(' ', '_');
      output.put(pName, dataObj.get('id'));
      output.put(valName, dataObj.get('validators'));
      output.put(args, dataObj.get('args'));
      system.debug('JSON PARSER OUTPUT: ' + output);
    }
    return true;
  }catch(Exception ex){
    system.debug('Exception ex: '+ex.getMessage());
    system.debug('Exception ex: '+ex.getStackTraceString());
  }
  return false;
  }
}