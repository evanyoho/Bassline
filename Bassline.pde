// File attributes
final String FILENAME = "test.txt";
final int METADATA_COUNT = 4; // needs work
String artist; // metadata fields
String song;
int tempo;
float delay;

// Environment attributes
final int partitions = 8; 
int textFadeDelay = 300;
int textStartColor = 255;
PFont artistFont;
PFont songFont;

// Bassline attributes
BLine bline;

final int G_OFFSET = 15;
final int D_OFFSET = 10;
final int A_OFFSET = 5;
final int E_OFFSET = 0;

final int pColor = 255; // project color
final int pAlpha = 200; // project alpha
final int trackerAlpha = 230;

int startPos;
int lowestNote;
int highestNote;
int totalSteps;
int borderHeight;
int stepDist;
String[] tabLines;

// debug
int gridColor = 0;
final int debugSize = 5000; 
final int debugLength = 1000;
float speed = 1;
boolean looping = true; // for pause

void setup() {
  size(1280, 720);
  frameRate(60);
  startPos = 3/2*width;
  songFont = createFont("Arial", width/36, true); // scale font size to screen height
  artistFont = createFont("Arial", width/42, true);
  
  loadMetadata();
  getBounds();

  // required steps between low and high note
  totalSteps = highestNote - lowestNote;
  borderHeight = height/partitions;
  stepDist = (height - 2 * borderHeight) / totalSteps;
  
  initializeBLine();
}

void draw() {
  background(0);
  
  // drawing artist and song, fades
  if (textFadeDelay != 0) {
    textFadeDelay--;
  } else {
    if (textStartColor > 0) {
      textStartColor -= 5;
    }
  }

  textFont(songFont);
  fill(textStartColor);
  text(song, 10, 30);
  textFont(artistFont);
  text(artist, 10, 60);

  // defining boundaries
  stroke(gridColor); // set to 0 or 255
  line(width/2, 0, width/2, height); // mid line
  line(0, height*1/partitions, width, height*1/partitions); // top line
  line(0, height*7/partitions, width, height*7/partitions); // bottom line

  // grid debug lines
  for (int i = 0; i < totalSteps; i++) {
    line(0, borderHeight + i * stepDist, width, borderHeight + i * stepDist);
  }
  bline.update();

  // debugging
  fill(255);
  textAlign(LEFT, BOTTOM);
  text(speed, borderHeight/2, height-borderHeight);
}

void initializeBLine() {
  Note[] notes;
  Connector[] Connectors = new Connector[0];
  Connector Connector;
  Tracker tracker;
  
  notes = tabToNotes();
  
  // generate connecting lines
  for (int i = 0; i < notes.length - 1; i++) {
    Connector = new Connector(notes[i].x, notes[i].y, notes[i+1].x, notes[i+1].y); // Connector(int x1, int y1, int x2, int y2)
    Connectors = (Connector[])append(Connectors, Connector);
  }

  // generate initial tracker
  tracker = new Tracker(notes[0].x, notes[0].y, notes[0].size, notes[0].size, pColor);

  // BLine(Connector[] lines, Note[] notes, Tracker tracker, int speed, int pColor)
  bline = new BLine(Connectors, notes, tracker, speed, pColor);
}

// Note constructor = Note(int x, int y, int size, int pColor, int pAlpha)
Note[] tabToNotes() {

  Note[] notes = new Note[0];
  Note note;
  int xPos;
  int yPos;
  
  String string_G = tabLines[0];
  String string_D = tabLines[1];
  String string_A = tabLines[2];
  String string_E = tabLines[3];

  String[] measuresOfG = shorten(split(string_G, '|'));
  String[] measuresOfD = shorten(split(string_D, '|'));
  String[] measuresOfA = shorten(split(string_A, '|'));
  String[] measuresOfE = shorten(split(string_E, '|'));

  // remove string label ("G", "D", "A", or "E")
  measuresOfG = reverse(shorten(reverse(measuresOfG)));
  measuresOfD = reverse(shorten(reverse(measuresOfD)));
  measuresOfA = reverse(shorten(reverse(measuresOfA)));
  measuresOfE = reverse(shorten(reverse(measuresOfE)));

  int measureCount = measuresOfG.length;
  for(int i = 0; i < measureCount; i++) {
    
    // remove leading formatting dash from each string of each measure
    String measureG = measuresOfG[i].substring(1);
    String measureD = measuresOfD[i].substring(1);
    String measureA = measuresOfA[i].substring(1);
    String measureE = measuresOfE[i].substring(1);
  
    // traverse each measure and calculate note xPos and yPos
    int measureLength = measureG.length();
    for(int j = 0; j < measureLength; j++) {
      xPos = 0;
      yPos = 0; // -48 to convert ascii to decimal
      if(measureG.charAt(j) >= 48 && measureG.charAt(j) <= 57) {
        // calcXPos(Note[] notes, int measureCount, int posInMeasure, int measureSize)
        xPos = calcXPos(notes, i, j, measureLength);
        // calcYPos(Note[] notes, int fret, int offset)
        yPos = calcYPos(notes, measureG.charAt(j), G_OFFSET);
        
      } else if(measureD.charAt(j) >= 48 && measureD.charAt(j) <= 57) {
        xPos = calcXPos(notes, i, j, measureLength);
        yPos = calcYPos(notes, measureD.charAt(j), D_OFFSET);
        
      } else if(measureA.charAt(j) >= 48 && measureA.charAt(j) <= 57) {
        xPos = calcXPos(notes, i, j, measureLength);
        yPos = calcYPos(notes, measureA.charAt(j), A_OFFSET);
        
      } else if(measureE.charAt(j) >= 48 && measureE.charAt(j) <= 57) {
        xPos = calcXPos(notes, i, j, measureLength);
        yPos = calcYPos(notes, measureE.charAt(j), E_OFFSET);
      }
      
      // xPos default value is 0, updated when note is found
      if(xPos != 0) {
        note = new Note(xPos, yPos, 0, pColor, pAlpha); // noteSize default 0, updated with generateSizes()
        notes = (Note[])append(notes, note);
      }
    }
  }
  
  generateSizes(notes);
  
  // debugging
  for(int i = 0; i < notes.length; i++) {
    //println(i + "\t" + notes[i].x + "\t" + notes[i].y + "\t" + notes[i].size);
  }
  
  return notes;
}

int calcXPos(Note[] notes, int measureCount, int posInMeasure, int measureSize) {
  int xPos;
  if(notes.length == 0) {
    xPos = startPos;
  } else {
    xPos = startPos + 30*measureSize*measureCount + 30*posInMeasure;
  }
  return xPos;
}

int calcYPos(Note[] notes, int fret, int offset) {
  int yPos = height - (borderHeight + (fret + offset - lowestNote - 48)*stepDist); // origin top left
  return yPos;
}

void generateSizes(Note[] notes) {
  // sort notes based on x coordinate, smallest to largest (default pSort)
  Note[] sorted = new Note[notes.length];
 
  int size;
  int dist;
  for (int i = 0; i < notes.length; i++) {
    if (i != notes.length-1) {
      dist = notes[i].x - notes[i+1].x;
      notes[i].size = dist;
      
    } else {
      notes[i].size = notes[i-1].size;
    }
  }
}

void loadMetadata() {

  String[] lines = loadStrings(FILENAME);
  for (int i = 0; i < METADATA_COUNT; i++) {  // traverse lines in text file and parse
    String[] line = splitTokens(lines[i]);
    String[] infos = new String[0];

    for (int j = 0; j < line.length; j++) {
      if (j != 0) {
        infos = append(infos, line[j]);
      }
    }
    
    lines[i] = join(infos, " ");
  }
  
  artist = lines[0];
  song = lines[1];
  tempo = Integer.parseInt(lines[2]);
  delay = float(lines[3]);
  // other metadata would go here, and METADATA_COUNT would be updated
}

void getBounds() {
  String[] lines = loadStrings(FILENAME);
  tabLines = new String[0];
  for (int i = METADATA_COUNT + 1; i < lines.length; i++) { // traverse through tab part of text file
    if (lines[i].charAt(1) == '|') {
      tabLines = append(tabLines, lines[i]);
    }
  }

  lowestNote = 0;
  highestNote = 0;  

  int[] notes = new int[0];
  for (int i = 0; i < tabLines.length; i++) { // traverse each line
    char[] currentString = tabLines[i].toCharArray();

    for (int j = 0; j < currentString.length; j++) { // traverse each char in the current line
      char currentChar = currentString[j];
      if (currentChar > 48 && currentChar < 57) { // test if tabbed note is between 0-9
        if (i == 0) {
          notes = append(notes, (int)currentChar + G_OFFSET - 48);
        } else if (i == 1) { 
          notes = append(notes, (int)currentChar + D_OFFSET - 48);
        } else if (i == 2) {
          notes = append(notes, (int)currentChar + A_OFFSET - 48);
        } else {
          notes = append(notes, (int)currentChar + E_OFFSET - 48);
        }
      }
    }
  }

  lowestNote = min(notes);
  highestNote = max(notes);
}

// for debugging
void keyPressed() {
  if (key == CODED) {
    if (keyCode == RIGHT) {
      speed++;
    } else if (keyCode == LEFT) {
      speed--;
    } else if (keyCode == DOWN) {
      if (looping) {
        noLoop();
        looping = false;
        text("paused", borderHeight/2, height - borderHeight/2);
      } else {
        loop();
        looping = true;
      }
    } else if (keyCode == UP) {
      if (gridColor == 255) {
        gridColor = 0;
      } else {
        gridColor = 255;
      }
    }
  }
}
