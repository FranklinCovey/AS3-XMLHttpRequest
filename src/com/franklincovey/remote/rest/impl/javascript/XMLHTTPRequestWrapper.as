//------------------------------------------------------------------------------
//  Copyright (c) 2012 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted you to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package com.franklincovey.remote.rest.impl.javascript
{

	import com.franklincovey.remote.rest.api.RESTEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
	
	import mx.utils.UIDUtil;
	
	import org.robotlegs.oil.async.Promise;

	public class XMLHTTPRequestWrapper extends EventDispatcher
	{
		private var _uid:String;
		private var _promise:Promise;

		public function XMLHTTPRequestWrapper(promise:Promise = null):void {
			if(!promise)
				promise = new Promise();

			_promise = promise;
			_uid = UIDUtil.getUID(promise);

			if(!JavascriptRESTClient.initialized) {
				throw new Error("JavascriptRESTClient must be initialized first!");
			}

			ExternalInterface.call('eval', 'FCREST.requests["' + _uid + '"] = FCREST.getRequest();');
			ExternalInterface.call('eval', 'FCREST.requestsUID[FCREST.requests["' + _uid + '"]] = "' + _uid + '";');

			addEventListener(RESTEvent.READY_STATE_CHANGED, handleStateChange);
		}

		public function get uid():String {
			return _uid;
		}
		public function get promise():Promise {
			return _promise;
		}

		public function open(action:String, url:String, async:Boolean):void {
			var asyncString:String = async ? 'true' : 'false';
			ExternalInterface.call('eval', 'FCREST.requests["' + uid + '"].open("' + action + '","' + url + '",' + asyncString + ');');
		}

		public function send(data:Object = null):void {
			var jsonData:String = JSON.stringify(data);
			ExternalInterface.call('eval', 'FCREST.requests["' + uid + '"].send(' + jsonData + ');');
		}

		public function handleStateChange(event:RESTEvent):void {
			if(event.readyState == 4) {
				var completeEvent:RESTEvent = new RESTEvent(RESTEvent.COMPLETE);
				completeEvent.readyState = 4;
				completeEvent.statusCode = event.statusCode;
				completeEvent.response = event.response;

				_promise.handleResult(completeEvent);
				dispatchEvent(completeEvent);

				//Garbage Collect!
				cleanUp();
			}
		}

		public function cleanUp():void {
			removeEventListener(RESTEvent.READY_STATE_CHANGED, handleStateChange);
			ExternalInterface.call('eval', 'delete FCREST.requestsUID[FCREST.requests["' + uid + '"]]');
			ExternalInterface.call('eval', 'delete FCREST.requests["' + uid + '"]');
		}
	}
}

