using Toybox.Application.Storage;
using Toybox.Media;

class Utils {

	function stringReplace(str, oldString, newString)
	{
		var result = str;
		
		while (true)
		{
			var index = result.find(oldString);
			
			if (index != null)
			{
				var index2 = index+oldString.length();
				result = result.substring(0, index) + newString + result.substring(index2, result.length());
			}else{
				return result;
			}
		}
		
		return null;
	}
	
	function findArrayField(array, field, value){
		if (array == null){
			return null;
		}
		for(var i=0; i<array.size(); i++){
			var x = array[i];
			if (field < x.size()){
				if (x[field] == value){
					return x;
				}
			}
		}
		
		return null;
	}
	
	function getArrayField(array, field){
	
		if (array == null){
			return [];
		}
		
		var x = [];
		
		for(var i=0; i<array.size(); i++){
			x.add(array[i][field]);
		}
		
		return x;
	}
	
	function getSafeStorageArray(key){
	   	var x = Storage.getValue(key);
        if(x == null) {
        	return [];
        }else{
        	return x;
        }
	}
	
	function getSafeDictKey(dict, key){
        if(dict.hasKey(key)) {
        	return dict[key];
        }else{
        	return null;
        }
	}

	function getSafeMedia(refId){
		var mediaObj = null;
		if(refId != null){
			try{
				var ref = new Media.ContentRef(refId, Media.CONTENT_TYPE_AUDIO);
				mediaObj = Media.getCachedContentObj(ref);
			}catch(ex){
				mediaObj = null;
			}
		}
		return mediaObj;
	}
}