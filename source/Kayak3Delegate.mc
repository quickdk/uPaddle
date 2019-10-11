using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application as App;
using Toybox.Attention as Attention;

var pageNum = 0;
var pageChange = false;
var lastLapTime = 0;
var totalLastLapTime = 0;
var numOfLaps = 0;
var lastLapDist = 0;
var totalLastLapDist = 0;

var currentTimeStopped = 0;
var currentDistStopped = 0;
var totalTimeStopped = 0;
var totalDistStopped = 0;

var vibrateDataStart = [
	new Attention.VibeProfile( 100, 80 ),
	new Attention.VibeProfile( 0, 40 ),
	new Attention.VibeProfile( 100, 80 )
];
var vibrateDataStop = [
	new Attention.VibeProfile( 100, 200 )
];
var vibrateDataLap = [
	new Attention.VibeProfile( 100, 100 )
];

//var object = new Kayak3DataRetreival();

class Kayak3Delegate extends Ui.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }
    
    function onBack() {
    	if( ( session != null ) && session.isRecording()) {
    		//If the back button has been pressed and the session is running
    		//add a lap to the session.
    		addLap();
    	}
    	if( ( session == null ) || ( session.isRecording() == false ) ) {
    		//If the back button has been pressed and the session is stopped
    		//show push the menu to let the user save or discard the recorded session.
        	Ui.pushView( new Rez.Menus.MainMenu(), new MenuDelegate(), Ui.SLIDE_UP );
        }
        return true;
    }
    
    function onKey(press) {
    	var info_settings = Sys.getDeviceSettings();
        if( Toybox has :ActivityRecording && (press.getKey() == KEY_ENTER || press.getKey() == KEY_START)) {
            if( ( session == null ) || ( session.isRecording() == false ) ) {
            	//If the start button has been pressed and the session is not 
            	//recording, start the session and notify the user by a vibration
            	//and or sound.
                session.start();
                Attention.vibrate( vibrateDataStart );
                if (Toybox has :tonesOn) {
                	Attention.playTone(TONE_START);
                }
                Ui.requestUpdate();
                return true;
            }
            else if( ( session != null ) && session.isRecording()) {
            	//If the start button has been pressed and the session is 
            	//recording, stop the session and notify the user by a vibration
            	//and or sound.
                session.stop();
                Attention.vibrate( vibrateDataStop );
                if (Toybox has :tonesOn) {
                	Attention.playTone(TONE_STOP);
                }
                Ui.requestUpdate();
                return true;
            }
        }
    }
    
    function onNextPage() {
    	//If the next page button is pressed, increment the page counter.
    	pageNum++;
    	if (pageNum > MAX_PAGE_NUM) {
    		//Iff the page counter value is above the maximum number of pages,
    		//reset the counter to page 0.
    		pageNum = 0;
    	}
    	var string = "ToggleDisplay" + (pageNum+1).toString();
    	System.print(string);
    	System.println(!App.getApp().getProperty(string));
    	//See if the chosen page has been actived for use in the properties.
    	while (!App.getApp().getProperty(string)) {
    		//Increment the page conuter, if the page has not been set to use.
    		pageNum++;
    		if (pageNum > MAX_PAGE_NUM) {
    			pageNum = 0;
    		}
    		string = "ToggleDisplay" + (pageNum+1).toString();
    	}
    	//Set the pageChange flag to true and update.
    	pageChange = true;
    	Ui.requestUpdate();
    	return true;
    }
    
    function onPreviousPage() {
    	//If the previous page button is pressed, decrease the page counter.
    	pageNum--;
    	if (pageNum < 0) {
    		//Iff the page counter value is below the minimum number of pages,
    		//reset the counter to the top page.
    		pageNum = MAX_PAGE_NUM;
    	}
    	var string = "ToggleDisplay" + (pageNum+1).toString();
    	//See if the chosen page has been actived for use in the properties.
    	while (!App.getApp().getProperty(string)) {
    		//Decrease the page conuter, if the page has not been set to use.
    		pageNum--;
    		if (pageNum < 0) {
    			pageNum = MAX_PAGE_NUM;
    		}
    		string = "ToggleDisplay" + (pageNum+1).toString();
    	}
    	//Set the pageChange flag to true and update.
    	pageChange = true;
    	Ui.requestUpdate();
    	return true;
    }
    
    function addLap() {
    	if( ( session != null ) && session.isRecording()) {
            session.addLap();
            var info_activity = Activity.getActivityInfo();
    		if( info_activity has :elapsedTime && info_activity.elapsedTime != null )
	        {
	        	if (numOfLaps == 0) {
	        		lastLapTime = time;
	        		totalLastLapTime = totalLastLapTime + lastLapTime;
	        	}
	        	else {
	        		lastLapTime = time - totalLastLapTime;
	        		totalLastLapTime = totalLastLapTime + lastLapTime;
	        	}
	        }
	        if( info_activity has :elapsedDistance && info_activity.elapsedDistance != null )
	        {
	        	if (numOfLaps == 0) {
	        		lastLapDist = dist/1000;
	        		totalLastLapDist = totalLastLapDist + lastLapDist;
	        	}
	        	else {
	        		lastLapDist = dist/1000 - totalLastLapDist;
	        		totalLastLapDist = totalLastLapDist + lastLapDist;
	        	}
	        }
	        numOfLaps++;
            Attention.vibrate( vibrateDataLap );
            if (Toybox has :tonesOn) {
            	Attention.playTone(TONE_LAP);
            }
            Ui.requestUpdate();
        }
        return true;
    }

}

class MenuDelegate extends Ui.MenuInputDelegate {
	function initialize() {
		MenuInputDelegate.initialize();
	}
	
    function onMenuItem(item) {
        if ( item == :item_resume ) {
            Ui.requestUpdate();
        }
        else if ( item == :item_save ) {
            session.stop();
            session.save();
            System.exit();
        }
        else if ( item == :item_discard ) {
        	Ui.pushView( new Rez.Menus.ConfMenu(), new MenuDelegate(), Ui.SLIDE_UP );
        }
        else if ( item == :item_cancel ) {
        	Ui.requestUpdate();
        }
        else if ( item == :item_confirm ) {
        	session.stop();
            session.discard();
            System.exit();
        }
    }
}