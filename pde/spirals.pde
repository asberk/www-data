int NUM_ARMS; // number of arms of sprial
int NUM_DOTS; // number of dots on each arm
float ARM_ROTN; // amount that each arm rotates

int MAX_ARMS = 100;
int MAX_DOTS = 100;
float MAX_ARM_ROTN = 30*PI;

float dtheta = 0.1;

int W = 500; // display width

void setup() {
  size(W, W);
  background(255);
  noStroke();
  fill(0);
  
  NUM_ARMS = 1;
  NUM_DOTS = 1;
  ARM_ROTN = PI;
  
}

void draw() {
  background(255);
  NUM_ARMS = round(mouseX/float(width)*MAX_ARMS);
  NUM_DOTS = round(mouseY/float(height)*MAX_DOTS);

  if (keyPressed == true) {
    if (key == CODED) {
      if (keyCode == RIGHT && ARM_ROTN < MAX_ARM_ROTN) {
        ARM_ROTN += dtheta;
      } else if (keyCode == LEFT && ARM_ROTN > -MAX_ARM_ROTN) {
        ARM_ROTN -= dtheta;
      }
    }
  }
  
  
  drawSpiral(NUM_ARMS, NUM_DOTS, ARM_ROTN);
  
}

void drawSpiral(int NUM_ARMS, int NUM_DOTS, float ARM_ROTN) {
  pushMatrix();
  translate(width/2.0, width/2.0);
  for (int j = 0; j < NUM_ARMS; j++) {
    float phi = 2*PI*j/float(NUM_ARMS);
    for (float k = 0; k < NUM_DOTS; k++) {
      float r = k/float(NUM_DOTS);
      float R = r*width;
      float theta = r*ARM_ROTN;
      float circle_width = min(min(3*R/2.0, max(0, 2*PI*R/(2.0*NUM_ARMS))), R/float(NUM_DOTS));
      ellipse(R*cos(theta+phi), R*sin(theta+phi), circle_width, circle_width);
    }
  }
  popMatrix();
}
