using Toybox.Communications;

// Delegate injects a context argument into web request response callback
class RequestDelegate
{
    hidden var callback;
    hidden var context;

    function initialize(callback, context) {
        self.callback = callback;
        self.context = context;
    }

    function request(url, params, options) {
        Communications.makeWebRequest(url, params, options, self.method(:onResponse));
    }

    function onResponse(code, data) {
        callback.invoke(code, data, context);
    }
}