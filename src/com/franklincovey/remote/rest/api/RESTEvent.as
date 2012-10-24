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

