using Toybox.Activity as Activity;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Graphics as Graphics;
using Toybox.System as System;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.WatchUi as WatchUi;

class StarterFaceView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Prefer the current sensor reading. A missing reading is never shown as 0 BPM.
    function getHeartRateLabel() {
        var heartRate = null;
        var activityInfo = Activity.getActivityInfo();

        if (activityInfo != null) {
            heartRate = activityInfo.currentHeartRate;
        }

        // A recent history sample is useful when a live reading is unavailable.
        if (heartRate == null && ActivityMonitor has :getHeartRateHistory) {
            var history = ActivityMonitor.getHeartRateHistory(1, true);
            if (history != null) {
                var sample = history.next();
                if (sample != null &&
                    sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
                    heartRate = sample.heartRate;
                }
            }
        }

        if (heartRate == null || heartRate <= 0 ||
            heartRate == ActivityMonitor.INVALID_HR_SAMPLE) {
            return "--";
        }

        return heartRate.format("%d");
    }

    // Watch faces are updated by the platform; don't request per-second redraws.
    function onUpdate(dc) {
        var cx = dc.getWidth() / 2;
        var clock = System.getClockTime();

        // Always use 12-hour time, regardless of the device's time format.
        var hour = clock.hour % 12;
        if (hour == 0) {
            hour = 12;
        }
        var amPm = (clock.hour >= 12) ? "PM" : "AM";
        var timeLabel = hour.format("%d") + ":" + clock.min.format("%02d");

        // The user needs the weekday, day, and month, not the year.
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
        var months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
                      "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
        var dateLabel = days[today.day_of_week - 1] + " " +
                        today.day.format("%d") + " " +
                        months[today.month - 1];

        var battery = System.getSystemStats().battery.toNumber();
        var batteryLabel = "BAT " + battery.format("%d") + "%";
        var heartRateLabel = "HR " + getHeartRateLabel();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Built-in number fonts have generous empty space above their glyphs.
        // An opaque text background would erase the lower half of the date
        // when the clock is drawn afterward. Keep glyph backgrounds transparent.
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // Compact 208 x 208 round layout. The date sits just above the
        // visible digits, without being masked by the number font's line box.
        dc.drawText(cx, 49, Graphics.FONT_SMALL, dateLabel,
                    Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(cx, 58, Graphics.FONT_NUMBER_HOT, timeLabel,
                    Graphics.TEXT_JUSTIFY_CENTER);

        // Align AM/PM to the right edge of the actual time (8:31 / 12:59),
        // close to the number baseline but clear of the bottom readouts.
        var timeRight = cx +
                        dc.getTextWidthInPixels(timeLabel, Graphics.FONT_NUMBER_HOT) / 2;
        dc.drawText(timeRight, 130, Graphics.FONT_XTINY, amPm,
                    Graphics.TEXT_JUSTIFY_RIGHT);

        // At the bottom of a round screen, usable width narrows quickly.
        // Move the readouts up and anchor their outer edges inside the circle.
        dc.drawText(31, 155, Graphics.FONT_XTINY, batteryLabel,
                    Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(dc.getWidth() - 31, 155, Graphics.FONT_XTINY, heartRateLabel,
                    Graphics.TEXT_JUSTIFY_RIGHT);
    }
}
