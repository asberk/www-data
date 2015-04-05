/*
  TODO: 

  * Display settings: bt_num, current number of lines, current
  vertex number (if editing vertex positions), current vertex
  position (if editing), etc.
  
  * Display track vertices on screen (as ellipses) once their positions have been selected. 

  * 
 */

/* 
   Counter to define current Mode
   0 = Nothing
   1 = "add vertex to Track" Mode: add vertices to new Track object
   2 = "add new Loop" Mode: 
 */
int Mode = 0;  // mode descriptions given above

// counters for indexing grobs
int bt_num = 0; // current BezierTrack
int gudp_num = 0; // current glowUDP

// Constants
final int MAX_GROBS = 20; // max number of grobs displayable on screen 
final int NUM_LINES = 12; // default number of lines for new Track. 
final int MAX_POINTS = 600; // max UDP length
final float MIN_MOVE = 3.0; // minimum distance between UDP vertices
final int MAX_MODES = 3;


// run-time variable
boolean busy = false; 

// 
float[] tmpvtx;
BezierTrack[] BT = new BezierTrack[MAX_GROBS];
glowUDP[] gUDP = new glowUDP[MAX_GROBS];


void setup() {
  //println("Startup successful.");
  size(1200, 800);
  background(255);

  // requires initialization. 
  for (int j = 0; j < MAX_GROBS; j++) {
    gUDP[j] = new glowUDP();
  }

}

void draw() {
  background(255);
  for (int j = 0; j < MAX_GROBS; j++) {
    if (BT[j] != null) {
      BT[j].updateBezierTrack();
      //      printCt("BT " + j + " exists.");
    }
    if (gUDP[j].exists) {
      gUDP[j].display();
      //      printCt("gUDP " + j + " exists.");

      if (gUDP[j].glowStatus) {
        gUDP[j].glow();
      }
    }
  }
}

void mouseClicked(MouseEvent event) {
  //  println("Mouse has been clicked");
  switch(Mode) {
  case 0: // do nothing
    //    println("Enter case 0");
    break;
  case 1: // BezierTrack Mode
    //    println("Enter case 1");
    busy = true;
    if (event.getButton()==LEFT) {
      tmpvtx = addBTVertex(tmpvtx);
    } else if (event.getButton() == RIGHT) {
      // do nothing for now. 
    }
    break;
  case 2: // glowUDP Mode
    //    println("Enter case 2");    
    break;
  }
}

void mousePressed() {
  //  println("Mouse has been pressed.");
  switch(Mode) {
  case 0:
    //    println("Enter case 0");
    break;
  case 1:
    //    println("Enter case 1");
    break;
  case 2:
    //    println("Enter case 2");
    busy = true;
    // start new path by adding point
    gUDP[gudp_num].addPoint(mouseX, mouseY);
    gudp_num = (gudp_num+1)%MAX_GROBS;
    break;
  }
}

void mouseDragged() {
  //  println("Mouse has been drag
  switch(Mode) {
  case 0:
    //    println("Enter case 0");
    break;
  case 1:
    //    println("Enter case 1");
    break;
  case 2:
    //    println("Enter case 2");
    // add points to path by dragging mouse
    //  println(gudp_num);
    if (gUDP[gudp_num].distToLast(mouseX, mouseY) > MIN_MOVE) {
      gUDP[gudp_num].addPoint(mouseX, mouseY);
    }
    break;
  }
}

void mouseReleased() {
  //  println("Mouse has been released.");
  switch(Mode) {
  case 0:
    //    println("Enter case 0");
    break;
  case 1:
    //    println("Enter case 1");
    break;
  case 2:
    //    println("Enter case 2");
    // finished drawing path; start glow. 
    gUDP[gudp_num].glowStatus = true;
    busy = false;
    break;
  }
}


void keyPressed(KeyEvent event) {
  if (key == CODED) {
    if (keyCode == RIGHT) {
      //      println("right arrow");
      switch (Mode) {
      case 0:
        break;
      case 1:
        break;
      case 2:
        gUDP[gudp_num].increaseHue();
        break;
      }
      
    } else if (keyCode == LEFT) {
      //      println("left arrow");
      switch (Mode) {
      case 0:
        break;
      case 1:
        break;
      case 2:
        gUDP[gudp_num].decreaseHue();
        break;
      }
      
    }
    
    if (keyCode == UP) {
      //      println("up arrow");
      switch (Mode) {
      case 0:
        break;
      case 1:
        break;
      case 2:
        gUDP[gudp_num].increaseSpeed();
        break;
      }

    } else if (keyCode == DOWN) {
      //      println("down arrow");
      switch (Mode) {
      case 0:
        break;
      case 1:
        break;
      case 2:
        gUDP[gudp_num].decreaseSpeed();
      }
      
    }
  } else {
    if (key =='\n' || key == '\r') {
      //      println("Enter key");
      switch (Mode) {
      case 0:
        break;
      case 1:
        if (tmpvtx != null && tmpvtx.length > 4) {
          /*
            if this happens, then the user has added enough points
            to create a Track, and has decided to finish adding
            track vertices.
          */
          int nvtx = tmpvtx.length/2;
          
          /*
            true: Track vertices form closed contour;
            false: Track vertices do not form closed contour
          */
          boolean closed = (dist(tmpvtx[0], tmpvtx[nvtx], tmpvtx[nvtx-1], tmpvtx[2*nvtx-1]) < 5);
          if (closed) {
            // constructor for closed Track
            
            // make new array for closed track
            // [i think this variable is local so we shouldn't have to clear it afterward?]
            float[] closed_vtx = new float[tmpvtx.length+2]; 
            // everything is the same...
            for (int j = 0; j < nvtx; j++) {
              closed_vtx[j] = tmpvtx[j];
              closed_vtx[j+nvtx+1] = tmpvtx[j+nvtx];
            }
            // except that the last two vertices of closed_vtx are
            // the first two vertices of tmpvtx (making a closed
            // loop)
            closed_vtx[nvtx-1] = tmpvtx[0];
            closed_vtx[nvtx] = tmpvtx[1];
            closed_vtx[nvtx+nvtx] = tmpvtx[nvtx];
            closed_vtx[nvtx+nvtx+1] = tmpvtx[nvtx+1];
            
            BT[bt_num] = new BezierTrack(closed_vtx, NUM_LINES);
            tmpvtx = null;
            bt_num = (1+bt_num)%MAX_GROBS;
          } else {
            // track is not closed loop. 
            
            //make new track
            BT[bt_num] = new BezierTrack(tmpvtx, NUM_LINES);
            // reset tmpvtx
            tmpvtx = null;
            // increase counter for BT 
            bt_num = (1+bt_num)%MAX_GROBS;
          }
        }
        busy = false;
        break;
      case 2:
        break;
      }
    } else if (key == ' ') {
      //      println("Space key. Previous mode: " + Mode + "; current mode: " + (1+Mode)%MAX_MODES);
      //      println(mousePressed==false);
      //      println(!busy);
      if (mousePressed == false && !busy) { // make sure we're not in the middle of something
        Mode = (1+Mode)%MAX_MODES;
        // code to handle changing from previous mode. 
      }
    }
  }
}


// code for adding a vertex to a list of BezierTrack vertices. 
float[] addBTVertex(float[] vtx_in) {
  int nvtx;
  float[] vtx_out;
  
  if (vtx_in == null) {
    nvtx = 0;
  } else {
    nvtx = vtx_in.length/2;
  }
  
  vtx_out = new float[2*nvtx + 2];

  for (int j = 0; j < nvtx; j++) {
    vtx_out[j] = vtx_in[j];
    vtx_out[j+nvtx+1] = vtx_in[j+nvtx];
  }
  vtx_out[nvtx] = mouseX;
  vtx_out[2*nvtx+1] = mouseY;

  return vtx_out;
}


void printCt(String msg, int N) {
  if ((frameCount%N)==0) {
    println(msg);
  }
}

void printCt(String msg) {
  printCt(msg, 250);
}
