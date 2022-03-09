using Toybox.WatchUi;

class ConfirmMenuDelegate extends WatchUi.Menu2InputDelegate {

    hidden var msg;
    hidden var callback;

    function initialize(msgId, callback) {
        msg = WatchUi.loadResource(msgId);
        self.callback = callback;

        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        WatchUi.pushView(new WatchUi.Confirmation(msg), new ConfirmMenuPromptDelegate(item, callback), WatchUi.SLIDE_LEFT);
    }

    function onBack(){
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}

class ConfirmMenuPromptDelegate extends WatchUi.ConfirmationDelegate {

    hidden var context;
    hidden var callback;

    function initialize(context, callback) {
        self.context = context;
        self.callback = callback;
        ConfirmationDelegate.initialize();
    }

    function onResponse(response) {
        if(response == CONFIRM_YES){
            callback.invoke(context.getId());
        }
    }
}
