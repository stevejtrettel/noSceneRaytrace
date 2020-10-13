
//----------------------------------------------------------------------------------------------------------------------
// NON-CONSTANT MEDIA
//----------------------------------------------------------------------------------------------------------------------

//the index of refraction of a varying medium is determined by a vector field
vec3 gradN(vec3 p){
    
    vec3 cent=vec3(0.,2.,0.);
    
    vec3 v=p-cent;
    vec3 n=normalize(v);
    float dist=length(v);
    
    //lightRad is a uniform controlling the size of the disturbance
    float mag=1.-smoothstep(0.,lightRad,dist);

//refl is a uniform controling the magnitude of the disturbance
    return -refl*mag*n; 
}


vec3 gradN(Point p){
    
    return gradN(p.coords.xyz);
}

vec3 gradN(Vector tv){
    return gradN(tv.pos);
}









//----------------------------------------------------------------------------------------------------------------------
// Marching Through NonConstant Media
//----------------------------------------------------------------------------------------------------------------------

void refractTrace(Vector tv){
    //raytrace until you are a certain distance from the original viewer, then stop and set sampletv
    
    //set dt
    float dt=0.01;
    //set number of steps
    int numSteps=500;
    
    //set initial conditions
    float x,y,z;//position
    float u,v,w;//direction
    
    vec3 p=tv.pos.coords.xyz;
    vec3 dir=tv.dir;    
    
    //first; maybe just raytrace a fixed number of steps:
    for(int k=0;k<numSteps;k++){
        
        //update the direction based on the position:
        p+=dt*dir;
        
        //update direction
        dir+=dt*gradN(p);
    }
    
    //after march; build final tangent vector
Vector finalV;
    finalV.pos.coords=vec4(p,1.);
    finalV.dir=dir;
    
    sampletv=finalV;
    distToViewer=float(numSteps)*dt;
    
}
















vec3 getPixelColor(Vector rayDir){
    
    vec3 totalColor=vec3(0.);
     
    
    refractTrace(rayDir);
    totalColor=skyTex(sampletv);

    
    return totalColor;
    
}







