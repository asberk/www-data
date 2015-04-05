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
