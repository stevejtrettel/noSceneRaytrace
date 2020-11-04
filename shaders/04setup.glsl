//----------------------------------------------------------------------------------------------------------------------
// PARAMETERS
//----------------------------------------------------------------------------------------------------------------------
float test;
vec2 test2;
vec3 test3;
vec4 test4;
/*

Some parameters that can be changed to change the scence
*/

//----------------------------------------------------------------------------------------------------------------------
// "TRUE" CONSTANTS
//----------------------------------------------------------------------------------------------------------------------

const float PI = 3.1415926538;
const float sqrt3 = 1.7320508075688772;
const float sqrt2 = 1.4142135623730951;


//----------------------------------------------------------------------------------------------------------------------
// Global Constants
//----------------------------------------------------------------------------------------------------------------------
float MAX_DIST = 30.0;

void setResolution(int UIVar){
//use this to reset MAX MARCHING, etc...
}

const float EPSILON = 0.0001;
const float fov = 90.0;



//----------------------------------------------------------------------------------------------------------------------
// Global Variables
//----------------------------------------------------------------------------------------------------------------------

int inWhich=0;
int hitWhich = 0;
bool eventHorizon=false;

//set by raymarch
Vector sampletv;
float distToViewer;

vec3 pSphColor;



//----------------------------------------------------------------------------------------------------------------------
// Translation & Utility Variables
//----------------------------------------------------------------------------------------------------------------------
uniform vec2 screenResolution;

uniform mat4 currentBoostMat;
uniform mat4 facing;

Isometry currentBoost;




//----------------------------------------------------------------------------------------------------------------------
// Lighting Variables & Global Object Variables
//----------------------------------------------------------------------------------------------------------------------

uniform samplerCube earthCubeTex;
uniform sampler2D tex;


uniform float time;

uniform float lightRad;
uniform float refl;

uniform float rad;
uniform float step;



//----------------------------------------------------------------------------------------------------------------------
// Re-packaging Isometries and Positions
//----------------------------------------------------------------------------------------------------------------------


void setVariables(){
    
    currentBoost = Isometry(currentBoostMat);

    
}
    
    















//----------------------------------------------------------------------------------------------------------------------
// Post-Processing Color Functions
//----------------------------------------------------------------------------------------------------------------------




vec3 LessThan(vec3 f, float value)
{
    return vec3(
        (f.x < value) ? 1.0f : 0.0f,
        (f.y < value) ? 1.0f : 0.0f,
        (f.z < value) ? 1.0f : 0.0f);
}
 
vec3 LinearToSRGB(vec3 rgb)
{
    rgb = clamp(rgb, 0.0f, 1.0f);
     
    return mix(
        pow(rgb, vec3(1.0f / 2.4f)) * 1.055f - 0.055f,
        rgb * 12.92f,
        LessThan(rgb, 0.0031308f)
    );
}
 
vec3 SRGBToLinear(vec3 rgb)
{
    rgb = clamp(rgb, 0.0f, 1.0f);
     
    return mix(
        pow(((rgb + 0.055f) / 1.055f), vec3(2.4f)),
        rgb / 12.92f,
        LessThan(rgb, 0.04045f)
    );
}



//TONE MAPPING
//takes linear color -> linear color
//call in post processing before conversion to sRGB, gamma
// ACES tone mapping curve fit to go from HDR to LDR
//https://knarkowicz.wordpress.com/2016/01/06/aces-filmic-tone-mapping-curve/
vec3 ACESFilm(vec3 x)
{
    float a = 2.51f;
    float b = 0.03f;
    float c = 2.43f;
    float d = 0.59f;
    float e = 0.14f;
    return clamp((x*(a*x + b)) / (x*(c*x + d) + e), 0.0f, 1.0f);
}


