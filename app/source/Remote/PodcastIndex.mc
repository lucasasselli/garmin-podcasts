using Toybox.WatchUi;
using Toybox.System;
using Toybox.Communications;
using Toybox.Cryptography;
using Toybox.StringUtil;

class PodcastIndex {

    function request(url, params, callback){
   		
   		var now = Time.now().value();
   		
   		var hash = new Cryptography.Hash({
		  	:algorithm => Toybox.Cryptography.HASH_SHA1
		});
		
		var fromArray = {
	        :fromRepresentation => StringUtil.REPRESENTATION_STRING_PLAIN_TEXT,
	        :toRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY,
			:encoding => StringUtil.CHAR_ENCODING_UTF8
	    };
	    
	   	var toString = {
	        :fromRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY,
	        :toRepresentation => StringUtil.REPRESENTATION_STRING_HEX,
			:encoding => StringUtil.CHAR_ENCODING_UTF8
	    };
    
		
		hash.update(StringUtil.convertEncodedString(Secrets.TOKEN + Secrets.SECRET + now, fromArray));	
					
		var auth = StringUtil.convertEncodedString(hash.digest(), toString);
				
		var headers = {
			"Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED,
			"X-Auth-Date" => now.format("%d"),
			"X-Auth-Key" => Secrets.TOKEN,
			"Authorization" => auth,
		};
	
	   	Communications.makeWebRequest(
	   		url, 
	   		params, 
	   		{
		    	:method => Communications.HTTP_REQUEST_METHOD_GET,
		    	:headers => headers,
		    	:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
	   		},
	   		callback);
    }
}