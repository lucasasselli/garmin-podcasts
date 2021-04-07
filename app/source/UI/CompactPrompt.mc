using Toybox.WatchUi;

// TODO: Replace compact prompt in code
class CompactPrompt {

    hidden var yesCallback;
    hidden var noCallback;
    hidden var msg;

    function initialize(msg, yesCallback, noCallback){
        self.msg = msg;
        self.yesCallback = yesCallback;
        self.noCallback = noCallback;
    }

    function show(){
        WatchUi.pushView(new WatchUi.Confirmation(StringHelper.get(msg)), new CompactPromptDelegate(yesCallback, noCallback), WatchUi.SLIDE_LEFT);
    }
}
class CompactPromptDelegate extends WatchUi.ConfirmationDelegate {

    hidden var yesCallback;
    hidden var noCallback;

    function initialize(yesCallback, noCallback) {
        self.yesCallback = yesCallback;
        self.noCallback = noCallback;
        ConfirmationDelegate.initialize();
    }

    function onResponse(response) {
        if(response == CONFIRM_YES){
            if(yesCallback != null){
                yesCallback.invoke();
            }else{
                WatchUi.popView(WatchUi.SLIDE_RIGHT);
            }
        }else{
            if(noCallback != null){
                noCallback.invoke();
            }else{
                WatchUi.popView(WatchUi.SLIDE_RIGHT);
            }
        }
    }
}