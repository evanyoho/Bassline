class Tracker {
  int x;
  float y;
  float initialSize;
  float currentSize;
  int pColor;

  Tracker(int x, float y, float initialSize, float currentSize, int pColor) {
    this.x = x;
    this.y = y;
    this.initialSize = initialSize;
    this.currentSize = currentSize;
    this.pColor = pColor;
  }
  
  // update and redraw tracker
  void update() {
    if(this.x > width/2) { // draw with lead note
      this.x = bline.notes[0].x;
      this.y = bline.notes[0].y;
      stroke(pColor);
      fill(pColor, trackerAlpha);
      
    } else if (bline.notes[bline.notes.length-1].x < width/2) {
      stroke(0);
      noFill();
      
    } else {
      this.x = width/2;
      this.y = updateY();
      this.currentSize = updateSize();
      stroke(pColor);
      fill(pColor, trackerAlpha);
    }

    ellipse(this.x, this.y, this.currentSize, this.currentSize);
  }
  
  float updateY() {
    float yPos = this.y;
    if(bline.notes[bline.notes.length-1].x > width/2) {
      yPos = yPos + bline.DELTAY/(bline.DELTAX/speed);
    }
    return yPos;
  }
  
  float updateSize() {
    float size = bline.prevNote.size;  
    float totalHypo = sqrt(sq(bline.DELTAX) + sq(bline.DELTAY));
    float trackerToEnd = dist(width/2, this.y, bline.nextNote.x, bline.nextNote.y); // x1 y1 x2 y2
    float ratio = trackerToEnd/totalHypo; // ratio of remaining/total distance
    return size * ratio;
  }
}
