// This file contains the contents of moving_lines/*.pde
// extraneous comments were removed
// hopefully this file works in a canvas object. 

int NVertices = 25;
int NLines = 23*7; // for NVertices==25: 12 and 23*k, k\in\ints are aesthetically-pleasing choices. 
Track track;
int CURRENT_VTX = 0;

int[] keysPressed = new int[0];

void setup() {
  size(800, 500);
  background(255);

  // setup track
  track = new Track(NVertices, NLines);

  // current issue in definition of arclength vector / linespacing:
  // when we define linespacing, we forget to take into account where the lines will end.
  // this is why we see them ending past the track / not on the track. to fix this, we need
  // to define the arclength vector / linespacing in such a way that we achieve Nlines, 
  // all of which end *before* arc length 1 (where arclength is in the interval [0,1]).

  track.setColourPalette("rainbow");
}

void draw() {
  background(255);
  track.drawTrack();

  track.drawLines();
  track.updateTime();
  track.setLineCoords();

//   noLoop();

  if (mousePressed && (mouseButton == LEFT)) {
    track.Nlines += 1;
    track.resetLines();
    track.setColourPalette();

  } else if (mousePressed && (mouseButton == RIGHT)) {
    if (track.Nlines > 0) {
      track.Nlines -= 1;
      track.resetLines();
      track.setColourPalette("rainbow");
    }
  }
  
  if (keyPressed && (key == CODED)) {
    if (keyCode == UP) {
      track.vtx[track.Nvtx + CURRENT_VTX] -= 5;
    } else if (keyCode == DOWN) {
      track.vtx[track.Nvtx + CURRENT_VTX] += 5;
    } else if (keyCode == LEFT) {
      track.vtx[CURRENT_VTX] -= 5;
    } else if (keyCode == RIGHT) {
      track.vtx[CURRENT_VTX] += 5;
    }
    //track.resetLines();
  } else if (keyPressed && (key != CODED)) {
    //    if (key == ' ') {
    // CURRENT_VTX = (CURRENT_VTX +1)%track.Nvtx;
    //}
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if (e > 0) {
    track.dt += .0001;
  } else if (e < 0) {
    if (track.dt > 0.0001) {
      track.dt -= .0001;
    }
  }
}

void keyPressed() {
  if (key == ' ') {
    CURRENT_VTX = (CURRENT_VTX +1)%track.Nvtx;
  }
}



class Track {
  int Nvtx, Nlines; // number of vertices, lines on track 
  float[] vtx; // vector of xcoords and y coords of vertices on track
  Line[] Lines;
  float[] sgmtLengths;
  //float[] x0, y0, x1, y1; // vector of x coords, y coords for lines on track
  //int[] k0, k1; // counts current segment on which end points are travelling
  
  float vtxWidth = 5.0; // width of ellipses marking track vertices
  color vtxFill = color(255, 0, 0); // fill color of vertices
  float trackWidth = 1.0; // width of track
  color trackStroke = color(190); // color of track

  // properties of movement
  float[] t; // "time" --- variable parametrizing track coord/s <x(t),y(t)> 
  float dt = .0025; // e.g., seconds. 

  
  Track (int Nvtx_, int Nlines_) {
    this.Nvtx = Nvtx_; // needs to be a lower bound on number of vertices. 
    this.Nlines = Nlines_;
    
    this.vtx = setVtx(Nvtx);
    this.sgmtLengths = getSgmtLengths(vtx);
    //    //this.svn = new int[this.Nlines];
    this.initTimes();
    this.createLines();
  }

  Track() {
    this(10, 3);
  }
  // Use this when the locations of the track vertices are known
  // Track (float[] vtx_, int Nlines_) {
  //   this.Nvtx = vtx_.length/2;
  //   this.Nlines = Nlines_;
  //   this.vtx = vtx_;
  //   this.sgmtLengths = getSgmtLengths(this.vtx);
  //   this.initTimes();
  //   this.createLines();
  // }

  // compute cumulative lengths for each segment of the track, starting from 0
  private float[] getSgmtLengths(float[] vtx) {
    float[] sgmtLengths = new float[Nvtx];
    sgmtLengths[0] = 0.0;

    for (int j = 1; j < Nvtx; j++) {
      sgmtLengths[j] = sgmtLengths[j-1] + sqrt(pow(vtx[j]-vtx[j-1], 2) + pow(vtx[Nvtx+j]-vtx[Nvtx + j-1], 2));
    }
    return sgmtLengths;    
  }

  private float getTrackLength(float[] vtx) {
    float trackLength = 0.0;
    for (int j=1; j < Nvtx; j++) {
      trackLength += sqrt(pow(vtx[j]-vtx[j-1], 2) + pow(vtx[Nvtx+j]-vtx[Nvtx + j-1], 2));
    }
    return trackLength;
  }


  /*
    Get (x,y) coordinates of plane curve defined by vertices of vtx.
    Coordinates are defined according to the function:
    <x(t), y(t)> := { (n+1-t)<x_n, y_n> + (t-n)<x_n+1, y_n+1>,  t \in [n, n+1),  n < Nvtx-1
                    { <vtx[Nvtx-1], vtx[2*Nvtx-1]>,             t = Nvtx-1
    so that a point travels from vtx[0] to vtx[1] as t goes from 0 to 1, 
    vtx[1] to vtx[2] as t goes from 1 to 2, etc. It should be noted that 
    elements of t must be in the interval [0, Nvtx]. 
  */
  float[] getCoords(float t) {
    float[] xy = new float[2]; // room for x and y coords
    int n; 
    if (floor(t) == Nvtx-1) {
      n = Nvtx-2;
    } else {
      n = floor(t);
    }
    // set x coordinate
    xy[0] = (n+1-t)*vtx[n] + (t-n)*vtx[n+1];
    // set y coordinate
    xy[1] = (n+1-t)*vtx[Nvtx + n] + (t-n)*vtx[Nvtx + n + 1];
    return xy;
  }

  // returns values t for given arclengths s, where s \in [0, 1]
  float arcLengthToTime(float s) {
    // float s is input arc length
    float t; // t value to return

    // get cumulative lengths of track; 
    // last element of sgmtLengths gives total track length
    // old : float[] sgmtLengths = getSgmtLengths(vtx);
    float trackLength = this.sgmtLengths[Nvtx-1]; // faster than using getTrackLength

    // find corresponding t for arclength value s
    // two cases:
    if (s == 1.0) { // trivial case
      t = Nvtx-1; // corresponds to the end of the track
    } else { // non-trivial case
      int k = getSTVfromArcLength(s);
      t = k + (s*trackLength - this.sgmtLengths[k])/(this.sgmtLengths[k+1]-this.sgmtLengths[k]);
    }

    return t;
  }

  /*
    This method retrieves the "starting" track vertex (STV),
    called (px0, py0) of the track segment for which F(s) lies on
    segment (px0,py0)_(px1,py1).  (e.g. if the start-point (x0,y0)
    of a Line object is at arc-length s, then (x0,y0) is between
    (px0, py0) and (px1, py1), while the end-point of the line,
    (x1,y1), is between (px1, py1) and (px2, py2)) 

    Note: require that s \in [0, 1]. 
  */
  int getSTVfromArcLength(float s) {
    int stv = Nvtx-2; // at second last vertex
    s *= this.sgmtLengths[Nvtx-1];
    for (int k = 0; k < Nvtx-1; k++) {
      if (s >= this.sgmtLengths[k] && s < sgmtLengths[k+1]) {
        stv = k;
        break;
      }
    }
    return stv; // returns as Nvtx-2 if s corresponds to last vertex; otherwise, k.
  }

  // set vertices of track
  float[] setVtx(int Nvtx) {
    float[] vtx = new float[2*Nvtx];

    
    // line
    for (int j = 0; j < Nvtx; j++) {
      vtx[j] = 10 + j*(width-20)/(Nvtx-1.0);
      vtx[Nvtx + j] = height/2.0 + pow(-1, j)*height/6.0;
    }
    
    /*
    // circle
    for (int j = 0; j < Nvtx; j++) {
      vtx[j] = .5*width + .25*width*cos(2*PI*j/float(Nvtx-2));
      vtx[Nvtx + j] = .5*height + .25*height*sin(2*PI*j/float(Nvtx-2));
    }
    */
    return vtx;
  }
  
  void createLines() {
    this.Lines = new Line[this.Nlines];
    //    this.svn = new int[this.Nlines];

    float[] xy0, xy1;
    
    for (int j = 0; j < this.Nlines; j++) {
      // get initial coordinates for line (ordered as (x0, x1, y0, y1))
      xy0 = getCoords(this.t[j]); // (x0, y0)
      xy1 = getCoords(this.t[j]+1.0); // (x1, y1)
      this.Lines[j] = new Line(xy0[0], xy0[1], xy1[0], xy1[1]);
      //      this.svn[j] = floor(this.t[j]); // what happens if t==Nvtx-2? Hopefully this was made to be impossible
      // ^^^ POSSIBLE ISSUE WITH THIS. IF THINGS MESS UP, LOOK HERE AND CF. bumpLines() FOR THE ISSUE
      // thing to do: this.Lines[j].setLineColor ?? 
    }
  }

  void initTimes() {
    this.t = new float[this.Nlines];
    float trackLength = this.sgmtLengths[Nvtx-1];
    float subLength = this.sgmtLengths[Nvtx-2]; // start of lines cannot be greater than this, since lines must end *before* last vertex
    for (int j = 0; j < this.Nlines; j++) {
      // get initial coordinates for line (ordered as (x0, x1, y0, y1))
      this.t[j] = arcLengthToTime(j/float(this.Nlines)*subLength/trackLength);
    }
  }

  // what should this be used for? 
  void setLines() {
    this.Lines = new Line[this.Nlines];
    //    this.svn = new int[this.Nlines];
    
    float trackLength = this.sgmtLengths[Nvtx-1];
    float subLength = this.sgmtLengths[Nvtx-2]; // start of lines cannot be greater than this, since lines must end *before* last vertex
    float t; // "time" parameter
    float[] xy0, xy1;
    for (int j = 0; j < Nlines; j++) {
      // get initial coordinates for line (ordered as (x0, x1, y0, y1))
      t = arcLengthToTime(j/float(this.Nlines)*subLength/trackLength);
      xy0 = getCoords(t); // (x0, y0)
      xy1 = getCoords(t+1.0); // (x1, y1)
      this.Lines[j] = new Line(xy0[0], xy0[1], xy1[0], xy1[1]);
      //      this.svn[j] = floor(t); // what happens if t==Nvtx-2? Hopefully this was made to be impossible
      // ^^^ POSSIBLE ISSUE WITH THIS. IF THINGS MESS UP, LOOK HERE AND CF. bumpLines() FOR THE ISSUE
      // thing to do: this.Lines[j].setLineColor ?? 
    }
  }

  // display track in output window
  void drawTrack() {
    stroke(this.trackStroke);
    strokeWeight(this.trackWidth);
    for (int j = 1; j < Nvtx; j++) {
      line(vtx[j-1], vtx[Nvtx+j-1], vtx[j], vtx[Nvtx+j]);
    }
    fill(this.vtxFill);
    noStroke();
    for (int j = 0; j < Nvtx; j++) {
      ellipse(vtx[j], vtx[Nvtx+j], vtxWidth, vtxWidth);
    }
  }
  
  void drawLines() {
    for (int j = 0; j < this.Nlines; j++) {
      this.Lines[j].display();
    }
  }
  
  /*
    If we have the [s]tarting [v]ertex [n]umber for each Line, say n, then we should be able to find the t value that corresponds to the line's current position.

    (x0, y0) = (p0x,p0y)(1-t) + t(p1x, p1y) = (p0x, p0y) + t((p1x,p1y)-(p0x,p0y))
    (x1, y1) = (p1x,p1y)(1-t) + t(p2x, p2y) = (p1x, p1y) + t((p2x,p2y)-(p1x,p1y))
   */
  void setLineCoords() {
    float[] xy0, xy1;
    
    // for (each line) 
    for (int j = 0; j < this.Nlines; j++) {
      xy0 = getCoords(this.t[j]); // (x0, y0)
      xy1 = getCoords(this.t[j]+1.0); // (x1, y1)
      this.Lines[j].move(xy0[0], xy0[1], xy1[0], xy1[1]);
    }
  }
  
  void updateTime() {
    for (int j = 0; j < this.Nlines; j++) {
      this.t[j] += this.dt;
      if (this.t[j] > this.Nvtx-2) {
        this.t[j] = this.t[j] % (this.Nvtx-2);
      }
    }
  }

  void resetLines() {
    this.initTimes();
    this.createLines();
  }

  void setColourPalette(color[] c) {
    for (int j = 0; j < this.Nlines; j++) {
      this.Lines[j].setLineColor(c[j]);
    }
  }
  void setColourPalette(String c) {
    if (c.toLowerCase().equals("rainbow")) {
      colorMode(HSB);
      for (int j = 0; j < this.Nlines; j++) {
        this.Lines[j].setLineColor(color(j/float(this.Nlines)*255, 255, 255));
      }
      colorMode(RGB);
    } else {
      colorMode(HSB);
      for (int j = 0; j < this.Nlines; j++) {
        this.Lines[j].setLineColor(color(0, 127.5 + 127.5*sin(2*PI*j/float(this.Nvtx)), 255));
      }
      colorMode(RGB);
    }
  }
  void setColourPalette() {
    this.setColourPalette("rainbow");
  }
    
  // methods to change track appearance
  void setVtxWidth(float vw) {
    vtxWidth = vw;
  }
  void setVtxFill(color vf) {
    vtxFill = vf;
  }
  void setTrackWidth(float tw) {
    trackWidth = tw;
  }
  void setTrackStroke(color ts) {
    trackStroke = ts;
  }
  
}

class Line {
  float x0, y0, x1, y1; // current position
  color LineColor = color(0, 0, 0, 255);
  float LineWidth = 2.0;

  Line (float x0_, float y0_, float x1_, float y1_) {
    x0 = x0_;
    y0 = y0_;
    x1 = x1_;
    y1 = y1_;
  }

  void display() {
    stroke(LineColor);
    strokeWeight(LineWidth);
    line(x0, y0, x1, y1);
  }

  void setStrokeWeight(float lw) {
    LineWidth = lw;
  }
  void setLineColor(color lc) {
    this.LineColor = lc;
  }
  void bump(float dx0, float dy0, float dx1, float dy1) {
    x0 += dx0;
    y0 += dy0;
    x1 += dx1;
    y1 += dy1;
  }
  void move(float x0_, float y0_, float x1_, float y1_) {
    x0 = x0_;
    y0 = y0_;
    x1 = x1_;
    y1 = y1_;
  }
}
