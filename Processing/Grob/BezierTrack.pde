// insert methods to de-specialize Track by creating new sub-class
// BezierTrack

class BezierTrack extends Track {
  
  int Nlines; // number of lines on track
  Line[] Lines;
  
  // properties of movement
  float[] t; // "time" --- variable parametrizing track coord/s <x(t),y(t)> 
  float dt = .0025; // e.g., seconds. 
  
  
  

  
  BezierTrack(int Nvtx_, int Nlines_) {
    super(Nvtx_);
    this.Nlines = Nlines_;
    
    this.initTimes();
    this.createLines();    
  }
  
  BezierTrack() {
    this(10, 3);
  }
  
  // Use this when the locations of the track vertices are known
  BezierTrack (float[] vtx_, int Nlines_) {
    super(vtx_);
    this.Nlines = Nlines_;
    this.initTimes();
    this.createLines();
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

  void updateBezierTrack() {
    this.drawTrack();
    this.drawLines();
    this.updateTime();
    this.setLineCoords();
  }
  
}
