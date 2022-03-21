({
	doInit : function(component, event, helper) {
		
		// function to check user session defined through the getting of the profile
		// Returns a promise
		// window.GetProfile = $A.getCallback(function() {
		// 	return new Promise($A.getCallback(function(resolve, reject) {
		// 		var GetProfile = component.get('c.getUserProfile');
		// 		GetProfile.setCallback(this, function(response) {
		// 			var state = response.getState();
		// 			if (state === "SUCCESS") {
		// 				var parsed = JSON.parse(response.getReturnValue());
		// 				if (parsed)
		// 				{
		// 					resolve(parsed);
		// 				}
		// 				else {
		// 					reject(Error('GetProfile JSON parser error'));
		// 				}
		// 			}
		// 			else if (state === "INCOMPLETE") {
		// 				// do something
		// 			}
		// 			else if (state === "ERROR") {
		// 				var errors = response.getError();
		// 				let errorMessage = "Unknown error"; 
		// 				if (errors) {
		// 					if (errors[0] && errors[0].message) {
		// 						errorMessage = errors[0].message;
		// 					}
		// 				}
		// 				reject(Error('GetProfile API error: '+ errorMessage));
		// 			}
		// 		});
		// 		$A.enqueueAction(GetProfile);
		// 	}));
		// });

		(function(w){
			"use strict"; //Optional because LC on LockerService active runs in strict mode
		
			var utilMethods = {
				"getNoReferenceValue":getNoReferenceValue,
				"DealWithError":DealWithError,
				"NavigateToUrl": NavigateToUrl
			};
		
			function getNoReferenceValue(value) {
				let newAssignValue = value;
				//Object.assign(newAssignValue,value);
				return newAssignValue;
			}

			function NavigateToUrl(relativeURL, checkSession = true, isTop = true) {
				var url = window.location.href;
				var pathname = window.location.pathname;
				var index1 = url.indexOf(pathname);
				var index2 = url.indexOf("/", index1 + 1);
				var siteRoot = url.substr(0, index2);

				if (checkSession) {
					window.GetProfile().then(result => {
						if (isTop) {
							window.open(siteRoot + '/' + relativeURL, "_top");
						} else {
							window.open(siteRoot + '/' + relativeURL);
						}
		
						// var urlEvent = $A.get("e.force:navigateToURL");
						//      urlEvent.setParams({
						// 	 "url": siteRoot + '/' + relativeURL
						// 	 //"url": "/lista"
						// 	});
							
						//    urlEvent.fire();
		
					}).catch(error => {
						// navigate to login page
						window.open("login", "_top");
					});
				} else {
					if (isTop) {
						window.open(siteRoot + '/' + relativeURL, "_top");
					} else {
						window.open(siteRoot + '/' + relativeURL);
					}
				}
			}
		
			function DealWithError (err, customErrorMessage) {
				window.GetProfile().then(result => {
					console.log(err);
					// TODO joaopaalmeida: deal with the error
					// var url = window.location.href;
					// var pathname = window.location.pathname;
					// var index1 = url.indexOf(pathname);
					// var index2 = url.indexOf("/", index1 + 1);
					// var siteRoot = url.substr(0, index2);
					var errorMessage = "Unknown error";
					if (customErrorMessage && customErrorMessage != "") {
						errorMessage = customErrorMessage;
					}
					else if (err && err.param1 && Array.isArray(err.param1) && err.param1.length > 0) {
						var error = err.param1[0];
						if (error.message) {
							errorMessage = error.message + (error.stackTrace ? "\n" + error.stackTrace : "");
						}
						else {
							errorMessage = error;
						}
					}
					else if (err && err.param1) {
						errorMessage = err.param1;
					}
					var toastEvent = $A.get('e.force:showToast');
					toastEvent.setParams({
						'message': errorMessage,
						'type': 'error'
					});
					toastEvent.fire();
				}).catch(error => {
					// navigate to login page
					var toastEvent = $A.get('e.force:showToast');
					toastEvent.setParams({
						'message': 'User Session is invalid',
						'type': 'error'
					});
					toastEvent.fire();
					NavigateToUrl("login", false, true);
				});
			};
		
			w.myUtil = utilMethods;
		
		})(window);
	},

	getEventMethodName: function(component, event, helper) {
		var method = event.getParam("MethodName");
		var params = event.getParam("MethodParams");
		var parsed = null;
		try
		{
			parsed = JSON.parse(params);
		}
		catch(e)
		{
			parsed = { param1: params };
		}
		switch(method) {
			case 'DealWithError': {
				myUtil.DealWithError(parsed.param1);
			} break;
			case 'getNoReferenceValue': {
					myUtil.getNoReferenceValue(parsed.param1, parsed.param2);
			} break;
			case 'NavigateToUrl': {
				myUtil.NavigateToUrl(parsed.param1, parsed.param2 ? parsed.param2 : true, parsed.param3 ? parsed.param3 : true);
			} break;
			default: console.log('GlobalComponentService: method ' + method + 'is not defined'); break;
		}
	}
})