using Toybox.Application.Storage;
using Toybox.Media;

class StringHelper {

    function substringReplace(str, oldString, newString)
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

    function get(x){
        if(x == null){
            return "";
        } else if(x instanceof String){
            return x;
        } else if(x instanceof Method){
            return x.invoke();
        } else {
            return WatchUi.loadResource(x);
        }
    }

    function notNullOrEmpty(x){
        if(x == null){
            return false;
        }else if(x.length() == 0){
            return false;
        }else{
            for(var i=0; i<x.length(); i++){
                if(x[i] != " "){
                    return true;
                }
            }

            return false;
        }
    }
}