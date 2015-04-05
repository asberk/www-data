int NVertices = 25;
int NLines = 23*7; // for NVertices==25: 12 and 23*k, k\in\ints are aesthetically-pleasing choices. 
Track track;
int CURRENT_VTX = 0;

int[] keysPressed = new int[0];

void setup() {
  size(800, 600);
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

  //for (int j = 0; j < NmL; j++) {
  //myLines[j].display();
  //myLines[j].bump(2, 0, 2, 0);
  //}
  track.drawLines();
  track.updateTime();
  track.setLineCoords();
  //  track.bumpLines(); // wording... // deprecated

  // noLoop();

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
  
  // ** buggy ** 
  // for (int j = 0; j < keysPressed.length; j++) {
  //   if (keysPressed[j] == UP) {
  //     track.vtx[track.Nvtx + CURRENT_VTX] -= 5;
  //   } else if (keysPressed[j] == DOWN) {
  //     track.vtx[track.Nvtx + CURRENT_VTX] += 5;
  //   } else if (keysPressed[j] == LEFT) {
  //     track.vtx[CURRENT_VTX] -= 5;
  //   } else if (keysPressed[j] == RIGHT) {
  //     track.vtx[CURRENT_VTX] += 5;
  //   }
  // }
  
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
  // ** buggy **
  // if (key == CODED && (keyCode==UP||keyCode==DOWN||keyCode==LEFT||keyCode==RIGHT)) {
  //     int[] tmp = new int[keysPressed.length+1];
  //     for (int j = 0; j < tmp.length-1; j++) {
  //       tmp[j] = keysPressed[j];
  //     }
  //     tmp[tmp.length-1] = keyCode;
  //     keysPressed = tmp;
  // }
}

// ** buggy ** 
// void keyReleased() {
//     if (key == CODED && (keyCode==UP||keyCode==DOWN||keyCode==LEFT||keyCode==RIGHT)) {
//       int[] tmp = new int[keysPressed.length-1];
//       for (int j = 0; j < tmp.length; j++) {
//         tmp[j] = keysPressed[j+1];
//       }
//       keysPressed = tmp;
//   }

// }


// void mousePressed(MouseEvent event) {
//   if (event.getButton()==LEFT) {
//     track.Nlines += 1;
//     track.setLines();
//   } else if (event.getButton() == RIGHT) {
//     if (track.Nlines > 0) {
//       track.Nlines -= 1;
//       track.setLines();
//     }
//   }
// }
