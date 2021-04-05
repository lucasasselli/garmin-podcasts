using Toybox.Media;

// BUG: WERETECH-10485 Garmin Device starts Sync while in
// charge and hangs. :-( 
// This only happens with Communication.SyncDelegate, not 
// Media.SyncDelegate
class SyncDummy extends Media.SyncDelegate {

    function initialize() {
        SyncDelegate.initialize();
    }
    
    function onStartSync() {
        Media.notifySyncComplete(null);
    }

    function isSyncNeeded() {
        return false;
    }

    function onStopSync() {
        Media.notifySyncComplete(null);
    }
}