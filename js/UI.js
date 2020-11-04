import {
    globals
} from './Main.js';

//-------------------------------------------------------
// UI Variables
//-------------------------------------------------------

let guiInfo;
let capturer;


//What we need to init our dat GUI
let initGui = function () {
    guiInfo = { //Since dat gui can only modify object values we store variables here.
        toggleUI: true,
        lightRad: 0.,
        refl: 10,
        rad: 1,
        step: 1,
        recording: false
    };

    let gui = new dat.GUI();
    gui.close();


    //using to control sphere size
    let lightRadController = gui.add(guiInfo, 'lightRad', 0.0, 1.).name("EH Grid Brightness");


    //    //using to control size of the change in index of refraction
    let reflController = gui.add(guiInfo, 'refl', 0., 20., 1.).name("Grid Spacing");

    let radController = gui.add(guiInfo, 'rad', 1., 3., 0.01).name("Sphere Radius");

    let stepController = gui.add(guiInfo, 'step', 0.01, 2., 0.01).name("StepSize");



    let recordingController = gui.add(guiInfo, 'recording').name("Record video");

    lightRadController.onChange(function (value) {
        globals.lightRad = value;
    });

    reflController.onChange(function (value) {
        globals.refl = value;
    });

    radController.onChange(function (value) {
        globals.rad = value;
    });

    stepController.onChange(function (value) {
        globals.step = value;
    });
    //

    recordingController.onFinishChange(function (value) {
        if (value == true) {
            guiInfo.recording = true;
            capturer = new CCapture({
                format: 'jpg'
            });
            capturer.start();
        } else {
            guiInfo.recording = false;
            capturer.stop();
            capturer.save();
            // onResize(); //Resets us back to window size
        }
    });



};

export {
    initGui,
    guiInfo,
    capturer
}
