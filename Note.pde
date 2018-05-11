class Note {
  int x;
  int y;
  int size;
  int pColor;
  int pAlpha;

  // constructor
  Note(int x, int y, int size, int pColor, int pAlpha) {
    this.x = x;
    this.y = y;
    this.size = size;
    this.pColor = pColor;
    this.pAlpha = pAlpha;
  }
  
  // update and redraw notes
  void update(int index, float trackerY) {
    this.x -= speed; 
    if(bline.nextNote.x < width/2) { // calc new next, old next becomes new prev
      if(index != bline.notes.length - 1) {
        bline.prevNote = bline.nextNote;
        bline.nextNote = bline.notes[index + 1];
        bline.DELTAX = bline.nextNote.x - bline.prevNote.x;
        bline.DELTAY = bline.nextNote.y - trackerY;
      }
    }
    
    // CASE 3
    if(this.x > width*4/3) { // case 3: no draw
      noFill();
    } else {
      if(this.x < width/2) { // CASE 1
        noFill(); 
      } else { // CASE 2 
        fill(pColor, pAlpha);
      }
      stroke(pColor);
      ellipse(this.x, this.y, this.size, this.size);
    }
  }
}
