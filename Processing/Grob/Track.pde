class Track {
  int Nvtx; // number of vertices, lines on track 
  float[] vtx; // vector of xcoords and y coords of vertices on track
  float[] sgmtLengths;
  
  float vtxWidth = 5.0; // width of ellipses marking track vertices
  color vtxFill = color(255, 0, 0); // fill color of vertices
  float trackWidth = 1.0; // width of track
  color trackStroke = color(190); // color of track

  public boolean showTrack;
  
  Track (int Nvtx_) {
    this.Nvtx = Nvtx_; // needs to be a lower bound on number of vertices. 
    
    this.vtx = setVtx(Nvtx);
    this.sgmtLengths = getSgmtLengths(vtx);

    this.showTrack = false;
  }

  Track() {
    this(10);
  }

  // Use this when the locations of the track vertices are known
  Track (float[] vtx_) {
    this.Nvtx = vtx_.length/2;
    this.vtx = vtx_;
    this.sgmtLengths = getSgmtLengths(this.vtx);

    this.showTrack = false;
  }

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
    // s *= trackLength; // re-map s from [0,1] to [0, trackLength]
    // // loop over segment lengths
    // for (int k = 0; k < Nvtx; k ++) {
    //   // find largest cumulative segment length that t is larger than 
    //   if (s >= sgmtLengths[k] && s < sgmtLengths[k+1]) {
    //     // by definition of getCoords, t is equal to the corresponding value of k,
    //     // plus the remaining fraction of the next segment: (s-sgmt_k)/(sgmt_k+1 - sgmt_k)
    //     t = k + (s - sgmtLengths[k])/(sgmtLengths[k+1]-sgmtLengths[k]);
    //     break; // found our value; exit loop
    //   } 
    // } // end loop over segment lengths

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
  




  // display track in output window
  void drawTrack() {
    if (this.showTrack) {
      stroke(trackStroke);
      strokeWeight(trackWidth);
      for (int j = 1; j < Nvtx; j++) {
        line(vtx[j-1], vtx[Nvtx+j-1], vtx[j], vtx[Nvtx+j]);
      }
      fill(vtxFill);
      noStroke();
      for (int j = 0; j < Nvtx; j++) {
        ellipse(vtx[j], vtx[Nvtx+j], vtxWidth, vtxWidth);
      }
    } // else 
      // do not display track
  }
    
  // methods to change track appearance
  void setVtxWidth(float vw) {
    this.vtxWidth = vw;
  }
  void setVtxFill(color vf) {
    this.vtxFill = vf;
  }
  void setTrackWidth(float tw) {
    this.trackWidth = tw;
  }
  void setTrackStroke(color ts) {
    this.trackStroke = ts;
  }

  void setShowTrack(boolean sT) {
    this.showTrack = sT;
  }
  
}
