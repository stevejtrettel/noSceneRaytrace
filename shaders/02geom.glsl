//----------------------------------------------------------------------------------------------------------------------
// LOCAL GEOMETRY
//----------------------------------------------------------------------------------------------------------------------

/*
  Methods perfoming computations in the tangent space at a given point.
*/


// Add two tangent vector at the same point (return v1 + v2)
Vector add(Vector v1, Vector v2) {
    // return the added vectors
    return Vector(v1.pos, v1.dir + v2.dir);
}

// subtract two tangent vector at the same point (return v1 - v2)
Vector sub(Vector v1, Vector v2) {
    // return the added vectors
    return Vector(v1.pos, v1.dir - v2.dir);
}

// scalar multiplication of a tangent vector (return a * v)
Vector scalarMult(float a, Vector v) {
    return Vector(v.pos, a * v.dir);
}


// dot product of the two vectors
float tangDot(Vector v1, Vector v2){
    return dot(v1.dir, v2.dir);
}

// calculate the length of a tangent vector
float tangNorm(Vector v){
    return sqrt(tangDot(v, v));
}

// create a unit tangent vector (in the tangle bundle)
// when possible use the normalization method below
Vector tangNormalize(Vector v){
    // length of the vector
    float length = tangNorm(v);
    return Vector(v.pos, v.dir / length);
}


// cosAng between two vector in the tangent bundle
float cosAng(Vector v1, Vector v2){
    return tangDot(v1, v2);
}

Vector turnAround(Vector v){
    return Vector(v.pos, -v.dir);
}














//----------------------------------------------------------------------------------------------------------------------
// GLOBAL GEOMETRY
//----------------------------------------------------------------------------------------------------------------------





// flow the given vector during time t
Vector flow(Vector v, float t) {
    
    vec4 diff=t*vec4(v.dir,0.);
    
    Point newPos=Point(v.pos.coords+diff);
    
    return Vector(newPos,v.dir);
}




void nudge(inout Vector v){
    v=flow(v,0.01);
}







