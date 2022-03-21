@isTest
public class ECOESresponseParsing_Test {

    @testSetup static void methodName() {

	}
    
    @isTest
    public static void parseECOESresponseParsing(){
        String inputJson = '{\n' +
                              '"SetValues3": {'+
                                '"IsSuccess": false,'+
                                '"NumberofSP": 1'+
                                '},'+
                              '"AccountHierarchy": {'+
                              '"ParentAccount": {'+
                                '"ServiceRecordTypeID": "0121t000000hUmCAAU"'+
                              '},'+
                              '"ServiceLocations": {'+
                                '"SPrecordtype": "0128E000000dXeOQAU",'+
                                '"ServicePointId": 1234567891013,'+
                                '"SupplyCapacity": 1000'+
                              '}'+
                            '},'+
                            '"ECOESresponse" : {'+
                                '"Results":[' +
                                     '{' +
                                        '"UtilityMatches":[' +
                                           '{' +
                                              '"Meters":[' +
                                                 '{' +
                                                    '"MeterDetails":[' +
                                                       '{'+
                                                          '"Value":"1470000269525",'+
                                                          '"Key":"mpancore"'+
                                                       '}' +
                                                    ']'+
                                                 '}'+
                                              '],'+
                                              '"UtilityType":"electricity",'+
                                              '"UtilityKey":"1470000269525",'+
                                              '"UtilityDetails":['+
                                                 '{'+
                                                    '"Value":"1470000269525",'+
                                                    '"Key":"mpan_core"'+
                                                 '}'+
                                              ']'+
                                           '}'+
                                        '],'+
                                        '"ParameterSet":{'+
                                           '"Parameters":['+
                                              '{'+
                                                 '"Value":"1470000269525",'+
                                                 '"Key":"MPAN"'+
                                              '}'+
                                           ']'+
                                        '}'+
                                     '},'+
                                     '{'+
                                        '"UtilityMatches":['+
                                           '{'+
                                              '"Meters":['+
                                                 '{'+
                                                    '"MeterDetails":['+
                                                       '{'+
                                                          '"Value":"1470000392353",'+
                                                          '"Key":"mpancore"'+
                                                       '}'+
                                                    ']'+
                                                 '}'+
                                              '],'+
                                              '"UtilityType":"electricity",'+
                                              '"UtilityKey":"1470000392353",'+
                                              '"UtilityDetails":['+
                                                 '{'+
                                                    '"Value":"1470000392353",'+
                                                    '"Key":"mpan_core"'+
                                                 '}'+
                                              ']'+
                                           '}'+
                                        ']'+
                                     '}'+
                                  ']'+
                            '}\n'+
                       	'}';
        
        
      	Map<String, Object> inMap =(Map<String, Object>)JSON.deserializeUntyped(inputJson);        
        ECOESresponseParsing ecoesResp = new ECOESresponseParsing();
        ecoesResp.invokeMethod('parse', inMap, new Map<String, Object>(), new Map<String, Object>());
        ecoesResp.invokeMethod('', inMap, new Map<String, Object>(), new Map<String, Object>());
    }
}