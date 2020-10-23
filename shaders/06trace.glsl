
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
    float mag=1.-smoothstep(0.,lightRad,dist);

//refl is a uniform controling the magnitude of the disturbance
    return -refl*mag*n; 
}






//structure for the derivative of a tangent vector.
struct velAcc{
    vec4 vel;
    vec4 acc;
};


velAcc add(velAcc s1,velAcc s2){
    vec4 vel=s1.vel+s2.vel;
vec4 acc=s1.acc+s2.acc;
velAcc dState;
dState.vel=vel;
dState.acc=acc;
    return dState;
}



velAcc scale(velAcc dState,float k){
    dState.vel*=k;
    dState.acc*=k;
    return dState;
}


Vector nudge(Vector tv, velAcc dState,float step){
    tv.pos.coords+=dState.vel*step;
    tv.dir+=dState.acc*step;
    return tv;
}
//----------------------------------------------------------------------------------------------------------------------
// Marching Through NonConstant Media
//----------------------------------------------------------------------------------------------------------------------



velAcc stateDeriv(Vector tv){
    
    vec4 pos=tv.pos.coords;
    vec4 vel=tv.dir;
    
 velAcc dState;
    dState.vel=vel;
    dState.acc=vecField(pos);
    return dState;
}




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
    float dt=0.1;
    
    //constants computed during the process
    velAcc k1,k2,k3,k4;
    
    //initial conditions
    vec4 y=tv.pos.coords;//position
    vec4 u=tv.dir;//velocity
    
    Vector temp;
    
    //iteratively step through rk4
    for(int n=0;n<100;n++){
   
        
        //get the derivative
        k1=stateDeriv(tv);
        k1=scale(k1,dt);
        
        //move the point a littkle
        temp=nudge(tv,k1,0.5);
        k2=stateDeriv(temp);
        k2=scale(k2,dt);
        
        //get k3
        temp=nudge(tv,k2,0.5);
        k3=stateDeriv(temp);
        k3=scale(k3,dt);
        
        //get k4
        temp=nudge(tv,k3,1.);
        k4=stateDeriv(temp);
        k4=scale(k4,dt);
        
        //add up results:
        velAcc total=add(k1,scale(k2,2.));
        total=add(total,scale(k3,2.));
        total=add(total,k4);
        
        tv=nudge(tv,total,1.);
        
       
    }
    
    //after the loop, reassemble tv at the endpoint
    sampletv=tv;
    
}






















vec3 getPixelColor(Vector rayDir){
    
    vec3 totalColor=vec3(0.);
     
    
    rk4(rayDir);
    totalColor=skyTex(sampletv);

    
    return totalColor;
    
}







