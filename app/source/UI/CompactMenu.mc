using Toybox.WatchUi;

class CompactMenu {

    hidden var items;
    hidden var title;
    hidden var menu;

    function initialize(title){
        items = [];
        self.title = title;
    }

    function build(){

    }

    function get(){
        if(menu == null){
            menu = new CompactMenuView({:title=> StringHelper.get(title)}, items);
            build();
        }
        return [menu, new CompactMenuDelegate()];
    }

    function show(){
        if(menu == null){
            menu = new CompactMenuView({:title=> StringHelper.get(title)}, items);
            build();
        }
        WatchUi.pushView(menu, new CompactMenuDelegate(), WatchUi.SLIDE_LEFT);
    }

    function add(labelBuilder, sublabelBuilder, callback){
        items.add([labelBuilder, sublabelBuilder, callback]);
    }
}

class CompactMenuView extends WatchUi.Menu2 {

    hidden var items;
    hidden var init;

    function initialize(options, items){
        self.items = items;
        Menu2.initialize(options);

    }

    function onShow() {
        for(var i=0; i<items.size(); i++){
            var item = new WatchUi.MenuItem(
                StringHelper.get(items[i][0]),
                StringHelper.get(items[i][1]),
                items[i][2],
                {});
            if(init){
                updateItem(item, i);     	
            } else {
                addItem(item);
            }
        }
        init = true;
    }
}

class CompactMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        item.getId().invoke();
    }

	function onBack(){
    	WatchUi.popView(WatchUi.SLIDE_RIGHT);    	
		return true;
	}
}