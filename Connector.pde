class Connector {
  int x1;
  int y1;
  int x2;
  int y2;
  
  // constructor
  Connector(int x1, int y1, int x2, int y2) {
    this.x1 = x1;
    this.y1 = y1;
    this.x2 = x2;
    this.y2 = y2;
  }
  
  // update and redraw connecting lines
  void update() {
    this.x1 -= speed;
    this.x2 -= speed;
    stroke(pColor);
    line(this.x1, this.y1, this.x2, this.y2);
  }
}
