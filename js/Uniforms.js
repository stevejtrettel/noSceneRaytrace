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
    globals.position.translateBy(new Isometry().makeLeftTranslation(new Vector3(0., -10, 0.)));

    //rotate to face forwards
    globals.position.rotateFacingBy(new Matrix4().set(1, 0, 0, 0, 0, 0, -1, 0, 0, 1, 0, 0, 0, 0, 0, 1));
}



//----------------------------------------------------------------------------------------------------------------------
// Set up shader
//----------------------------------------------------------------------------------------------------------------------

var texture = new TextureLoader().load('images/sunset_fairway.jpg');


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
                value: (new Date().getTime()) - time0
            },

            earthCubeTex: { //earth texture to global object
                type: "t",
                value: new CubeTextureLoader().setPath('images/SkyCube/')
                    .load([ //Cubemap derived from http://www.humus.name/index.php?page=Textures&start=120
                        'posx.jpg',
                        'negx.jpg',
                        'posy.jpg',
                        'negy.jpg',
                        'posz.jpg',
                        'negz.jpg'
                    ])
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

            lightRad: {
                type: "float",
                value: globals.lightRad
            },



            refl: {
                type: "float",
                value: globals.refl
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
    //example of how this worked
    globals.material.uniforms.currentBoostMat.value = globals.position.boost;

    globals.material.uniforms.lightRad.value = globals.lightRad;
    globals.material.uniforms.refl.value = globals.refl;

}



export {
    initGeometry,
    setupMaterial,
    updateMaterial
};
