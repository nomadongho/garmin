using Toybox.Application as App;

class StarterFaceApp extends App.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        return [new StarterFaceView()];
    }
}
