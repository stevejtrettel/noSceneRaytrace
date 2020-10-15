
//----------------------------------------------------------------------------------------------------------------------
// NON-CONSTANT MEDIA
//----------------------------------------------------------------------------------------------------------------------

//the index of refraction of a varying medium is determined by a vector field (which is the gradient of the index function)
//this vector field is below:



//the vector field controlling the ODE

vec4 vecField(vec4 p){
    
    //center at the origin
    vec4 cent=vec4(0.,0.,0.,1.);
    vec4 v=p-cent;
    
    //direction vector from p to center point
    vec4 n=normalize(v);
    float dist=length(v);
    
    //lightRad is a uniform controlling the size of the disturbance
    float mag =3.*(1.-smoothstep(1.,1.5,dist));
    //float mag=1.-smoothstep(0.,lightRad,dist);

//refl is a uniform controling the magnitude of the disturbance
    return -refl*mag*n; 
}





//----------------------------------------------------------------------------------------------------------------------
// Marching Through NonConstant Media
//----------------------------------------------------------------------------------------------------------------------





void euler(inout Vector tv){
    
    //do an iteration of rk4 to the second order equation y''=vector field
    
    //timestep
    float dt=0.05;
    
    //constants computed during the process
    vec4 k1;
    vec4 j1;
    
    //initial conditions
    vec4 y=tv.pos.coords;//position
    vec4 u=tv.dir;//velocity
    
    
    //iteratively step through rk4
    for(int n=0;n<100;n++){
        
        //compute j1,k2
        j1=u*dt;
        k1=vecField(y)*dt;
      
        y+=j1;
        u+=k1;
    }
    
    //after the loop, reassemble tv at the endpoint
    sampletv=Vector(Point(y),u);
    
}





void rk4(inout Vector tv){
    
    //do an iteration of rk4 to the second order equation y''=vector field
    
    //timestep
    float dt=0.05;
    float dist;
    
    
    //constants computed during the process
    vec4 k1,k2,k3,k4;
    vec4 j1,j2,j3,j4;
    
    //initial conditions
    vec4 y=tv.pos.coords;//position
    vec4 u=tv.dir;//velocity
    
    
    //iteratively step through rk4
    for(int n=0;n<100;n++){
        
        //compute j1,k2
        j1=u*dt;
        k1=vecField(y)*dt;
        
        //compute j2,k2
        j2=(u+j1/2.)*dt;
        k2=vecField(y+k1/2.)*dt;
        
        //compute j3,k3
        j3=(u+j2/2.)*dt;
        k3=vecField(y+k2/2.)*dt;
        
        //compute j4,k4
        j4=(u+j3)*dt;
        k4=vecField(y+k3)*dt;
        
        
        //compute the updated y and u
        u+=k1/6.+k2/3.+k3/3.+k4/6.;
        y+=j1/6.+j2/3.+j3/3.+j4/6.;
        
        
        //if you are inside the connect sum mouth, stop
        dist=length(y.xyz);
        if(dist<1.){
            teleport=true;
            break;}
        
//        y+=j1;
//        u+=k1;
    }
    
    //after the loop, reassemble tv at the endpoint
    sampletv=Vector(Point(y),u);
    
}






















vec3 getPixelColor(Vector rayDir){
    
    teleport=false;
    Vector newDir;
    vec3 totalColor=vec3(0.);
     
    //raytrace through the geometry
    rk4(rayDir);
    
    
    //get the color from the direction you are pointing
    totalColor=skyTex(sampletv);

    //if you entered the wormhole
    if(teleport){
        //flip around and head back out
        rayDir=turnAround(sampletv);
        nudge(rayDir);
        rk4(rayDir);
        totalColor=cubeTexture(sampletv);
        
    }
    
    return totalColor;
    
}







