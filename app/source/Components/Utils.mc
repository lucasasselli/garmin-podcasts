using Toybox.Application.Storage;

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
}