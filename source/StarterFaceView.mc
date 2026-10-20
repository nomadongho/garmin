using Toybox.Graphics as Graphics;
using Toybox.System as System;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.WatchUi as WatchUi;

class StarterFaceView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Let the platform choose the update cadence. No per-second redraws.
    function onUpdate(dc) {
        var cx = dc.getWidth() / 2;
        var clock = System.getClockTime();
        var is24Hour = System.getDeviceSettings().is24Hour;
        var hour = clock.hour;
        var suffix = "";

        if (!is24Hour) {
            suffix = (hour >= 12) ? "PM" : "AM";
            hour = hour % 12;
            if (hour == 0) {
                hour = 12;
            }
        }

        var timeLabel = hour.format("%02d") + ":" + clock.min.format("%02d");
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
        var dayLabel = days[today.day_of_week - 1];
        var dateLabel = dayLabel + " " + today.day.format("%02d")
                              + "/" + today.month.format("%02d");
        var battery = System.getSystemStats().battery.toNumber();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

        // Coordinates are tuned for the 208 x 208 round screen.
        dc.drawText(cx, 32, Graphics.FONT_SMALL, "GARMIN STARTER",
                    Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(cx, 64, Graphics.FONT_NUMBER_HOT, timeLabel,
                    Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(cx, 140, Graphics.FONT_SMALL, dateLabel,
                    Graphics.TEXT_JUSTIFY_CENTER);
        if (!is24Hour) {
            dc.drawText(cx, 161, Graphics.FONT_XTINY, suffix,
                        Graphics.TEXT_JUSTIFY_CENTER);
        }
        dc.drawText(cx, 180, Graphics.FONT_XTINY,
                    "BAT " + battery.format("%d") + "%",
                    Graphics.TEXT_JUSTIFY_CENTER);
    }
}
