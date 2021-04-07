using Toybox.Application.Storage;

class StorageHelper {

    function get(key, default_value){
           var x = Storage.getValue(key);
        if(x == null) {
            return default_value;
        }else{
            return x;
        }
    }
}