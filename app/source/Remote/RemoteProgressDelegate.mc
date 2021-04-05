using Toybox.WatchUi;
using Toybox.Communications;

class RemoteProgressDelegate extends WatchUi.BehaviorDelegate
{
	function initialize() {
		BehaviorDelegate.initialize();
	}
	
	function onBack() {
		Communications.cancelAllRequests();
		return false;
	}
}