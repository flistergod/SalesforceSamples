/*
* @author Joao Paulo Almeida
* @CreatedDate 2019
*
* @group Generics
* @group-content 
*
* @description Generic DML class for CRUD operations on SObjects.
*/
public abstract with sharing class Loyalty_Util_GenericDML {
	public class GenericDmlException extends Exception{}

    private String sObjectName;
   

	public Loyalty_Util_GenericDML(String SObjectName) {
		if (String.isBlank(SObjectName))
		{
			throw new GenericDmlException('##GenericDml Error - SObjectName string is Empty##');
		}
		else {
			try {
				Schema.SObjectType t = Schema.getGlobalDescribe().get(SObjectName);
				if (t == null) {
					throw new GenericDmlException('##GenericDml Error - '+SObjectName+' is an invalid API Object Name.##');
				}
				this.sObjectName = SObjectName;
			}
			catch(Exception ex) {
				throw ex;
			}
		}
	}

	/*******************************************************************************************************
    * @description Checks if the user has permissions to access the SObject fields. 
    * @param currentObject the object to look up
    * @param selectableFields is an optional parameter: limit the return fields with a list. If you want a count(), just include it in this array
    * @return throws exception if does not have access to some field
    * @example
    * List<SObject> a = GenericDmlInstance.CheckReadPermissions(Schema.SObjectType,selectableFields);
    */
	private void CheckReadPermissions(Schema.SObjectType currentObject, List<String> selectableFields) {
		Map<String, Schema.SObjectField> fieldMap = currentObject.getDescribe().fields.getMap();
        Set<String> objectFields = fieldMap.keySet();
		for(String field: selectableFields) {
			field = String.escapeSingleQuotes(field).toLowerCase();
			if (String.isNotBlank(field)) {
                boolean fieldIsLookup = field.toUpperCase().contains('.');//it means that is a lookup field;
				boolean fieldIsAggregate = field.toUpperCase().contains('COUNT(')
						|| field.toUpperCase().contains('SUM(')
						|| field.toUpperCase().contains('MIN(')
						|| field.toUpperCase().contains('MAX(')
						|| field.toUpperCase().contains('AVG(');
                
                if (!fieldIsLookup) {
                    if (!fieldIsAggregate) {
                        if (!objectFields.contains(field)) {
                            throw new GenericDmlException('##CheckReadPermissions Error - The Object ' + this.sObjectName + ' doesn\'t contain the Field ' + field +'##');
                        }
                        boolean hasAccess = fieldMap.get(field).getDescribe().isAccessible();
                        if (!hasAccess) {
                            throw new GenericDmlException('##CheckReadPermissions Error - access to the Field \'' + field + ' \' of the '+SObjectName+' Object is denied.##');
                        }
                    }
                    else {
                        List<String> aux = field.split('\\(');
                        List<String> aux2 = aux[1].split('\\)');
                        String auxField = String.escapeSingleQuotes(aux2[0]).toLowerCase();
                        if (!objectFields.contains(auxField)) {
                            throw new GenericDmlException('##CheckReadPermissions Error - The Object ' + this.sObjectName + ' doesn\'t contain the Field ' + auxField +'##');
                        }
                        boolean hasAccess = fieldMap.get(auxField).getDescribe().isAccessible();
                        if (!hasAccess) {
                            throw new GenericDmlException('##CheckReadPermissions Error - access to the Field \'' + auxField + ' \' of the '+SObjectName+' Object is denied.##');
                        }
                    }
                }
			}
		}
	}

	public String escapeMetaCharacters(String inputString, String[] ignoreMetaChars) {
        inputString = String.escapeSingleQuotes(inputString).replace('+',' ').replace('%',' ').trim();
        String[] metaCharacters = new String[]{'\\','^','$','{','}','[',']','(',')','.','*','+','?','|','<','>','-','&','%','!','~',':','"'};
        Integer specialCharsSize = metaCharacters.size();
        for (integer i = 0 ; i < specialCharsSize ; i++){
            if (ignoreMetaChars == null || !ignoreMetaChars.contains(metaCharacters[i])) {
                if(inputString.contains(metaCharacters[i])){
                    inputString = inputString.replace(metaCharacters[i],'\\'+metaCharacters[i]);
                    inputString = inputString.replace('\\\\\'','\\\'');
                }
            }
        }
        return inputString;
    }


    /*******************************************************************************************************
    * @description Builds a SOSL query that returns a Set of SObject Ids to use on an 'IN' condition of a SOQL query. Conditions for SOSL in the search words:
	* AND - the search should match multiple words - all data should match all words
	* OR - the search should match at least one word - could retrieve isolated data related to just one of the words
	* Conditions that can be added to the word characters:
	* '*' - the query should match all characters in the word
	* '?' - the query should match at least one character in the word
    * @param searchWordsWithClauses is an optional parameter: you could combine multiple conditions as mentioned above. If defined, the searchKeyword parameter is ignored.
    * @param splitSearchByOr is an optional parameter: defines if the words on SearchKeyword should be splitted with OR clause. If false, they are splitted with AND condition
    * @param searchAllFields if false, searches only in NAME fields (like roductName, Name, ContactName, etc.)
    * @param searchKeyword is an optional parameter: its the raw word to search. Every word separated by a space will be formatted with the AND condition and with *
    * @param queryObject its the SObject to search by
    * @param queryWhere the WHERE conditions. After the result of this function, you should only use the IN condition with the Ids returned
    * @return  the Set with the IDs matched with the search words and the WHERE conditions
    * @example
    * Set<Id> a = processQuerySearchByText(new List<String>{'Teste','AND teste2','OR teste3'},false,null,'Contact','WHERE Name = teste');
    */
    public Set<Id> processQuerySearchByText(List<String> searchWordsWithClauses, Boolean searchAllFields, Boolean splitSearchByOr, String searchKeyword, String queryObject, String queryWhere, Set<Id> dataIds) {
        try {
            //Pattern querySpecialChars = Pattern.compile('[\?\&\|\!\{\}\[\]\(\)\^\~\*\:\"\'\+\-]');
            String queryJoin = splitSearchByOr == true ? ' OR ' : ' AND ';
            String findString = '';
            Integer searchWordsCount = 0;
            if (searchWordsWithClauses != null && !searchWordsWithClauses.isEmpty()) {
                Integer searchWordsSize = searchWordsWithClauses.size();
                if (searchWordsSize > 1) {
                    for (integer index = 0; index < searchWordsSize; index++) {
                        String aux = escapeMetaCharacters(searchWordsWithClauses[index], new String[]{'*','?'});
                        // aux = aux.replaceAll('\\p{Punct}','\\\\');
                        searchWordsCount += aux.length();
                        if (!String.isBlank(aux)) {
                            if (index == 0) {
                                findString = '{'+ aux;
                            } else if (index == searchWordsSize - 1) {
                                findString += ' ' + aux +'}';
                            } else {
                                findString += ' ' + aux;
                            }
                        }
                        else {
                            if (index == 0) {
                                findString = '{';
                            }
                            else if (index == searchWordsSize - 1) {
                                findString += '}';
                            }
                        }
                    }
                } else {
                    String aux = escapeMetaCharacters(searchWordsWithClauses[0], new String[]{'*','?'});
                    // aux = aux.replaceAll('\\p{Punct}','\\\\');
                    searchWordsCount += aux.length();
                    findString = '{'+ aux + '*' +'}';
                }
            }
            else {
                findString = searchKeyword;
                findString = escapeMetaCharacters(findString, null);
                searchWordsWithClauses = findString.split(' ');
                Integer searchWordsSize = searchWordsWithClauses.size();

                if (searchWordsSize > 1) {
                    for (integer index = 0; index < searchWordsSize; index++) {
                        String aux = searchWordsWithClauses[index].trim();
                        // aux = aux.replaceAll('\\p{Punct}','\\\\');
                        searchWordsCount += aux.length();
                        if (!String.isBlank(aux)) {
                            if (index == 0) {
                                findString = '{'+ aux;
                                if (aux.length() > 1) {
                                    findString += '*';
                                } else {
                                    findString += '\\\\t*';
                                }
                            } else if (index == searchWordsSize - 1) {
                                findString += queryJoin + aux;
                                if (aux.length() > 1) {
                                    findString += '*';
                                } else {
                                    findString += '\\\\t*';
                                }
                                findString += '}';
                            } else {
                                findString += queryJoin + aux;
                                if (aux.length() > 1) {
                                    findString += '*';
                                } else {
                                    findString += '\\\\t*';
                                }
                            }
                        }
                        else {
                            if (index == 0) {
                                findString = '{';
                            }
                            else if (index == searchWordsSize - 1) {
                                findString += '}';
                            }
                        }
                    }
                } else {
                    searchWordsCount += findString.length();
                    // findString = findString.replaceAll('\\p{Punct}','\\\\');
                    // findString = querySpecialChars.matcher(findString).replaceAll('\\');
                    findString = '{'+ findString.trim();
                    if (searchWordsCount > 1) {
                        findString += '*';
                    } else {
                        findString += '\\\\t*';
                    }
                    findString += '}';
                }
            }

            // SOSL has a limit of 100 characters in the search String
            if (searchWordsCount > 100) {
                throw new GenericDmlException('SOSL violation: The search string has more than ' + 100 + ' characters.');

            } 

            String searchInFields = '';
            if (searchAllFields == true) {
                searchInFields = ' IN ALL FIELDS RETURNING ';
            }
            else {
                searchInFields = ' IN NAME FIELDS RETURNING ';
            }

            Id lastOffsetDataId = null;
            Integer currentQuerySize = 0;
            String queryLimit = ' order by Id LIMIT 2000';

            String searchBySosl = 'FIND ' + findString + searchInFields + queryObject +'(Id' + queryWhere;

            List<List<SObject>> soslAux = null;
            soslAux = search.query(searchBySosl + queryLimit + ')');
            List<SObject> searchedData = (SObject[])soslAux[0];
            currentQuerySize = searchedData.size();
            if (currentQuerySize == 2000) {
                while (currentQuerySize == 2000) {
                    // get the last ordered by Id
                    lastOffsetDataId = searchedData[1999].Id;
                    
                    soslAux = search.query(searchBySosl + ' and Id > \'' + lastOffsetDataId + '\'' + queryLimit + ')');
                    List<SObject> aux = (SObject[])soslAux[0];
                    currentQuerySize = aux.size();
                    if (aux != null) {
                        searchedData.addAll(aux);
                    }
                    if (currentQuerySize == 2000) {
                        lastOffsetDataId = aux[1999].Id;
                    }
                    else {
                        // no more data that reaches the 2000 LIMIT
                        break;
                    }
                }
            }

            for (SObject sObj : searchedData) {
                if (sObj.Id != null && !dataIds.contains(sObj.Id)) {
                    dataIds.add(sObj.Id);
                }
            }
        }
        catch (Exception ex) {
            throw new GenericDmlException('processQuerySearchByText Error: ' + ex.getMessage() + ' Stacktrace: ' + ex.getStackTraceString());
        }

        return dataIds;
    }

	/*******************************************************************************************************
    * @description find the Last Id in a sorted query
    * @param queryWithSort query with order by
    * @param fieldToOffset is the SObject field to compare for the jump
    * @param SObjectClassName is the query SObject class type
    * @return  the Last fieldToOffset value found
    * @example
    * String lastId = GenericDmlInstance.findOffset('SELECT Id FROM Account Order By Id','Id',Account.Class);
    */
    public String findOffset(String queryWithSort, String fieldToOffset, String SObjectClassName) {
        String lastOffsetDataId = null;

        Type sobjectType = Type.forName(SObjectClassName);

        SObject[] results = Database.query(queryWithSort);
        SObject offsetData = results[results.size()-1];

        string[] splittedFieldToOffset = fieldToOffset.split('.'); // it means that it is a lookup
        Integer splittedSize = 0;
        SObject offsetObject = null;
        if (splittedSize <= 1) {
            lastOffsetDataId = (String)offsetData.get(fieldToOffset);
        }
        else {
            for (integer index = 0; index < splittedSize; index++) {
                if (index == 0) {
                    offsetObject = offsetData.getSobject(splittedFieldToOffset[index].replace('__r','__c'));
                }
                else if (index == splittedSize - 1) {
                    lastOffsetDataId = (String)offsetObject.get(splittedFieldToOffset[index]);
                }
                else {
                    offsetObject = offsetObject.getSobject(splittedFieldToOffset[index].replace('__r','__c'));
                }
            }
        }
        return lastOffsetDataId;
    }

    /*******************************************************************************************************
    * @description Builds a SOQL Query with offset. Deals with the limit of 2000 queries in Salesforce applying a jump between Ids
    * @param offset is the query jump
    * @param fieldToOffset is the SObject field to compare for the jump
    * @param SObjectClassName is the query SObject class type
    * @param querySelect is the select from part
    * @param queryWhere the WHERE conditions
    * @param querySort the query sort
    * @param queryGroupBy the query group by
    * @param queryLimit the query LIMIT
    * @return  the parsed query ready to be executed
    * @example
    * String query = GenericDmlInstance.addQueryOffset(0,'SELECT Id FROM Account',' WHERE isNew__c = true','', ' LIMIT 15');
    */
    private String addQueryOffset(Integer offset, string fieldToOffset, string SObjectClassName, string querySelect, string queryWhere, string querySort, string queryGroupBy, string queryLimit) {
        String query = '';
        Integer apexQueryLimit = 2000;
        String lastOffsetDataId = null;
        Integer offsetPages = offset/apexQueryLimit;

        if (String.isBlank(querySort)) {
            querySort = ' ORDER BY Id';
        }

        if (String.isBlank(fieldToOffset)) {
            fieldToOffset = 'Id';
        }

        if (offsetPages > 0) {
            for (integer i = 0; i < offsetPages; i++) {
                offset = offset - (apexQueryLimit*i);
                if (lastOffsetDataId != null) {
                    query = querySelect + queryWhere + ' and ' + fieldToOffset + ' > \'' + lastOffsetDataId + '\'' + queryGroupBy + querySort + ' LIMIT ' + apexQueryLimit;
                } else {
                    query = querySelect + queryWhere + queryGroupBy + querySort + ' LIMIT ' + apexQueryLimit;
                }
                lastOffsetDataId = this.findOffset(query, fieldToOffset, SObjectClassName);
            }
            offset = offset - apexQueryLimit;
            query = querySelect + queryWhere + ' and ' + fieldToOffset + ' > \'' + lastOffsetDataId + '\'' + queryGroupBy + querySort + queryLimit +' OFFSET '+ offset;
        }
        else {
            query = querySelect + queryWhere + queryGroupBy + querySort + queryLimit +' OFFSET '+ offset;
        }
        return query;
    }

	/*******************************************************************************************************
    * @description Builds the select part of the query with the fields.
    * @param currentObject the object to look up
    * @param selectableFields is an optional parameter: limit the return fields with a list. If you want a count(), just include it in this array
    * @param checkPermissions is an optional parameter: if true, it will check object and fields permissions
    * @param checkFields is an optional parameter: if true, it will check for the existance of fields selected in the SObject
    * @return  string with the select part
    * @example
    * List<SObject> a = GenericDmlInstance.buildSelectPart(Schema.SObjectType,null);
    */
	private String buildSelectPart(Schema.SObjectType currentObject, List<String> selectableFields, boolean checkPermissions, boolean checkFields) {
        Set<String> objectFields = null;
        String selectQuery = 'SELECT ';
        
		if (selectableFields != null && !selectableFields.isEmpty()) {
            if (checkPermissions) {
                this.CheckReadPermissions(currentObject,selectableFields);
            }
            if (checkFields) {
                Map<String, Schema.SObjectField> fieldMap = currentObject.getDescribe().fields.getMap();
                objectFields = fieldMap.keySet();
            }

            integer selectableFieldsSize = selectableFields.size();
			for (integer index = 0; index < selectableFieldsSize; index++) {
				String field = String.escapeSingleQuotes(selectableFields[index]);
				if (String.isNotBlank(field)) {
					boolean fieldIsAggregate = field.toUpperCase().contains('COUNT(')
						|| field.toUpperCase().contains('SUM(')
						|| field.toUpperCase().contains('MIN(')
						|| field.toUpperCase().contains('MAX(')
						|| field.toUpperCase().contains('AVG(')
                        || field.toUpperCase().contains('.');//it means that is a lookup field

                    if (checkFields && !fieldIsAggregate && !objectFields.contains(field.toLowerCase())) {
                        throw new GenericDmlException('##GenericDml Error - The Object ' + this.sObjectName + ' doesn\'t contain the Field ' + selectableFields[index] +'##');
                    }

                    selectQuery += ' ' + field;
                    if (index < selectableFieldsSize -1) {
                        selectQuery += ',';
                    }
				}
			}
		}
		else {
            Map<String, Schema.SObjectField> fieldMap = currentObject.getDescribe().fields.getMap();
            objectFields = fieldMap.keySet();
			selectableFields = new List<String>(objectFields);
			if (checkPermissions) {
                this.CheckReadPermissions(currentObject,selectableFields);
            }
			integer selectableFieldsSize = selectableFields.size();
			for (integer index = 0; index < selectableFieldsSize; index++) {
				String field = selectableFields[index];
				selectQuery += ' ' + field;
				if (index < selectableFieldsSize -1) {
					selectQuery += ',';
				}
			}
		}
		return selectQuery + ' FROM ' + currentObject;
	}

	/*******************************************************************************************************
    * @description Builds the where part of the query.
    * @param whereClauses the clauses. After the first one, please define if it's an AND or an OR
    * @return  string with the where part
    * @example
    * String a = GenericDmlInstance.buildWherePart(new List<String>{'Id == 1','AND Name = \'teste\''});
    */
    private String buildWherePart(List<String> whereClauses) {
        String selectWhere = '';


		if (whereClauses != null && !whereClauses.isEmpty()) {
			integer whereClausesSize = whereClauses.size();
			selectWhere += ' WHERE';
			for (integer index = 0; index < whereClausesSize; index++) {
				String whereClause = whereClauses[index];
				if (String.isNotBlank(whereClause)) {
                   
                        selectWhere += ' ' + whereClause;
                 
                   
				}
			}
		}
		return selectWhere;
	}

	/*******************************************************************************************************
    * @description Builds the order by part of the query.
    * @param orderByClauses the clauses. Also define the ASC or DESC (ASC is default if not defined)
    * @param nullsLast defines if the ordered data should set the nulls first or not. By default, it sets nulls to first
    * @return  string with the order by part
    * @example
    * String a = GenericDmlInstance.buildOrderByPart(new List<String>{'Name DESC'},null);
    */
	private String buildOrderByPart(List<String> orderByClauses, Boolean nullsLast) {
		String selectOrderBy = '';

		if (orderByClauses != null && !orderByClauses.isEmpty()) {
			integer orderByClausesSize = orderByClauses.size();
			selectOrderBy += ' ORDER BY';
			for (integer index = 0; index < orderByClausesSize; index++) {
				String orderByClause = String.escapeSingleQuotes(orderByClauses[index]);
				if (String.isNotBlank(orderByClause)) {
					selectOrderBy += ' ' + orderByClause;
					if (index < orderByClausesSize -1) {
						selectOrderBy += ',';
					}
				}
			}
			if (nullsLast != null && nullsLast == true) {
				selectOrderBy += ' NULLS last';
			}
		}
		return selectOrderBy;
	}

    private List<SObject> parseAgreggateToSObject(String selectPart, List<AggregateResult> aggregateResults) {
        List<String> selectableFields = selectPart.split(',');
        List<SObject> results = new List<SObject>();
        Schema.SObjectType currentObject = Schema.getGlobalDescribe().get(this.sObjectName);
        Map<String, Schema.SObjectField> fieldMap = currentObject.getDescribe().fields.getMap();
		Set<String> objectFields = fieldMap.keySet();

        for(AggregateResult a: aggregateResults)
        {   

        }

        return results;
    }

	/*******************************************************************************************************
    * @description Returns a list of SObjects. By default, it returns all fields from the record
    * @param objectId the Id of the object record to look up
    * @param selectableFields is an optional parameter: limit the return fields with a list. If you want a count(), just include it in this array
    * @param checkPermissions is an optional parameter: if true, it will check object and fields permissions
    * @param checkFields is an optional parameter: if true, it will check for the existance of fields selected in the SObject
    * @return  list of SObjects with the type of the instance class GenericDml
    * @example
    * List<SObject> a = GenericDmlInstance.selectById('t56WW56CCFF',null);
    */
	public List<SObject> selectById(Id objectId, List<String> selectableFields, boolean checkPermissions, boolean checkFields) {
        List<SObject> returnObjects = new List<SObject>();
       
		try {
            if (!String.isBlank(objectId)) {
                Schema.SObjectType currentObject = Schema.getGlobalDescribe().get(this.sObjectName);

                String selectPart = this.buildSelectPart(currentObject,selectableFields, checkPermissions, checkFields);

                String selectWhere = this.buildWherePart(new List<String>{' Id = \'' + objectId + '\''});
                
                returnObjects = Database.query(selectPart + selectWhere); 
            }
            else {
                throw new GenericDmlException('selectById Error - ' + 'objectId is an empty string');
            }
		}
		catch(Exception ex) {
			throw new GenericDmlException('##GenericDml Error - ' + ex.getMessage() + ' Stacktrace: ' + ex.getStackTraceString() + '##');
		}
		return returnObjects;
	}

	/*******************************************************************************************************
    * @description Returns the counting of SObject records
    * @param whereClauses the clauses. After the first one, please define if it's an AND or an OR
    * @param groupByClauses is an optional parameter: its the query group by
    * @param checkPermissions is an optional parameter: if true, it will check object and fields permissions
    * @param checkFields is an optional parameter: if true, it will check for the existance of fields selected in the SObject
    * @return  the count of records
    * @example
    * Integer a = GenericDmlInstance.count(new List<String>{'Id == 1','AND Name = \'teste\''},'');
    */
	public Integer count(List<String> whereClauses, string groupByClauses, boolean checkPermissions, boolean checkFields) {
		Integer count = 0;
		try {
			Schema.SObjectType currentObject = Schema.getGlobalDescribe().get(this.sObjectName);

			String selectPart = this.buildSelectPart(currentObject,new List<String>{'count(Id)countIDs'},checkPermissions, checkFields);

			String selectWhere = this.buildWherePart(whereClauses);

            groupByClauses = groupByClauses == null ? '' : groupByClauses;
			
			List<AggregateResult> returnObjects = Database.query(selectPart + selectWhere + groupByClauses); 
			AggregateResult countedObject = returnObjects[0];
			count = (Integer)countedObject.get('countIDs');
		}
		catch(Exception ex) {
			throw new GenericDmlException('##GenericDml Error - ' + ex.getMessage()  + ex.getStackTraceString() + '##');
		}
		return count;
	}

    /*******************************************************************************************************
    * @description Returns a list of SObjects. By default, it returns all fields from the record
    * @param pageNumber is the query jump
    * @param pageSize is the query jump
    * @param SearchKeyword is the search by text clause
    * @param splitSearchByOr is an optional parameter: defines if the words on SearchKeyword should be splitted with OR clause. If false, they are splitted with AND condition
    * @param selectableFields is an optional parameter: limit the return fields with a list. If you want a count(), just include it in this array
    * @param whereClauses is an optional parameter: its the query clauses
    * @param orderByClauses is an optional parameter: its the query sorts
    * @param groupByClauses is an optional parameter: its the query group by
    * @param nullsLast defines if the ordered data should set the nulls first or not. By default, it sets nulls to first
    * @param searchByInIds is an optional parameter: contains the ID's for the IN clause
    * @param checkPermissions is an optional parameter: if true, it will check object and fields permissions
    * @param checkFields is an optional parameter: if true, it will check for the existance of fields selected in the SObject
    * @return  list of SObjects with the type of the instance class GenericDml
    * @example
    * String query = teste.buildSelectRecordsQuery(1,15,null,null,new List<String>{'Id','Name'},null, new List<String>{'Name','Id'},'group by Id,Name',true);
    */
    private String buildSelectRecordsQuery(Integer pageNumber, Integer pageSize, String SearchKeyword, boolean splitSearchByOr, List<String> selectableFields,
											 List<String> whereClauses, List<String> orderByClauses, string groupByClauses, Boolean nullsLast, Set<Id> searchByInIds, boolean checkPermissions, boolean checkFields)
    {
        String finalQuery = '';
        try {
			Schema.SObjectType currentObject = Schema.getGlobalDescribe().get(this.sObjectName);

            groupByClauses = groupByClauses == null ? '' : ' ' + groupByClauses;
            SearchKeyword = SearchKeyword == null ? '' : SearchKeyword;

            String fieldToOffset = 'Id';
            if (orderByClauses != null && !orderByClauses.isEmpty()) {
                String aux = orderByClauses[0].toLowerCase();
                List<String> aux2 = aux.split(' ');
                if (aux2.size() > 0) {
                    fieldToOffset = aux2[0].trim();
                }
            }

			String selectPart = this.buildSelectPart(currentObject,selectableFields, checkPermissions, checkFields);

			String selectWhere = this.buildWherePart(whereClauses);

			String selectOrderBy = this.buildOrderByPart(orderByClauses,nullsLast);

			if (!String.isBlank(SearchKeyword))
			{
				this.processQuerySearchByText(null, true, splitSearchByOr, SearchKeyword, this.sObjectName,selectWhere, searchByInIds);
                selectWhere = ' WHERE Id IN :searchByInIds';
                // throw new GenericDmlException(JSON.serialize(searchByInIds));
			}

            Integer offset = 0;
            String filterLimit = '';
            if (pageSize > 0) {
                filterLimit = ' LIMIT ' + pageSize;
                if(pageSize>2){
                    offset = ((Integer)pageNumber -1) * pageSize;
                }
            }
            else if (pageSize < 0) {
                throw new GenericDmlException('##buildSelectRecordsQuery Error - the pageSize parameter has to be non-negative');
            }

            finalQuery = this.addQueryOffset(offset, fieldToOffset, this.sObjectName, selectPart, selectWhere, selectOrderBy, groupByClauses, filterLimit);
		}
		catch(Exception ex) {
			throw new GenericDmlException('##buildSelectRecordsQuery Error - ' + ex.getMessage() + ' Stacktrace: ' + ex.getStackTraceString() + '##');
		}
		return finalQuery;
    }

	/*******************************************************************************************************
    * @description Returns a list of SObjects. By default, it returns all fields from the record
    * @param pageNumber is the query jump
    * @param pageSize is the query jump
    * @param SearchKeyword is the search by text clause
    * @param splitSearchByOr is an optional parameter: defines if the words on SearchKeyword should be splitted with OR clause. If false, they are splitted with AND condition
    * @param selectableFields is an optional parameter: limit the return fields with a list. If you want a count(), just include it in this array
    * @param whereClauses is an optional parameter: its the query clauses
    * @param orderByClauses is an optional parameter: its the query sorts
    * @param nullsLast defines if the ordered data should set the nulls first or not. By default, it sets nulls to first
    * @param checkPermissions is an optional parameter: if true, it will check object and fields permissions
    * @param checkFields is an optional parameter: if true, it will check for the existance of fields selected in the SObject
    * @return  list of SObjects with the type of the instance class GenericDml
    * @example
    * List<Account> accounts = (Account[])teste.selectRecords(1,15,'edge',null,new List<String>{'Id','Name'},null, new List<String>{'Name','Id'},true);
    */
	public List<SObject> selectRecords(Integer pageNumber, Integer pageSize, String SearchKeyword, boolean splitSearchByOr, List<String> selectableFields,
											 List<String> whereClauses, List<String> orderByClauses, Boolean nullsLast, boolean checkPermissions, boolean checkFields) {
        List<SObject> returnObjects = new List<SObject>();
        
		try {
            
            Set<Id> searchByInIds = new Set<Id>();
            String finalQuery = this.buildSelectRecordsQuery(pageNumber, pageSize, SearchKeyword, splitSearchByOr, selectableFields, whereClauses, orderByClauses, '', nullsLast, searchByInIds, checkPermissions, checkFields);
			
            returnObjects = Database.query(finalQuery);
		}
		catch(Exception ex) {
			throw new GenericDmlException('##GenericDml Error - ' + ex.getMessage() + ' Stacktrace: ' + ex.getStackTraceString() + '##');
		}
		return returnObjects;
	}

    /*******************************************************************************************************
    * @description Returns a list of AggregateResult. By default, it returns all fields from the record
    * @param pageNumber is the query jump
    * @param pageSize is the query jump
    * @param SearchKeyword is the search by text clause
    * @param splitSearchByOr is an optional parameter: defines if the words on SearchKeyword should be splitted with OR clause. If false, they are splitted with AND condition
    * @param selectableFields is an optional parameter: limit the return fields with a list. If you want a count(), just include it in this array
    * @param whereClauses is an optional parameter: its the query clauses
    * @param orderByClauses is an optional parameter: its the query sorts
    * @param groupByClauses is an optional parameter: its the query group by
    * @param nullsLast defines if the ordered data should set the nulls first or not. By default, it sets nulls to first
    * @param checkPermissions is an optional parameter: if true, it will check object and fields permissions
    * @param checkFields is an optional parameter: if true, it will check for the existance of fields selected in the SObject
    * @return  list of SObjects with the type of the instance class GenericDml
    * @example
    * List<AggregateResult> accounts = teste.selectRecords(1,15,null,null,new List<String>{'Id','Name'},null, new List<String>{'Name','Id'},'group by Id,Name',true);
    */
	public List<AggregateResult> selectRecords(Integer pageNumber, Integer pageSize, String SearchKeyword, boolean splitSearchByOr, List<String> selectableFields,
											 List<String> whereClauses, List<String> orderByClauses, string groupByClauses, Boolean nullsLast, boolean checkPermissions, boolean checkFields) {
        List<AggregateResult> returnObjects = new List<AggregateResult>();
		try {
            if (String.isBlank(groupByClauses)) {
			    throw new GenericDmlException('##selectRecords Error - ' + 'the group by clause is mandatory' + '##');
            }
            
            Set<Id> searchByInIds = new Set<Id>();

			String finalQuery = this.buildSelectRecordsQuery(pageNumber, pageSize, SearchKeyword, splitSearchByOr, selectableFields, whereClauses, orderByClauses, groupByClauses, nullsLast, searchByInIds, checkPermissions, checkFields);
		
            returnObjects = Database.query(finalQuery); 
		}
		catch(Exception ex) {
			throw new GenericDmlException('##GenericDml Error - ' + ex.getMessage() + ' Stacktrace: ' + ex.getStackTraceString() + '##');
		}
		return returnObjects;
	}

    /*******************************************************************************************************
    * @description Returns a Map of aggregated fields. Useful to build IN clauses, since Apex is limited in the use of for loops
    * @param fieldsToMap are the 2 fields to map
    * @param SearchKeyword is the search by text clause
    * @param splitSearchByOr is an optional parameter: defines if the words on SearchKeyword should be splitted with OR clause. If false, they are splitted with AND condition
    * @param selectableFields is an optional parameter: limit the return fields with a list. If you want a count(), just include it in this array
    * @param whereClauses is an optional parameter: its the query clauses
    * @param orderByClauses is an optional parameter: its the query sorts
    * @param groupByClauses is an optional parameter: its the query group by
    * @param nullsLast defines if the ordered data should set the nulls first or not. By default, it sets nulls to first
    * @param checkPermissions is an optional parameter: if true, it will check object and fields permissions
    * @param checkFields is an optional parameter: if true, it will check for the existance of fields selected in the SObject
    * @return  list of SObjects with the type of the instance class GenericDml
    * @example
    * Set<String> accounts = teste.buildSelectableData(new List<String>{'Id','Quantity'},null,null,new List<String>{'Id','sum(Quantity__c)Quantity'},null, new List<String>{'Name','Id'},'group by Id,Name',true);
    */
	public Map<Object,Object> buildSelectableData(List<String> fieldsToMap, String SearchKeyword, boolean splitSearchByOr, List<String> selectableFields,
                                                     List<String> whereClauses, List<String> orderByClauses, string groupByClauses, Boolean nullsLast, boolean checkPermissions, boolean checkFields)
    {
		Map<Object,Object> returnMap = new Map<Object,Object>();
		try {
            if (String.isBlank(groupByClauses)) {
			    throw new GenericDmlException('##buildSelectableData Error - ' + 'the group by clause is mandatory' + '##');
            }

            Set<Id> searchByInIds = new Set<Id>();

			String finalQuery = this.buildSelectRecordsQuery(1, 0, SearchKeyword, splitSearchByOr, fieldsToMap, whereClauses, orderByClauses, groupByClauses, nullsLast, searchByInIds, checkPermissions, checkFields);
			
            List<AggregateResult> returnObjects = Database.query(finalQuery); 
		
            for(AggregateResult objectAggregated : returnObjects)
            {
                returnMap.put(objectAggregated.get(fieldsToMap[0]),objectAggregated.get(fieldsToMap[1]));
            }
		}
		catch(Exception ex) {
			throw new GenericDmlException('##GenericDml Error - ' + ex.getMessage() + ' Stacktrace: ' + ex.getStackTraceString() + '##');
		}
		return returnMap;
	}

    /*******************************************************************************************************
    * @description Returns a Set of field Ids. Useful to build IN clauses, since Apex is limited in the use of for loops
    * @param fieldsToMap are the 2 fields to map
    * @param SearchKeyword is the search by text clause
    * @param splitSearchByOr is an optional parameter: defines if the words on SearchKeyword should be splitted with OR clause. If false, they are splitted with AND condition
    * @param whereClauses is an optional parameter: its the query clauses
    * @param orderByClauses is an optional parameter: its the query sorts
    * @param nullsLast defines if the ordered data should set the nulls first or not. By default, it sets nulls to first
    * @param checkPermissions is an optional parameter: if true, it will check object and fields permissions
    * @param checkFields is an optional parameter: if true, it will check for the existance of fields selected in the SObject
    * @return  list of SObjects with the type of the instance class GenericDml
    * @example
    * Set<String> accounts = teste.buildSelectableData('Id',null,null,null, new List<String>{'Name','Id'},true);
    */
	public Set<String> buildSelectableData(String objectIdField, String SearchKeyword, boolean splitSearchByOr,
											 List<String> whereClauses, List<String> orderByClauses, Boolean nullsLast, boolean checkPermissions, boolean checkFields) {
		Set<String> returnMap = new Set<String>();
		try {
            Set<Id> searchByInIds = new Set<Id>();
			String finalQuery = this.buildSelectRecordsQuery(1,0, SearchKeyword, splitSearchByOr, new List<String>{objectIdField}, whereClauses, orderByClauses, '', nullsLast, searchByInIds, checkPermissions, checkFields);
			
            List<SObject> returnObjects = Database.query(finalQuery); 
		
            for(SObject objectAggregated : returnObjects)
            {
                returnMap.add((String)objectAggregated.get(objectIdField));
            }
		}
		catch(Exception ex) {
			throw new GenericDmlException('##GenericDml Error - ' + ex.getMessage() + ' Stacktrace: ' + ex.getStackTraceString() + '##');
		}
		return returnMap;
	}

    /*******************************************************************************************************
    * @description Returns a Set of field Ids. Useful to build IN clauses, since Apex is limited in the use of for loops
    * @param fieldsToMap are the 2 fields to map
    * @param SearchKeyword is the search by text clause
    * @param splitSearchByOr is an optional parameter: defines if the words on SearchKeyword should be splitted with OR clause. If false, they are splitted with AND condition
    * @param whereClauses is an optional parameter: its the query clauses
    * @param orderByClauses is an optional parameter: its the query sorts
    * @param groupByClauses is an optional parameter: its the query group by
    * @param nullsLast defines if the ordered data should set the nulls first or not. By default, it sets nulls to first
    * @param checkPermissions is an optional parameter: if true, it will check object and fields permissions
    * @param checkFields is an optional parameter: if true, it will check for the existance of fields selected in the SObject
    * @return  list of SObjects with the type of the instance class GenericDml
    * @example
    * Set<String> accounts = teste.buildSelectableData('Id',null,null,null, new List<String>{'Name','Id'},'group by Id,Name',true);
    */
	public Set<String> buildSelectableData(String objectIdField, String SearchKeyword, boolean splitSearchByOr,
											 List<String> whereClauses, List<String> orderByClauses, string groupByClauses, Boolean nullsLast, boolean checkPermissions, boolean checkFields) {
		Set<String> returnMap = new Set<String>();
		try {
            if (String.isBlank(groupByClauses)) {
			    throw new GenericDmlException('##buildSelectableData Error - ' + 'the group by clause is mandatory' + '##');
            }
            Set<Id> searchByInIds = new Set<Id>();

			String finalQuery = this.buildSelectRecordsQuery(1,0, SearchKeyword, splitSearchByOr, new List<String>{objectIdField}, whereClauses, orderByClauses, groupByClauses, nullsLast, searchByInIds, checkPermissions, checkFields);
			
            List<AggregateResult> returnObjects = Database.query(finalQuery); 
		
            for(AggregateResult objectAggregated : returnObjects)
            {
                returnMap.add((String)objectAggregated.get(objectIdField));
            }
		}
		catch(Exception ex) {
			throw new GenericDmlException('##GenericDml Error - ' + ex.getMessage() + ' Stacktrace: ' + ex.getStackTraceString() + '##');
		}
		return returnMap;
	}

    /*******************************************************************************************************
    * @description Returns a String with Ids. Useful to build IN clauses, since Apex is limited in the use of for loops
    * @param fieldsToMap are the 2 fields to map
    * @param SearchKeyword is the search by text clause
    * @param splitSearchByOr is an optional parameter: defines if the words on SearchKeyword should be splitted with OR clause. If false, they are splitted with AND condition
    * @param whereClauses is an optional parameter: its the query clauses
    * @param orderByClauses is an optional parameter: its the query sorts
    * @param nullsLast defines if the ordered data should set the nulls first or not. By default, it sets nulls to first
    * @param checkPermissions is an optional parameter: if true, it will check object and fields permissions
    * @param checkFields is an optional parameter: if true, it will check for the existance of fields selected in the SObject
    * @return  String concatenated by comma with ids
    * @example
    * String Ids = teste.buildSelectableDataAsString('Id',null,null,null, new List<String>{'Name','Id'},true);
    */
	public String buildSelectableDataAsString(String objectIdField, String SearchKeyword, boolean splitSearchByOr,
											 List<String> whereClauses, List<String> orderByClauses, Boolean nullsLast, boolean checkPermissions, boolean checkFields) {
		String returnMap = '';
		try {
            Set<Id> searchByInIds = new Set<Id>();
			String finalQuery = this.buildSelectRecordsQuery(1,0, SearchKeyword, splitSearchByOr, new List<String>{objectIdField}, whereClauses, orderByClauses, '', nullsLast, searchByInIds, checkPermissions, checkFields);
			
            List<SObject> returnObjects = Database.query(finalQuery); 
            Integer returnedSize = returnObjects != null ? returnObjects.size() : 0;
            for(integer index = 0; index < returnedSize; index++)
            {
                returnMap += (String)returnObjects[index].get(objectIdField);
                if (index < returnedSize - 1) {
                    returnMap += ',';
                }
            }
		}
		catch(Exception ex) {
			throw new GenericDmlException('##GenericDml Error - ' + ex.getMessage() + ' Stacktrace: ' + ex.getStackTraceString() + '##');
		}
		return returnMap;
	}

    /*******************************************************************************************************
    * @description Returns a String with Ids. Useful to build IN clauses, since Apex is limited in the use of for loops
    * @param fieldsToMap are the 2 fields to map
    * @param SearchKeyword is the search by text clause
    * @param splitSearchByOr is an optional parameter: defines if the words on SearchKeyword should be splitted with OR clause. If false, they are splitted with AND condition
    * @param whereClauses is an optional parameter: its the query clauses
    * @param orderByClauses is an optional parameter: its the query sorts
    * @param groupByClauses is an optional parameter: its the query group by
    * @param nullsLast defines if the ordered data should set the nulls first or not. By default, it sets nulls to first
    * @param checkPermissions is an optional parameter: if true, it will check object and fields permissions
    * @param checkFields is an optional parameter: if true, it will check for the existance of fields selected in the SObject
    * @return  String concatenated by comma with ids
    * @example
    * String Ids = teste.buildSelectableDataAsString('Id',null,null,null, new List<String>{'Name','Id'},'group by Id,Name',true);
    */
	public String buildSelectableDataAsString(String objectIdField, String SearchKeyword, boolean splitSearchByOr,
											 List<String> whereClauses, List<String> orderByClauses, string groupByClauses, Boolean nullsLast, boolean checkPermissions, boolean checkFields) {
		String returnMap = '';
		try {
            if (String.isBlank(groupByClauses)) {
			    throw new GenericDmlException('##buildSelectableDataAsString Error - ' + 'the group by clause is mandatory' + '##');
            }
            Set<Id> searchByInIds = new Set<Id>();

			String finalQuery = this.buildSelectRecordsQuery(1,0, SearchKeyword, splitSearchByOr, new List<String>{objectIdField}, whereClauses, orderByClauses, groupByClauses, nullsLast, searchByInIds, checkPermissions, checkFields);
			
            List<AggregateResult> returnObjects = Database.query(finalQuery); 

		    Integer returnedSize = returnObjects != null ? returnObjects.size() : 0;
            for(integer index = 0; index < returnedSize; index++)
            {
                returnMap += (String)returnObjects[index].get(objectIdField);
                if (index < returnedSize - 1) {
                    returnMap += ',';
                }
            }
		}
		catch(Exception ex) {
			throw new GenericDmlException('##GenericDml Error - ' + ex.getMessage() + ' Stacktrace: ' + ex.getStackTraceString() + '##');
		}
		return returnMap;
	}

    /*******************************************************************************************************
    * @description The Apex defines that the inserts should be done with a list of objects
    * @param objectsToInsert is the list of objects to insert
    * @return  result message 'INSERT SUCCESS' or empty in case of error
    * @example
    * String resultMessage = teste.insertBulk(objectsToInsert);
    */
    public String insertBulk(List<SObject> objectsToInsert) {
        String message = '';
        try {
            if (objectsToInsert != null && !objectsToInsert.isEmpty()) {
                insert objectsToInsert;
                message = 'INSERT SUCCESS';
            }
            else {
                throw new GenericDmlException('##insertBulk Error - ' + 'the insert List is empty or null' + '##');
            }
        }
        catch (Exception ex) {
			throw new GenericDmlException('##GenericDml Error - ' + ex.getMessage() + ' Stacktrace: ' + ex.getStackTraceString() + '##');
        }
        return message;
    }

    /*******************************************************************************************************
    * @description The Apex defines that the updates should be done with a list of objects
    * @param objectsToUpdate is the list of objects to update
    * @return  result message 'UPDATE SUCCESS' or empty in case of error
    * @example
    * String resultMessage = teste.updateBulk(objectsToUpdate);
    */
    public String updateBulk(List<SObject> objectsToUpdate) {
        String message = '';
        try {
            if (objectsToUpdate != null && !objectsToUpdate.isEmpty()) {
                update objectsToUpdate;
                message = 'UPDATE SUCCESS';
            }
            else {
                throw new GenericDmlException('##updateBulk Error - ' + 'the update List is empty or null' + '##');
            }
        }
        catch (Exception ex) {
			throw new GenericDmlException('##GenericDml Error - ' + ex.getMessage() + ' Stacktrace: ' + ex.getStackTraceString() + '##');
        }
        return message;
    }

    /*******************************************************************************************************
    * @description The Apex defines that the deletes should be done with a list of objects
    * @param objectsToDelete is the list of objects to delete
    * @return  result message 'DELETE SUCCESS' or empty in case of error
    * @example
    * String resultMessage = teste.deleteBulk(objectsToDelete);
    */
    public String deleteBulk(List<SObject> objectsToDelete) {
        String message = '';
        try {
            if (objectsToDelete != null && !objectsToDelete.isEmpty()) {
                delete objectsToDelete;
                message = 'DELETE SUCCESS';
            }
            else {
                throw new GenericDmlException('##deleteBulk Error - ' + 'the delete List is empty or null' + '##');
            }
        }
        catch (Exception ex) {
			throw new GenericDmlException('##GenericDml Error - ' + ex.getMessage() + ' Stacktrace: ' + ex.getStackTraceString() + '##');
        }
        return message;
    }

    /*******************************************************************************************************
    * @description Deletes a record by its Id
    * @param objectIdToDelete is the Id of the record to delete
    * @return  result message 'DELETE SUCCESS' or empty in case of error
    * @example
    * String resultMessage = teste.deleteById('gdfkn45vcsdfg4');
    */
    public String deleteById(Id objectIdToDelete) {
        String message = '';
        try {
            if (objectIdToDelete != null) {
                List<SObject> objectsToDelete = this.selectById(objectIdToDelete, new List<String>{'Id'}, false, false);
                if (objectsToDelete != null && !objectsToDelete.isEmpty()) {
                    delete objectsToDelete;
                    message = 'DELETE SUCCESS';
                }
                else {
                    throw new GenericDmlException('##deleteById Error - ' + 'no rows selected for delete for the Id ' + objectIdToDelete + '##');
                }
            }
            else {
                throw new GenericDmlException('##deleteById Error - ' + 'the Id for delete cannot be null ' + '##');
            }
        }
        catch (Exception ex) {
			throw new GenericDmlException('##GenericDml Error - ' + ex.getMessage() + ' Stacktrace: ' + ex.getStackTraceString() + '##');
        }
        return message;
    }

    /*******************************************************************************************************
    * @description Gets a list of fields related to the SObject defined globally
    * @return  result list of fields
    * @example
    * List<Util_GenericDML.GenericFieldMapper> resultMessage = teste.getSObjectFieldsList();
    */
    public List<GenericFieldMapper> getSObjectFieldsList() {
        List<GenericFieldMapper> fieldsData = new List<GenericFieldMapper>();
        Schema.SObjectType currentObject = Schema.getGlobalDescribe().get(this.sObjectName);
        Map<String, Schema.SObjectField> fieldMap = currentObject.getDescribe().fields.getMap();
        Set<String> fields = fieldMap.keySet();
        for (String fieldName: fields) {
            GenericFieldMapper fieldData = new GenericFieldMapper();
            fieldData.fieldName = fieldName;
            fieldData.fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();//It provides to get the object field label.
            fieldData.fieldType = fieldMap.get(fieldName).getDescribe().getType().name();//It provides to get the object field type
            fieldsData.add(fieldData);
        }
        return fieldsData;
    }

    public class GenericFieldMapper {
        public string fieldName;
        public string fieldLabel;
        public string fieldType;
    }
}