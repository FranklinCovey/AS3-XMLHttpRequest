//------------------------------------------------------------------------------
//  Copyright (c) 2012 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted you to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package com.franklincovey.remote.rest.api
{
	import flash.events.Event;

	public class RESTEvent extends Event
	{
		public static const READY_STATE_CHANGED:String = 'RESTEvent-READY_STATE_CHANGED';
		public static const COMPLETE:String = 'RESTEvent-COMPLETE';

		public var response:String;
		public var statusCode:uint;
		public var readyState:uint;

		public function RESTEvent(type:String)
		{
			super(type, false, false);
		}

		override public function clone():Event {
			var event:RESTEvent = new RESTEvent(type);

			event.response = response;
			event.statusCode = statusCode;
			event.readyState = readyState;

			return event;
		}
	}
}

