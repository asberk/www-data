Swarm swarm1;
Swarm swarm2;
color dc1 = color(255, 0, 0);
color dc2 = color(255);
PVector v0, v1;

void setup() {
  size(1280, 720);
  background(0);
  swarm1 = new Swarm(25, 5, dc2);
  swarm2 = new Swarm(25, 5, dc1);

  swarm1.display();
  swarm2.display();

} // /setup

void draw() {
  colorMode(RGB);
  noStroke();
  fill(0, 200);
  rect(0, 0, width, height);

  //  colorMode(HSB);
  PVector[] cn;
  
  for (int k = 0; k < swarm1.NUM_DOTS; k++) {
    cn = swarm1.getClosestNeighbours(k);
    for (int j = 0; j < swarm1.NNbr; j++) {
      //stroke(k*255/float(swarm.NUM_DOTS), 255, 255);
      stroke(255);
      v0 = swarm1.dots[k].pos;
      v1 = cn[j];
      line(v0.x, v0.y, v1.x, v1.y);

    } // /for inner
  } // /for outer

  swarm1.display();
  swarm1.updateDots2();



  for (int k = 0; k < swarm2.NUM_DOTS; k++) {
    cn = swarm2.getClosestNeighbours(k);
    for (int j = 0; j < swarm2.NNbr; j++) {
      //stroke(k*255/float(swarm.NUM_DOTS), 255, 255);
      stroke(255, 0, 0);
      v0 = swarm2.dots[k].pos;
      v1 = cn[j];
      line(v0.x, v0.y, v1.x, v1.y);

    } // /for inner
  } // /for outer

  swarm2.display();
  swarm2.updateDots2();
}


class Dot {
  float dotSize;
  color dotColor;
  
  PVector pos;
  PVector vel;
  PVector acc;

  Dot(PVector pos, PVector vel, PVector acc, float dotSize, color dotColor) {
    this.pos = pos;
    this.vel = vel;
    this.acc = acc;
    this.dotSize = dotSize;
    this.dotColor = dotColor;
  }
  
  Dot(PVector pos, PVector vel, PVector acc) {
    this(pos, vel, acc, 10.0, color(0));

  }

  Dot() {
    this(new PVector(0,0), new PVector(0,0), new PVector(0,0), 10.0, color(0));
  }



  void display() {
    strokeWeight(1);
    stroke(0);
    fill(dotColor);
    
    ellipse(pos.x, pos.y, dotSize, dotSize);
  }
  
  // change pos, vel or acc
  void setPos(PVector xnew) {
    this.pos = xnew;
  }  
  void setVel(PVector vnew) {
    this.vel = vnew;
  }
  void setAcc(PVector anew) {
    this.acc = anew;
  }

  // add to pos, vel or acc
  void bumpX(PVector dx) {
    this.pos.add(dx);
  }
  void bumpV(PVector dv) {
    this.vel.add(dv);
  }
  void bumpA(PVector da) {
    this.acc.add(da);
  }


}



class Swarm {
  Dot dots[];
  
  int NUM_DOTS; // swarm size
  int NNbr; // number of neighbours each dot has (e.g., 2 or 3)
  final float PrRan = .2; // probability that dot travels in new direction
  final float kappa = .3; // scaling coefficient for acceleration
  final float Rc = 100; // for scalingFn
  final float alpha_3 = .1;
  final float alpha_4 = .5; 
  final float gamma = .1;
  final float beta = .1;
  final float TOP_SPEED = 2;
  

  Swarm(int NDots, int NumNbrs, color dc) {
    NUM_DOTS = NDots;
    if (NumNbrs > NUM_DOTS) {
      NNbr = NUM_DOTS/2;
    } else {
      NNbr = NumNbrs;
    }
    dots = new Dot[NUM_DOTS];
    //PrRan = Pr;

    for (int j = 0; j < NUM_DOTS; j++) {
      PVector dotpos = new PVector(random(width), random(height));
      PVector dotvel = new PVector(random(-1, 1), random(-1, 1));
      PVector dotacc = new PVector(random(-1, 1), random(-1, 1));
      colorMode(HSB);
      dots[j] = new Dot(dotpos, dotvel, dotacc, 5.0, dc);//color(j*255/float(NUM_DOTS), 255, 255));
      colorMode(RGB);
    }
    
  }

  void display() {
    for (int j = 0; j < NUM_DOTS; j++) {
      dots[j].display();
    }
  }

  PVector[] getClosestNeighbours(int j) {
    Dot dot = this.dots[j];
    float[] dists = new float[NUM_DOTS];
    float[] distSort = new float[NUM_DOTS];
    PVector[] closestNbrs = new PVector[NNbr];
    
    // find distances of each dot to every other dot
    for (int k = 0; k < NUM_DOTS; k++) {
      dists[k] = dot.pos.dist(dots[k].pos);
    }
    
    // Determine which dots are closest to each other. 
    distSort = sort(dists);
    // Then, for each other dot...
    for (int k = 0; k < NUM_DOTS; k++) {
      if (j == k) {
        continue; // the same dot
      }
      // ... check to see if the corresponding distance is one of the NNbr-th
      // closest distances. 
      for (int l = 0; l < NNbr; l++) {
        if (dot.pos.dist(dots[k].pos) == distSort[l+1]) {
          // If so, make that position a closest neighbour. 
          closestNbrs[l] = dots[k].pos;
        }
      }
    }
    return closestNbrs;
    
  } // /getClosestNeighbours


  // returns positions of all dots in an array
  PVector[] getDotPositions() {

    PVector[] dotPosns = new PVector[NUM_DOTS];
    for (int j = 0; j < NUM_DOTS; j++) {
      dotPosns[j] = dots[j].pos;
    }
    return dotPosns;
  } // /getDotPositions

  float[] getProbVec() {
    int N = this.NNbr;
    float[] probvec = new float[N + 1];
    probvec[0] = this.PrRan;
    for (int j = 1; j < N+1; j++) {
      probvec[j] = probvec[j-1] + 2*j*(1-PrRan)/float(N*(N+1));
    }
    return probvec;
  }


  PVector[] calcAccel() {

    PVector[] closestNbrs;
    int nbrChoice;
    PVector[] accel = new PVector[NUM_DOTS];
    PVector vv = new PVector(0,0);
    float aM;
    // for each dot
    for (int j = 0; j < NUM_DOTS; j++) {
      nbrChoice = NNbr-1;
      if (nbrChoice == this.NNbr) {
        vv.set(random(-width, width), random(-height, height));
        vv.normalize();
        accel[j] = vv;
      } else {
        closestNbrs = getClosestNeighbours(j);
        vv = PVector.sub(closestNbrs[nbrChoice], dots[j].pos);
        aM = accelMag(vv.mag());
        vv.normalize();
        vv.mult(aM);
        accel[j] = vv;
      }
    }
    return accel;
  } // /calcAccel

  PVector dotAccel(int j, PVector[] nbrs) {
    Dot dot = this.dots[j];
    PVector accel = new PVector(0,0);
    PVector rjk = new PVector(0,0);
    PVector vel_diff;
    PVector pos_diff;
    PVector drag;
    PVector noisevec = new PVector(randomGaussian(), randomGaussian());
    
    for (int k = 0; k < NUM_DOTS; k++) {
      if (j == k) {
        continue;
      }
      rjk = PVector.sub(this.dots[k].pos, dot.pos);
      rjk.normalize();
      rjk.mult(accelMag(rjk.mag()));
      accel.add(rjk);
    }
    for (int k = 0; k < this.NNbr; k++) {
      vel_diff = PVector.sub(dots[k].vel, dot.vel);
      pos_diff = PVector.sub(dots[k].pos, dot.pos);
      vel_diff.mult(alpha_3);
      pos_diff.mult(alpha_4);
      accel.add(PVector.add(vel_diff, pos_diff));
    }
    drag = dot.vel;
    drag.mult(gamma);
    noisevec.mult(beta);
    
    accel.sub(PVector.add(drag, noisevec));

    return accel;
  }

  float accelMag(float r) {
    // kappa is scaling coefficient
    //return kappa*atan(x-10)/HALF_PI;
    float out; 
    if (r < Rc) {
      out = -kappa*(1-r/Rc);
    } else {
      out = 0.0;
    }
    return out;
  }

  void updateDots2() {
    PVector dot_accel;
    PVector[] closestNbrs;

    // for each Dot
    for (int j = 0; j < NUM_DOTS; j++) {
      closestNbrs = getClosestNeighbours(j);
      dots[j].bumpA(dotAccel(j, closestNbrs));
      dots[j].bumpV(dots[j].acc);
      if (dots[j].vel.mag() > TOP_SPEED) {
        dots[j].vel.setMag(TOP_SPEED);
      }
      dots[j].bumpX(dots[j].vel);
      if (dots[j].pos.x > width) {
        dots[j].pos.x = 0;
      } else if ( dots[j].pos.x < 0) {
        dots[j].pos.x = width;
      }
      if (dots[j].pos.y > height) {
        dots[j].pos.y = 0;
      } else if (dots[j].pos.y < 0) {
        dots[j].pos.y = height;
      }
    }
  }

  void updateDots() {
    // update Position
    PVector[] dot_accel = calcAccel();
    for (int j = 0; j < NUM_DOTS; j++) {
      dots[j].bumpA(dot_accel[j]);
      dots[j].acc.setMag(1.0);
      dots[j].bumpV(dots[j].acc);
      if (dots[j].vel.mag() > TOP_SPEED) {
        dots[j].vel.setMag(TOP_SPEED);
      }
      dots[j].bumpX(dots[j].vel);
      if (dots[j].pos.x > width) {
        dots[j].pos.x = 0;
      } else if ( dots[j].pos.x < 0) {
        dots[j].pos.x = width;
      }
      if (dots[j].pos.y > height) {
        dots[j].pos.y = 0;
      } else if (dots[j].pos.y < 0) {
        dots[j].pos.y = height;
      }
    }
    
  }


} // /swarm

float[] cumsum(float[] x) {
  float[] out = new float[x.length];
  float y = 0.0;
  for(int j = 0; j < x.length; j++) {
    y += x[j];
    out[j] = y;
  }
  return out;
}


