class UDP {
  private int max_points;
  public PVector pathPts[]; // points on path
  public int nPoints;
  public boolean exists;
  public boolean showTrack;

  UDP() {
    max_points = 600; // capacity of UDP; how many points can a UDP hold? 
    
    pathPts = new PVector[max_points];

    nPoints = 0;

    exists = false; // not yet enough points. 

    showTrack = true;
  }

  void addPoint(float x, float y) {
    if (nPoints >= max_points) {

    } else { // it's okay to add a new point!
      pathPts[nPoints++] = new PVector(x,y);
      if (nPoints > 1) {
        exists = true;
      }
    }
  }

  float distToLast(float ix, float iy) {
    if (nPoints > 0) {
      PVector v = pathPts[nPoints-1];
      float dx = v.x - ix;
      float dy = v.y - iy; 
      return mag(dx,dy);
    } else {
      // ret number larger than min dist needed to create new point on mouseDrag
      return 30; 
    }
  }

  void printPoints() {
    for (int j = 0; j < nPoints; j++) {
      println(this.pathPts[j]);
    }
  }

  void display() {
    if (this.showTrack) {
      noFill();
      stroke(0);
      beginShape();
      for (int j = 0; j < nPoints-1; j ++) {
        vertex(pathPts[j].x, pathPts[j].y);
      }
      endShape();
    }
  }
  
  PVector computePathCentroid() {
    PVector sum = new PVector(0.0, 0.0); 
    
    if (nPoints > 0) {
      for (int j = 0; j < nPoints; j++) {
        sum.x += pathPts[j].x;
        sum.y += pathPts[j].y;
      }
      sum.x = sum.x/float(nPoints);
      sum.y = sum.y/float(nPoints);
    } 
    return sum;
  }

}
