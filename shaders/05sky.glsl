

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



vec4 rotXY(vec4 v, float t){
    float x=v.x*cos(t)-v.y*sin(t);
    float y=v.x*sin(t)+v.y*cos(t);
    
    return vec4(x,y,v.z,v.w);
}

vec3 toSphCoordsNoSeam(vec4 v){
    
    //rotate the background sky slowly
    v=rotXY(v,time/20.);
    
    float theta=atan(v.y,v.x);
    float theta2=atan(v.y,abs(v.x));
    float phi=acos(v.z);
return vec3(theta,phi,theta2);
}






vec3 skyTex(Vector tv){

vec3 angles=toSphCoordsNoSeam(tv.dir);
    

//theta coordinates (x=real, z=to trick the derivative so there's no seam)
float x=(angles.x+3.1415)/(2.*3.1415);
float z=(angles.z+3.1415)/(2.*3.1415);
    
float y=1.-angles.y/3.1415;

vec2 uv=vec2(x,y);
  vec2 uv2=vec2(z,y);//grab the other arctan piece;
    
return SRGBToLinear(textureGrad(tex,uv,dFdx(uv2), dFdy(uv2)).rgb);

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













//--------------------------------------------------------------------
// FOR THE EARTH
//--------------------------------------------------------------------


//
vec3 earthTexture(Vector tv){
    
    vec3 dir=tv.pos.coords.xyz-earthPos;
    dir=normalize(dir);
    dir=(earthFacing*vec4(dir.yzx,0)).xyz;

    vec3 color = texture(earthCubeTex, dir).rgb;
return color;
}





vec3 earthLight(Vector tv, vec3 lP){
    
    Point lightPos=Point(vec4(lP,1.));
    
    //get earth color:
    vec3 dir=tv.pos.coords.xyz-earthPos;
    dir=normalize(dir);
    vec3 rotDir=(earthFacing*vec4(dir.yzx,0)).xyz;
    


    //color of the sphere
    vec3 baseColor = texture(earthCubeTex, rotDir).rgb;
    
    //vectors for phong model:
    Vector V =turnAround(tv);
    //normal vector to sphere is just the direction vector from its center
    Vector N=Vector(tv.pos,vec4(dir, 0.));
    
    Vector L = tangDirection(tv.pos, lightPos);
    Vector R = sub(scalarMult(2.0 * cosAng(L, N), N), L);
    //Calculate Diffuse Component
    float nDotL = max(cosAng(N, L), 0.0);
    vec3 diffuse = vec3(1.)* nDotL;
    //Calculate Specular Component
    float rDotV = max(cosAng(R, V), 0.0);
    vec3 specular = vec3(1.)* pow(rDotV, 2.0);
    
    //no attenuation
    float att=0.8;
    
    //Compute final color
    vec3 color= att*((diffuse*baseColor) + specular/8.);
    
    return 0.1*baseColor+0.7*color;

}







//--------------------------------------------------------------------
// FOR THE MOON
//--------------------------------------------------------------------






vec3 toSphCoordsNoSeam(vec3 v){
    
    float theta=atan(v.y,v.x);
    float theta2=atan(v.y,abs(v.x));
    float phi=acos(v.z);
return vec3(theta,phi,theta2);
}



vec3 moonTexture(Vector tv){
    
    vec3 dir=tv.pos.coords.xyz-moonPos;
    dir=normalize(dir);
    
    vec3 rotDir=(earthFacing*vec4(dir.yzx,0)).xyz;

    vec3 angles=toSphCoordsNoSeam(rotDir);

    //theta coordinates (x=real, y=to trick the derivative so there's no seam)
float x=(angles.x+3.1415)/(2.*3.1415);
float z=(angles.z+3.1415)/(2.*3.1415);
    
float y=1.-angles.y/3.1415;

vec2 uv=vec2(x,y);
  vec2 uv2=vec2(z,y);//grab the other arctan piece;
    
vec3 color= textureGrad(moonTex,uv,dFdx(uv2), dFdy(uv2)).rgb;
    
    return color;
}





vec3 moonLight(Vector tv, vec3 lP){
    
    Point lightPos=Point(vec4(lP,1.));
    
    
    
     vec3 dir=tv.pos.coords.xyz-moonPos;
    dir=normalize(dir);
    
    vec3 rotDir=(earthFacing*vec4(dir.yzx,0)).xyz;

    vec3 angles=toSphCoordsNoSeam(rotDir);

    //theta coordinates (x=real, y=to trick the derivative so there's no seam)
float x=(angles.x+3.1415)/(2.*3.1415);
float z=(angles.z+3.1415)/(2.*3.1415);
    
float y=1.-angles.y/3.1415;

vec2 uv=vec2(x,y);
  vec2 uv2=vec2(z,y);//grab the other arctan piece;
    
vec3 baseColor= textureGrad(moonTex,uv,dFdx(uv2), dFdy(uv2)).rgb;
    
    
    
    
    
//    //get earth color:
//    vec3 dir=tv.pos.coords.xyz-earthPos;
//    dir=normalize(dir);
//    vec3 rotDir=(earthFacing*vec4(dir.yzx,0)).xyz;
//    


    //color of the sphere
   // vec3 baseColor = texture(earthCubeTex, rotDir).rgb;
    
    //vectors for phong model:
    Vector V =turnAround(tv);
    //normal vector to sphere is just the direction vector from its center
    Vector N=Vector(tv.pos,vec4(dir, 0.));
    
    Vector L = tangDirection(tv.pos, lightPos);
    Vector R = sub(scalarMult(2.0 * cosAng(L, N), N), L);
    //Calculate Diffuse Component
    float nDotL = max(cosAng(N, L), 0.0);
    vec3 diffuse = vec3(1.)* nDotL;
    //Calculate Specular Component
    float rDotV = max(cosAng(R, V), 0.0);
    vec3 specular = vec3(1.)* pow(rDotV, 2.0);
    
    //no attenuation
    float att=0.8;
    
    //Compute final color
    vec3 color= att*((diffuse*baseColor) + specular/8.);
    
    return 0.1*baseColor+0.7*color;

}
