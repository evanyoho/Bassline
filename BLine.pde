class BLine {
  Note[] notes;
  Connector[] Connectors; 
  Note note;
  Connector Connector;
  Tracker tracker;
  float speed;
  int pColor;
  
  Note prevNote;
  Note nextNote;
  float DELTAX;
  float DELTAY;
   
  // bassline (BLine) constructor  
  BLine(Connector[] Connectors, Note[] notes, Tracker tracker, float speed, int pColor) {
    this.Connectors = Connectors;
    this.notes = notes;
    this.tracker = tracker;
    this.speed = speed;
    this.pColor = pColor;
    
    prevNote = notes[0]; // initial values
    nextNote = notes[0];
  }
  
  // update and redraw notes, connecting lines, and tracker
  void update() {
    // ends the program
    if(notes[notes.length - 1].x < 0-width/2) {
      delay(6000);
      exit();
    }
    
    // update and redraw notes
    for(int i = 0; i < notes.length; i++) {
      notes[i].update(i, tracker.y); // pass index of current note
    }
    
    // update and redraw connecting lines
    for(Connector Connector : Connectors) {
      Connector.update();
    }
    
    // update and redraw tracker
    tracker.update();
  }
}
