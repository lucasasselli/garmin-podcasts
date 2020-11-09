class Iterator {

    hidden var i = -1;
    hidden var object = 0;

    hidden var actionCallback;
    hidden var doneCallback;

    function initialize(object, actionCallback, doneCallback){
        self.object = object;
        self.actionCallback = actionCallback;
        self.doneCallback = doneCallback;
    }

    function index(){
        return i;
    }

    function item(){
        return object[i];
    }

    function size(){
        return object.size();
    }

    function next(){
        i++;
        if(i >= object.size()){
            doneCallback.invoke();
        }else{
            actionCallback.invoke(object[i]);
        }
    }
}