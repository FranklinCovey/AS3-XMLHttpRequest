//------------------------------------------------------------------------------
//  Copyright (c) 2012 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted you to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package com.franklincovey.remote.rest.api
{
	import org.robotlegs.oil.async.Promise;

	public interface IRESTClient
	{
		function doGET(url:String, promise:Promise = null):Promise;
		function doPOST(url:String, data:Object, promise:Promise = null):Promise;
		function doPUT(url:String, data:Object, promise:Promise = null):Promise;
		function doDELETE(url:String, data:Object, promise:Promise = null):Promise;
	}
}

