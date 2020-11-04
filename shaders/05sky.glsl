

//----------------------------------------------------------------------------------------------------------------------
// Coloring functions
//----------------------------------------------------------------------------------------------------------------------

vec3 checkerboard(vec2 v){
    float x=mod(10.*v.x/6.28,2.);
    float y=mod(10.*v.y/3.14,2.);
    
    if(x<1.&&y<1.||x>1.&&y>1.){
        return vec3(0.1);
    }
    else return vec3(0.0);
}



vec3 gridLines(vec2 v,vec3 color){
    //use refl to control grid spacing
float numGrids=refl+4.;
    
    float x=mod(numGrids*v.x/6.28,2.);
    float y=mod(numGrids*v.y/3.14,2.);
    
    //lightRad controls grid brightness
    float mag=clamp(1./(50.*x*(2.-x)*y*(2.-y)),0.,20.);
    return mag*color;
//    
}




vec2 toSphCoords(vec4 v){

//normalize the thing:
 vec3 p=normalize(v.xyz);
    
float theta=atan(p.y,p.x);
float phi=acos(p.z);
return vec2(theta,phi);
}


vec3 toSphCoordsNoSeam(vec4 v){
    
    float theta=atan(v.y,v.x);
    float theta2=atan(v.y,abs(v.x));
    float phi=acos(v.z);
return vec3(theta,phi,theta2);
}


//
vec3 cubeTexture(Vector tv){
    // vec3 color = vec3(0.5,0.5,0.5);
    vec3 color = texture(earthCubeTex, tv.dir.yzx).rgb;
return color;
}


vec3 skyTex(Vector tv){

vec3 angles=toSphCoordsNoSeam(tv.dir);
    
//theta coordinates (x=real, y=to trick the derivative so there's no seam)
float x=(angles.x+3.1415)/(2.*3.1415);
float z=(angles.z+3.1415)/(2.*3.1415);
    
float y=1.-angles.y/3.1415;

vec2 uv=vec2(x,y);
  vec2 uv2=vec2(z,y);//grab the other arctan piece;
    
return SRGBToLinear(textureGrad(tex,uv,dFdx(uv2), dFdy(uv2)).rgb);

}



vec3 diskTex(Vector tv){
    
    //get polar coordinates:
    float r=length(tv.pos.coords.xy);
    float x=tv.pos.coords.x;
    float y=tv.pos.coords.y;
    float theta=atan(y,x);
    
    
    x=mod(10.*r/6.28,2.);
   y=mod(10.*theta/3.14,2.);
    vec3 color=vec3(0./255.,92./255.,220./255.);
     //lightRad controls grid brightness
    float mag=clamp(1./(50.*x*(2.-x)*y*(2.-y)),0.,20.);
    return mag*color;
    
//    
//    if(x<1.&&y<1.||x>1.&&y>1.){
//        return vec3(0.1);
//    }
//    else return vec3(0.0);
//    
}

//
//
////colors unit sphere at origin with grid
//vec3 sphereGrid(Vector tv,vec3 color){
//
//vec2 p=toSphCoords(tv.pos.coords);
//vec3 color=gridLines(p,color);
//return color;
//
//}






//colors unit sphere at origin with grid
vec3 EHGrid(Vector tv){
        //use lightRad to control brightness
    float brightness=lightRad;

vec2 p=toSphCoords(tv.pos.coords);
vec3 color=vec3(166./255.,24./255.,2./255.);
vec3 gridColor=gridLines(p,brightness*color);
return gridColor;

}






//colors unit sphere at origin with grid
vec3 PSphGrid(Vector tv){

vec2 p=toSphCoords(tv.pos.coords);
vec3 color=vec3(0./255.,92./255.,220./255.);
vec3 gridColor=gridLines(p,color);
return gridColor;
}