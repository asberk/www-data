class glowUDP extends UDP {
  private float t; 
  private float dt;
  private float a;
  private float da;
  private float t0; // used to update phase when scaling speed is increased/decreased
  private float dhue;
  
  public boolean glowStatus;

  private int NUM_OVERLAY;
  private color glowColor;

  glowUDP() {
    super();
    NUM_OVERLAY = 5;
    glowColor = color(0, 200, 0);
    t = 0.0;
    dt = 0.02;

    glowStatus = false;
    dhue = 0.5;

    a = 2.0;
    da = dt/TWO_PI;
    t0 = 0.0;

  }

  void glow() {
    PVector trVec = this.computePathCentroid();
    pushMatrix();
    translate(trVec.x, trVec.y);
    scale((cos(a*t)+1)/2.0);
    translate(-trVec.x, -trVec.y);
    noFill();
    for (int k=0; k < NUM_OVERLAY; k++) {
      strokeWeight(pow(NUM_OVERLAY-k+1,2));
      int r = (this.glowColor >> 16) & 0xFF;  // Faster way of getting red
      int g = (this.glowColor >> 8) & 0xFF;   // Faster way of getting green
      int b = this.glowColor & 0xFF;          // Faster way of getting blue

      stroke(r,g,b, 255/float(NUM_OVERLAY));
      beginShape();
      for (int j = 0; j < nPoints-1; j ++) {
        vertex(pathPts[j].x, pathPts[j].y);
      }
      endShape();
    }
    popMatrix();
    t += dt;
    if (t > TWO_PI) {
      t = t % TWO_PI;
    }

  }

  void increaseHue() {
    colorMode(HSB);
    this.glowColor = color((hue(this.glowColor)+dhue)%255, 255, 255);
    colorMode(RGB);
  }

  void decreaseHue() {
    colorMode(HSB);
    this.glowColor = color((hue(this.glowColor)-dhue)%255, 255, 255);
    colorMode(RGB);
  }

  void increaseSpeed() {
    this.t0 = t;
    this.a += da;
  }

  void decreaseSpeed() {
    this.t0 = t;
    this.a -= da;
  }

}
