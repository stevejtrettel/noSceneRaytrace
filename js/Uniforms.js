import {
    Vector3,
    Vector4,
    Matrix4,
    ShaderMaterial,
    CubeTextureLoader,
    TextureLoader
} from "./module/three.module.js";

import {
    globals
} from "./Main.js";

import {
    Point,
    Vector,
    Isometry,
    serializeIsoms,
    serializePoints
} from "./Geometry.js";

import {
    Position
} from "./Position.js";




//----------------------------------------------------------------------------------------------------------------------
//	Initialise things
//----------------------------------------------------------------------------------------------------------------------

const time0 = new Date().getTime();

/**
 * Initialize the globals variables related to the scene (position, cell position, lattice, etc).
 */
function initGeometry() {

    //globals.position = new Position();
    //make it so we start looking along y axis
    globals.position = new Position();

    //translate the position back
    globals.position.translateBy(new Isometry().makeLeftTranslation(new Vector3(0., -20, 0.)));

    //rotate to face forwards
    globals.position.rotateFacingBy(new Matrix4().set(1, 0, 0, 0, 0, 0, -1, 0, 0, 1, 0, 0, 0, 0, 0, 1));
}



//----------------------------------------------------------------------------------------------------------------------
// Set up shader
//----------------------------------------------------------------------------------------------------------------------

let earthPos = new Vector3(3, 0, 0);
let earthFacing = new Matrix4();

let moonPos = new Vector3(5, 0, 0);
let moonFacing = new Matrix4();







var texture = new TextureLoader().load('images/MilkyWay.jpg');
//'images/sunset_fairway.jpg');


/**
 * Pass all the data to the shader
 * @param fShader
 */
function setupMaterial(fShader) {
    //console.log(globals.position.facing.toLog());
    globals.material = new ShaderMaterial({
        uniforms: {

            screenResolution: {
                type: "v2",
                value: globals.screenResolution
            },

            time: {
                type: "f",
                value: globals.time
            },

            earthCubeTex: { //earth texture to global object
                type: "t",
                value: new CubeTextureLoader().setPath('images/earth/')
                    .load([ //Cubemap derived from http://www.humus.name/index.php?page=Textures&start=120
                        'posx.jpg',
                        'negx.jpg',
                        'posy.jpg',
                        'negy.jpg',
                        'posz.jpg',
                        'negz.jpg'
                    ])
            },

            moonTex: {
                type: "t",
                value: new TextureLoader().load("images/2k_moon.jpg")
            },

            tex: { //earth texture to global object
                type: "t",
                value: texture
            },


            currentBoostMat: {
                type: "m4",
                value: globals.position.boost
            },
            facing: {
                type: "m4",
                value: globals.position.facing
            },


            eP: {
                type: "v3",
                value: earthPos
            },

            earthFacing: {
                type: "m4",
                value: earthFacing
            },


            mP: {
                type: "v3",
                value: moonPos
            },
            moonFacing: {
                type: "m4",
                value: moonFacing
            },



            lightRad: {
                type: "float",
                value: globals.lightRad
            },



            refl: {
                type: "float",
                value: globals.refl
            },

            rad: {
                type: "float",
                value: globals.rad
            },

            step: {
                type: "float",
                value: globals.step
            },

        },

        vertexShader: document.getElementById('vertexShader').textContent,
        fragmentShader: fShader,
        transparent: true
    });
}

/**
 * Update the data passed to the shader.
 *seems to work fine as uniforms now...
 */
function updateMaterial() {

    globals.time += 0.01;

    globals.material.uniforms.time.value = globals.time;




    //example of how this worked
    globals.material.uniforms.currentBoostMat.value = globals.position.boost;


    //rotate three times per orbit
    earthFacing = new Matrix4().makeRotationAxis(new Vector3(0.2, 1, 0), -3. * globals.time);

    moonFacing = new Matrix4().makeRotationAxis(new Vector3(0.2, 1, 0), -1. * globals.time);

    earthPos = new Vector3(3. * Math.cos(globals.time), 3. * Math.sin(globals.time), 0.);

    moonPos = (earthPos.clone()).add(new Vector3(1.5 * Math.cos(2. * globals.time), 1.5 * Math.sin(2. * globals.time), 0.))

    //make the orbit
    globals.material.uniforms.eP.value = earthPos;
    globals.material.uniforms.mP.value = moonPos;

    globals.material.uniforms.earthFacing.value = earthFacing;

    globals.material.uniforms.moonFacing.value = moonFacing;

    globals.material.uniforms.lightRad.value = globals.lightRad;
    globals.material.uniforms.refl.value = globals.refl;
    globals.material.uniforms.rad.value = globals.rad;
    globals.material.uniforms.step.value = globals.step;
}



export {
    initGeometry,
    setupMaterial,
    updateMaterial
};
