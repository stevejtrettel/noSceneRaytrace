

//----------------------------------------------------------------------------------------------------------------------
// Coloring functions
//----------------------------------------------------------------------------------------------------------------------

vec3 checkerboard(vec2 v){
    float x=mod(10.*v.x/6.28,2.);
    float y=mod(10.*v.y/3.14,2.);
    
    if(x<1.&&y<1.||x>1.&&y>1.){
        return vec3(0.0);
    }
    else return vec3(0.005);
}




vec2 toSphCoords(vec4 v){
float theta=atan(v.y,v.x);
float phi=acos(v.z);
return vec2(theta,phi);
}




//
vec3 cubeTexture(Vector tv){
    // vec3 color = vec3(0.5,0.5,0.5);
    vec3 color = texture(earthCubeTex, tv.dir.yzx).rgb;
return color;
}


vec3 skyTex(Vector tv){

vec2 angles=toSphCoords(tv.dir);
float x=(angles.x+3.1415)/(2.*3.1415);
float y=1.-angles.y/3.1415;

return SRGBToLinear(texture(tex,vec2(x,y)).rgb);

}





//colors unit sphere at origin with grid
vec3 sphereGrid(Vector tv){

vec2 p=toSphCoords(tv.pos.coords);
vec3 color=checkerboard(p);

return color;

}
