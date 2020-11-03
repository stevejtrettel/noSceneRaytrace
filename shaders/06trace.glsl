
//----------------------------------------------------------------------------------------------------------------------
// NON-CONSTANT MEDIA
//----------------------------------------------------------------------------------------------------------------------

//the index of refraction of a varying medium is determined by a vector field (which is the gradient of the index function)
//this vector field is below:



//the vector field controlling the ODE
//this ficticious force whose trajectories have the same paths in space as the projection of schwarzchild geodesics.

vec4 vecField(Vector tv){
    
    vec3 r=tv.pos.coords.xyz;
    vec3 v=tv.dir.xyz;
    float R=length(r);
    
    vec3 l=cross(r,v);
    float L=length(l);
    
    float mag=1.5*L*L/(R*R*R*R*R);
    vec3 acc=-mag*r;
    
    return vec4(acc,0.);
    
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
    dState.acc=vecField(tv);
    return dState;
}





void euler(inout Vector tv){
    float dist;
    float dt;
    velAcc dState;
    
     //iteratively step through rk4
    for(int n=0;n<300;n++){
   // dist=length(tv.pos.coords.xyz);
        
    dState=stateDeriv(tv);
    
    dt=0.1;
    
    tv=nudge(tv,dState,dt);
        
    }
    
    sampletv=tv;
}

//
//
//
//void euler(inout Vector tv){
//    
//    //do an iteration of rk4 to the second order equation y''=vector field
//    
//    //timestep
//    float dt=0.05;
//    
//    //constants computed during the process
//    vec4 k1;
//    vec4 j1;
//    
//    //initial conditions
//    vec4 y=tv.pos.coords;//position
//    vec4 u=tv.dir;//velocity
//    
//    
//    //iteratively step through rk4
//    for(int n=0;n<100;n++){
//        
//        //compute j1,k2
//        j1=u*dt;
//        k1=vecField(y)*dt;
//      
//        y+=j1;
//        u+=k1;
//    }
//    
//    //after the loop, reassemble tv at the endpoint
//    sampletv=Vector(Point(y),u);
//    
//}
//





void rk4(inout Vector tv){
    
    //do an iteration of rk4 to the second order equation y''=vector field
    
    //timestep
   // float dist=length(tv.pos.coords.xyz);
    float dt;
    float R;
    //constants computed during the process
    velAcc k1,k2,k3,k4;
    
    //initial conditions
   // vec4 y=tv.pos.coords;//position
    //vec4 u=tv.dir;//velocity
    
    Vector temp;
    
    //iteratively step through rk4
    for(int n=0;n<50;n++){
        
      //set the step size to be the min of 0.1 and distance to the sphere (right now 1.)
        
        //distance from schwarzchild radius
        R=length(tv.pos.coords.xyz)-1.;
    
       dt=min(1.,R/2.+0.001);
   
        
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
        velAcc total=scale(k1,1.);  
        total=add(total,scale(k2,2.));
        total=add(total,scale(k3,2.));
        total=add(total,k4);
        total=scale(total,1./6.);
        
        tv=nudge(tv,total,1.);
        
        
        //if you enter the event horizon, return black
        if(length(tv.pos.coords.xyz)<1.){
            eventHorizon=true;
            break;
        }
       
    }
    
    //after the loop, reassemble tv at the endpoint
    sampletv=tv;
    
}





















vec3 getPixelColor(Vector rayDir){
    
    vec3 totalColor=vec3(0.);
     
   //euler(rayDir);
    rk4(rayDir);
    
    //if you don't fall in the black hole, see where you go
    if(eventHorizon){
        totalColor=sphereGrid(sampletv);
    }
    else{
    totalColor=skyTex(sampletv);
    }
    
    return totalColor;
    
}







