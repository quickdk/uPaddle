using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Position as Position;
using Toybox.Sensor as Sensor;
using Toybox.ActivityRecording as Record;

var session;

class Kayak3App extends App.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    //! onStart() is called on application start up
    function onStart(state) {
    	Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    	var activityType = App.getApp().getProperty("ActivityType");
    	if (activityType == 1) {
    		session = Record.createSession({:name=>"Kayak", :sport=>Record.SPORT_PADDLING});
    	}
    	else if (activityType == 2) {
    		session = Record.createSession({:name=>"Stand up paddle", :sport=>Record.SPORT_PADDLING});
    	}
    	else if (activityType == 3) {
    		session = Record.createSession({:name=>"Rafting", :sport=>Record.SPORT_PADDLING});
    	}
    	Sensor.setEnabledSensors( [Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_BIKECADENCE] );
        Sensor.enableSensorEvents( method(:onSensor) );
    }

    //! onStop() is called when your application is exiting
    function onStop(state) {
    	Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }
    
    //Are the following two functions to be used???
    function onPosition(info) {
    }
    
    function onSensor(info_snsr) {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [ new Kayak3View(), new Kayak3Delegate() ];
    }
    
    //! If the settings have changed, update the layout
    function onSettingsChanged() {
        Ui.requestUpdate();
    }

}


