//------------------------------------------------------------------------------
//  Copyright (c) 2012 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted you to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package com.franklincovey.remote.rest.impl.javascript
{
	import com.franklincovey.remote.rest.api.IRESTClient;
	import com.franklincovey.remote.rest.api.RESTEvent;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.external.ExternalInterface;
	import flash.system.Security;
	import flash.utils.Dictionary;
	
	import mx.core.FlexGlobals;
	import mx.utils.UIDUtil;
	
	import org.robotlegs.oil.async.Promise;

	public class JavascriptRESTClient implements IRESTClient
	{
		private static var _singleton:JavascriptRESTClient;

		public static function getInstance():JavascriptRESTClient {
			if(!_singleton) {
				_singleton = new JavascriptRESTClient(new JavascriptRESTClientSingletonToken);
			}

			return _singleton;
		}

		public function JavascriptRESTClient(singleton:JavascriptRESTClientSingletonToken)
		{
			initialize();
		}


		private var requestUIDMap:Dictionary = new Dictionary();
		private static var _initialized:Boolean = false;

		public function doGET(url:String, promise:Promise = null):Promise
		{			
			return doAction('GET', url);
		}

		public function doPOST(url:String, data:Object, promise:Promise = null):Promise
		{
			return doAction('POST', url, data, promise);
		}

		public function doPUT(url:String, data:Object, promise:Promise = null):Promise
		{
			return doAction('PUT', url, data, promise);
		}

		public function doDELETE(url:String, data:Object, promise:Promise = null):Promise
		{
			return doAction('DELETE', url, data, promise);
		}

		public function doAction(action:String, url:String, data:Object = null, promise:Promise = null):Promise
		{
			var request:XMLHTTPRequestWrapper = createRequest(promise);
			request.open(action, url, true);
			request.send();

			return request.promise;
		}

		public function createRequest(promise:Promise = null):XMLHTTPRequestWrapper {
			var request:XMLHTTPRequestWrapper = new XMLHTTPRequestWrapper(promise);
			requestUIDMap[request.uid] = request;

			return request;
		}

		public static function get initialized():Boolean {
			return JavascriptRESTClient._initialized;
		}

		private function initialize():void {
			if(!JavascriptRESTClient._initialized) {

				var appName:String = FlexGlobals.topLevelApplication.toString();
				var javascript:String = "FCREST = {" +
					"	requests: [],																				\n" +
					"	requestsUID: [],																			\n" +
					"	applicationAPI : document.getElementById('" + appName + "'),								\n" +  
					"	getRequest: function() {																	\n" +
					"		var ref = null;																			\n" +
					"		if (window.XMLHttpRequest) {															\n" +
					"			ref = new XMLHttpRequest();															\n" +
					"		} else if (window.ActiveXObject) {														\n" +
					"			ref = new ActiveXObject('MSXML2.XMLHTTP.3.0');										\n" +
					"		}																						\n" +
					"																								\n" +  
					"																								\n" +  
					"		ref.onreadystatechange	 = function(event) {											\n" +  
					"			if (ref.readyState == 4) {															\n" +  
					"				var uid = FCREST.requestsUID[ref];												\n" +  
					"				var statusCode = ref.status;													\n" +  
					"				var response = ref.responseText;												\n" +  
					"				var readyState = ref.readyState;												\n" +  
					"																								\n" +    
					"				FCREST.applicationAPI.handleStateChange(uid, readyState, statusCode, response);	\n" +  
					"			}																					\n" +  
					"		}																						\n" +  
					"																								\n" +  
					"		return ref;																				\n" +
					"	}																							\n" +
					"																								\n" +
					"}";

				ExternalInterface.call('eval', javascript);
				ExternalInterface.addCallback("handleStateChange", handleStateChange);
				Security.allowDomain("*");
				Security.allowInsecureDomain("*");
				JavascriptRESTClient._initialized = true;
			}
		}

		private function handleStateChange(uid:String, readyState:uint, statusCode:uint, response:String):void {
			var request:XMLHTTPRequestWrapper = requestUIDMap[uid] as XMLHTTPRequestWrapper;
			var event:RESTEvent = new RESTEvent(RESTEvent.READY_STATE_CHANGED);
			event.readyState = readyState;
			event.statusCode = statusCode;
			event.response = response;

			request.dispatchEvent(event);

			//Garbage Collect!
			delete requestUIDMap[uid];
		}
	}
}

class JavascriptRESTClientSingletonToken {

}

