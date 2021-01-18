
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











void rk4Step(inout Vector tv,float dt){

    //constants computed during the process
    velAcc k1,k2,k3,k4;
    Vector temp;
    

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
    
}




bool inside(Vector tv,vec3 pos, float rad){
    if(length(tv.pos.coords.xyz-pos)<rad){
        return true;
    }
    else return false;
}




void binarySearch(inout Vector tv,float dt,vec3 pos, float rad){
    //given that you just passed the earth, binary search to find it
    float dist=0.;
    //flowing dist doesnt hit the plane, dist+step does:
    float testDist=dt;
    Vector temp;
    for(int i=0;i<4;i++){
        
        //divide the step size in half
         testDist=testDist/2.;

        //test flow by that amount:
        temp=tv;
        rk4Step(temp, dist+testDist);
        //if you are still above the plane, add to distance.
        if(!inside(temp,pos, rad)){
            dist+=testDist;
        }
        //if not, then don't add: divide in half and try again
    
    }
    
//step tv ahead by the right ammount;
  rk4Step(tv,dist);
    
}



void teleport(inout Vector tv){
    float x=tv.pos.coords.x;
    float y=tv.pos.coords.y;
    float z=tv.pos.coords.z;
    
    float size=25.;
    float halfSize=size/2.;
    
    if(x>halfSize){
        tv.pos.coords.x=-halfSize+0.1;
        return;
    }
    else if(x<-halfSize){
        tv.pos.coords.x=halfSize-0.1;
        return;
    }
    else if(y>halfSize){
        tv.pos.coords.y=-halfSize+0.1;
        return;
    }
    else if(y<-halfSize){
        tv.pos.coords.y=halfSize-0.1;
        return;
    }
    else if(z>halfSize){
        tv.pos.coords.z=-halfSize+0.1;
        return;
    }
    else if(z<-halfSize){
        tv.pos.coords.z=halfSize-0.1;
        return;
    }
}


void trace(inout Vector tv){ 
    
    int maxSteps=300;
    
    //timestep
   // float dist=length(tv.pos.coords.xyz);
    float dt;
    float R,r;

    Vector temp;
    //iteratively step through rk4
    for(int n=0;n<maxSteps;n++){

        
        float maxStep=0.25;\
            
        //distance from schwarzchild radius
        R=length(tv.pos.coords.xyz)-1.;
    
        //set dt based on this
        dt=min(maxStep,max(R/2.,0.01));
        
        //set alternate dt based on earth location:
         r=length(tv.pos.coords.xyz-earthPos)-earthRad;
        
        dt=min(dt,max(r/2.,0.1));
        
        
        
        //set alternate length based on moon location:
        
        r=length(tv.pos.coords.xyz-moonPos)-moonRad;
        
        dt=min(dt,max(r/2.,0.1));
        
        
        
        
        temp=tv;
        
        //do an rk4 step
        rk4Step(temp,dt);
        
        
    
        if(inside(temp,earthPos,earthRad)){
            //if you entered the earth for the first time:
            //go back to your previous position, and search
            binarySearch(tv,dt,earthPos,earthRad);
            //now tv is set right at the earths surface
            earth=true;
            break;
        }
        
        
        if(inside(temp,moonPos,moonRad)){
            //if you entered the earth for the first time:
            //go back to your previous position, and search
            binarySearch(tv,dt,moonPos,moonRad);
            //now tv is set right at the earths surface
            moon=true;
            break;
        }
        
        //otherwise set tv to your new location and keep going
        tv=temp;
        
        
        //if you enter the event horizon, return black
        if(length(tv.pos.coords.xyz)<1.){
            eventHorizon=true;
            break;
        }
        

        
        //if you leave fundamental domain: teleport
        teleport(tv);
        
        
        
        
    }
    
        //after the loop, reassemble tv at the endpoint
    sampletv=tv;
    
}













vec3 getPixelColor(Vector rayDir){
    
    vec3 totalColor=vec3(0.);
     
   //euler(rayDir);
    trace(rayDir);
    
    //if you don't fall in the black hole, see where you go
    if(eventHorizon){
        totalColor=EHGrid(sampletv);
    }

    else if(earth){
        totalColor=earthLight(sampletv,vec3(-10,-10,0));
    }
    
        else if(moon){
        totalColor=moonLight(sampletv,vec3(-10,-10,0));
    }
    
    else{
    totalColor=skyTex(sampletv);
    }
    
    return totalColor;
    
}







