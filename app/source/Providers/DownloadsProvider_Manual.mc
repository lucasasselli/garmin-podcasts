using Toybox.Communications;
using Toybox.Application.Storage;

class DownloadsProvider_Manual {

    private var downloads;

    function initialize(){
        self.downloads = StorageHelper.get(Constants.STORAGE_DOWNLOADS, []);
    }

    function valid(){
        return (downloads.size() != 0);
    }

    function get(doneCallback, errorCallback){
        doneCallback.invoke(downloads);
        return false;
    }

}