using Toybox.System;
using Toybox.Application;

(:debug)
module Log {
    function debug(string) {
        System.println(string);
    }
}

(:release)
module Log {
    function debug(string) {}
}