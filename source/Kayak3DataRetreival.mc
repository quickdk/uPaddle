//using Toybox.WatchUi as Ui;
//using Toybox.System as Sys;
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.Attention as Attention;

var time = 0;
var stoppedTime = 0;
var dist = 0;
var stoppedDist = 0;
//numOfLaps in delegate file


var pi1_8 = Math.PI * (1.0/8);
var pi3_8 = Math.PI * (3.0/8);
var pi5_8 = Math.PI * (5.0/8);
var pi7_8 = Math.PI * (7.0/8);

class Kayak3DataRetreival {    
	var value = "0";
	var label = "lbl";
	var gpsstatus = 0;
	
	function getGPSStatus() {
		var info_pos = Position.getInfo();
		if ( info_pos has :accuracy && info_pos.accuracy != null )
        {
        	gpsstatus = info_pos.accuracy;
        }
	}
		
    function getDataFieldValues(dataField_prop) {
    
    	//Should probably find another place for the following part of the function
    	//-------------------------------------------------------------------
    	//Saves time and dist when activity is running
		//Also checks for auto-lap
		var info_activity = Activity.getActivityInfo();
	    if( info_activity has :elapsedTime && info_activity.elapsedTime != null )
		{
		    if ( session.isRecording() == false ) {
				stoppedTime = info_activity.elapsedTime - time;
				if( info_activity has :elapsedDistance && info_activity.elapsedDistance != null ) {
					stoppedDist = info_activity.elapsedDistance - dist;
				}
			}
			else {
				time = info_activity.elapsedTime - stoppedTime;
				if( info_activity has :elapsedDistance && info_activity.elapsedDistance != null ) {
					dist = info_activity.elapsedDistance - stoppedDist;
				}
			}
		}
		if ( App.getApp().getProperty("ToggleAutoLap") == true ) {
			if ( dist >= App.getApp().getProperty("AutoLapDist") * (numOfLaps + 1) ) {
				//session.addLap();
				//numOfLaps = numOfLaps+1;
				//Attention.vibrate( vibrateDataLap );
            	//if (Toybox has :tonesOn) {
            	//	Attention.playTone(TONE_LAP);
            	//}
            	addLap();
			}
		}
		//------------------------------------------------------------------
    
    	if (dataField_prop == 1) {
    		var info_activity = Activity.getActivityInfo();
    		value = "--:--:--";
    		System.print("info_activity: ");
    		System.println(info_activity.elapsedTime);
    		if( info_activity has :elapsedTime && info_activity.elapsedTime != null )
	        {
	        	value = convertTime(time);
	        }
	    	label = Ui.loadResource(Rez.Strings.ElapsedTimeLabel);

    	}
    	
    	else if (dataField_prop == 2) {
	    	var info_clock = Sys.getClockTime();
	    	value = "--:--:--";
	    	if ( info_clock has :hour && info_clock has :min && info_clock has :sec) {
	        	value = info_clock.hour.format("%d").toString() + ":" + info_clock.min.format("%02d").toString() + ":" + info_clock.sec.format("%02d").toString();
	    	}
	    	label = Ui.loadResource(Rez.Strings.TimeofDayLabel);
	    }
	    
	    else if (dataField_prop == 3) {
	    	var info_activity = Activity.getActivityInfo();
    		value = "--:--:--";
    		if( info_activity has :elapsedTime && info_activity.elapsedTime != null )
	        {
	        	var lapTime = time - totalLastLapTime;
	        	value = convertTime(lapTime);
	        }
	    	label = Ui.loadResource(Rez.Strings.CurrentLapTimeLabel);
	    }
	    else if (dataField_prop == 4) {
	    	value = "--:--:--";
	    	if (lastLapTime != 0) {
	    		value = convertTime(lastLapTime);
	    	}
	    	label = Ui.loadResource(Rez.Strings.LastLapTimeLabel);
	    }
	    else if (dataField_prop == 5) {
		    var info_activity = Activity.getActivityInfo();
		    value = "0";
	    	if( info_activity has :elapsedDistance && info_activity.elapsedDistance != null )
	        {
	        	value = dist/1000;
	        	value = value.format("%0.2f");
	        	value = value.toString();
	        }
	    	label = Ui.loadResource(Rez.Strings.DistanceLabel);
	    }
	    else if (dataField_prop == 6) {
	    	var info_activity = Activity.getActivityInfo();
		    value = "0";
	    	if( info_activity has :elapsedDistance && info_activity.elapsedDistance != null )
	        {
	        	var lapDist = dist/1000;
	        	lapDist = lapDist - totalLastLapDist;
	        	lapDist = lapDist.format("%0.2f");
	        	value = lapDist.toString();
	        }
	    	label = Ui.loadResource(Rez.Strings.CurrentLapDistanceLabel);
	    }
	    else if (dataField_prop == 7) {
	    	value = lastLapDist.format("%0.2f").toString();
	    	label = Ui.loadResource(Rez.Strings.LastLapDistanceLabel);
	    }
	    else if (dataField_prop == 8) {
	    	var info_sens = Sensor.getInfo();
	    	value = "0";
	    	if( info_sens has :speed && info_sens.speed != null )
	        {
	        	value = info_sens.speed;
	        	value = value*3.6;
	        	value = value.format("%0.1f");
	        	value = value.toString();
	        }
	    	label = Ui.loadResource(Rez.Strings.SpeedLabel);
	    }
	    else if (dataField_prop == 9) {
	    	var info_activity = Activity.getActivityInfo();
		    value = "0";
	    	if( info_activity has :averageSpeed && info_activity.averageSpeed != null )
	        {
	        	value = info_activity.averageSpeed;
	        	value = value*3.6;
	        	value = value.format("%0.1f");
	        	value = value.toString();
	        }
	    	label = Ui.loadResource(Rez.Strings.AverageSpeedLabel);
	    }
	    else if (dataField_prop == 10) {
	    	var info_sensor = Sensor.getInfo();
	    	value = "0";
	    	if ( info_sensor has :cadence && info_sensor.cadence != null && info_sensor.cadence != 0 &&
	    	info_sensor has :speed && info_sensor.speed != null )
	        {
	        	value = info_sensor.speed * 60 / (info_sensor.cadence / 2); //!Kayaking cadence is measured double
	        	value = value.format("%0.1f");
	        	value = value.toString();
	        }
	    	label = Ui.loadResource(Rez.Strings.MeterperStrokeLabel);
	    }
	    else if (dataField_prop == 11) {
	    	var info_activity = Activity.getActivityInfo();
	    	value = "0";
	    	if ( info_activity has :averageCadence && info_activity.averageCadence != 0 && info_activity.averageCadence != null &&
	    	info_activity has :elapsedDistance && info_activity.elapsedDistance != null )
	        {
	        	value = info_activity.elapsedDistance / (info_activity.averageCadence / 2); //!Kayaking cadence is measured double
	        	value = value.format("%0.1f");
	        	value = value.toString();
	        }
	    	label = Ui.loadResource(Rez.Strings.AverageMeterperStrokeLabel);
	    }
	    else if (dataField_prop == 12) {
	    	var info_sens = Sensor.getInfo();
	    	value = "0";
	    	if( info_sens has :cadence && info_sens.cadence != null )
	        {
	        	value = info_sens.cadence / 2; //!Kayaking cadence is measured double
	        	value = value.toString();
	        }
	    	
	    	label = Ui.loadResource(Rez.Strings.StrokeCadenceLabel);
	    }
	    else if (dataField_prop == 13) {
	    	var info_activity = Activity.getActivityInfo();
	    	value = "0";
	    	if ( info_activity has :averageCadence && info_activity.averageCadence != null )
	        {
	        	value = info_activity.averageCadence / 2; //!Kayaking cadence is measured double
	        	value = value.toString();
	        }
	    	label = Ui.loadResource(Rez.Strings.AverageSrokeCadenceLabel);
	    }
	    else if (dataField_prop == 14) {
	    	var info_sens = Sensor.getInfo();
	    	value = "0";
	    	if( info_sens has :heartRate && info_sens.heartRate != null )
	        {
	        	value = info_sens.heartRate; //!Kayaking cadence is measured double
	        	value = value.toString();
	        }
	    	
	    	label = Ui.loadResource(Rez.Strings.HeartRateLabel);
	    }
	    else if (dataField_prop == 15) {
	    	var info_activity = Activity.getActivityInfo();
	    	value = "0";
	    	if ( info_activity has :averageHeartRate && info_activity.averageHeartRate != null )
	        {
	        	value = info_activity.averageHeartRate; //!Kayaking cadence is measured double
	        	value = value.toString();
	        }
	    	label = Ui.loadResource(Rez.Strings.AverageHeartRateLabel);
	    }
	    
	    else if (dataField_prop == 16) {
	    	var info_sens = Sensor.getInfo();
	    	value = "--";
	    	if( info_sens has :heading && info_sens.heading != null )
	        {
	        	value = info_sens.heading;
	        	value = Math.toDegrees(value);
	        	if (value < 0) {
	        		value = 360+value;
	        	}
	        	//value.format("%02d").toString();
	        	value = value.format("%.0f").toString();
	        	System.println(value);
	        }
	    	
	    	label = Ui.loadResource(Rez.Strings.HeadingLabel);
	    }
	    
	    else if (dataField_prop == 17) {
	    	var info_sens = Sensor.getInfo();
	    	value = "0";
	    	if( info_sens has :speed && info_sens.speed != null )
	        {
	        	value = info_sens.speed;
	        	value = 1/(value*0.06);
	        	value = value.format("%0.1f");
	        	value = value.toString();
	        }
	    	label = Ui.loadResource(Rez.Strings.PaceLabel);
	    }
    }
    
	function addLap() { //This function should not be here
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
    }
    
    function convertTime(time) {
    	var sec;
		var min;
		var hour;
		var time_string;
		sec = time / 1000;
        min = sec / 60;
        hour = min / 60;
            
        min -= hour * 60;
        sec -= min * 60 + hour * 3600;
        
		time_string = hour.format("%d").toString() + ":" + min.format("%02d").toString() + ":" + sec.format("%02d").toString();
		return time_string;
    } 
}