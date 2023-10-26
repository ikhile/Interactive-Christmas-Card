// NOTE
// audio files must be run through audition and re-saved as wav to work

import processing.sound.*;

// SCALING DOWN
float scale;
float unscale;
int scaleValue = 1;

// START SCREEN
float      startRotate = 0;
boolean    started     = false;
boolean    swingLeft   = true;
boolean    btnClicked  = false;

// SONGS
SoundFile  bells;
SoundFile  currentSong;
int        numSongs;
int        millisAtStart;
int        millisOnPlay;
int        currentSongIndex;
String     currentTitle;
String     currentArtist;
String     songFiles[];
boolean    isPlaying  = false;
boolean    autoplayOn = false;
StringList songFilesTemp;

// COLOURS                        0 red bg             1 gold/red/green      2 blue/white          
color      textColour[]       = { color(255),          color(164, 26, 2),    color(255)           };
color      skipColour[]       = { color(255),          color(8, 92, 43),     color(189, 226, 255) };
color      playColour[]       = { color(255, 200, 69), color(164, 26, 2),    color(255)           };
color      starColour[]       = { color(255, 200, 69), color(248, 214, 78),  color(189, 226, 255) }; // old gold star color(212, 175, 55)
boolean    fillStand[]        = { true,                true,                 false                };
color      treeStandFill[]    = { color(128, 80, 32),  color(128, 80, 32),   color(232, 245, 255) };
color      treeTopColour[]    = { color(9, 153, 86),   color(9, 153, 86),    color(255)           };
color      treeBaseColour[]   = { color(8, 92, 43),    color(8, 92, 43),     color(232, 245, 255) };
color      treeStandStroke[]  = { color(77, 40, 2),    color(77, 40, 2),     color(189, 226, 255) };
String     bgNames[]          = { "red bg",            "gold 2 bg",          "blue bg"            };
String     lights1Names[]     = { "redwhite1",         "redgreen1",          "bluewhite1"         };
String     lights2Names[]     = { "redwhite2",         "redgreen2",          "bluewhite2"         };

int        colourIndex = 1;
int        numColourSchemes = textColour.length;
PImage     bg[] = new PImage[numColourSchemes];
color      buttonColours[] = { color(66, 201,  73), color(66, 193, 255), color(0, 0, 255), color(142, 28, 255), color(227, 0, 0), color(255, 221, 0) };
      

// VISUALISER
FFT        fft;
int        bands = 128;
float      spectrum[] = new float[bands];
float      spectrumFire[] = new float[64];
int        vary;
int        gapT = 8;
int        gapF = 6;
int        base = 1450;
int        maxHeight = 550;
float      line, yellowLine, redLine, lOrangeLine;

// LIGHTS
int        flashInt    = 30;
boolean    flashOn     = true;
boolean    showLights1 = true;
PImage     lights1[]   = new PImage[numColourSchemes];
PImage     lights2[]   = new PImage[numColourSchemes];

// STAR
float      starRotate  = 0;
float      starScale   = 0.9;
boolean    incStar     = true;
boolean    starCW      = true;
Amplitude  amp;

// FONTS
PFont      titleFont;
PFont      artistFont;
PFont      titleFontSmall;
int        titleYTree  = 315;
int        artistYTree = 375;
int        titleYFire  = 185;
int        artistYFire = 245;

// SNOW
int        minSize     = 5;
int        maxSize     = 20;
int        minSpeed    = 5;
int        maxSpeed    = 12;
int        numSnow     = 700;
int        snowX[]     = new int[numSnow];
int        snowY[]     = new int[numSnow];
int        snowSize[]  = new int[numSnow];
int        snowSpeed[] = new int[numSnow];

// FIREPLACE
PImage     bow;
PImage     garland;
PImage     fireIcon;
PImage     treeIcon;
PImage     fireplace;
color      red      = color(184, 52, 0);
color      orange   = color(210, 95, 21);
color      yellow   = color(242, 189, 125);
color      lOrange  = color(244, 153, 43);
boolean    treeMode = true;

void setup() {
  //int w = int(1700 * scaleValue);
  
  size(986, 986);
  //fullScreen();
  textAlign(CENTER);
  
  scale = float(width) / float(1700);
  unscale = 1 / scale;
  base *= scale;
  println(scale + " " + unscale);
  
  // songs - load and shuffle
  songFilesTemp = new StringList();
  songFilesTemp.append(listFileNames(dataPath("music")));
  songFilesTemp.shuffle();
  songFiles = songFilesTemp.array();
  numSongs = songFiles.length;
  currentSongIndex = int(random(numSongs));
  bells = new SoundFile(this, "bells.wav");
  
  // fonts
  titleFont = createFont("fonts\\GreatVibes.ttf", 110 * scale);
  titleFontSmall = createFont("fonts\\GreatVibes.ttf", 95 * scale);
  artistFont = createFont("fonts\\SourceSansPro-Regular.ttf", 45 * scale);
  
  // images
  bow = loadImage("bow.png");
  garland = loadImage("garland.png");
  treeIcon = loadImage("tree-emoji.png");
  fireIcon = loadImage("fire-emoji.png");
  fireplace = loadImage("fireplace.png");
  for (int i = 0; i < numColourSchemes; i++) { bg[i] = loadImage("bg smaller\\" + bgNames[i] + ".png"); }
  for (int i = 0; i < numColourSchemes; i++) { lights1[i] = loadImage("lights\\" + lights1Names[i] + ".png"); }
  for (int i = 0; i < numColourSchemes; i++) { lights2[i] = loadImage("lights\\" + lights2Names[i] + ".png"); }
  
  // snow
  for (int i = 0; i < numSnow; i++) {
    snowX[i] = int(random(0, width));
    snowY[i] = int(random(-height, height));
    snowSize[i] = int(random(minSize, maxSize));
    snowSpeed[i] = int(random(minSpeed, maxSpeed));
  }

}

void draw() { 
  //scale(scale);
  if (!started) { startScreen(); snow(); }
  else {
    
    // background
    background(treeMode ? bg[colourIndex] : fireplace); 
    //background(bg[colourIndex]);
    //image(treeMode ? bg[colourIndex] : fireplace, 0, 0, 850, 850);
    
  
    // autoplay - turns on 10s after pressing play/skipping song
    if (!autoplayOn && millis() - millisOnPlay >= 10000) { autoplayOn = true; }
    if (autoplayOn && !currentSong.isPlaying() && isPlaying) { autoplay(); }
    
    // song title  
    //scale(scale);

    fill(treeMode ? textColour[colourIndex] : 255);
    textFont(currentTitle.length() >= 40 ? titleFontSmall : titleFont);
    text(currentTitle, width / 2, treeMode ? titleYTree * scale : titleYFire * scale);
    textFont(artistFont);
    text(currentArtist.toUpperCase(), width / 2, treeMode ? artistYTree * scale : artistYFire * scale);
    
    // music buttons
    noFill();
    strokeWeight(7 * scale);
    // back
    stroke(treeMode ? skipColour[colourIndex] : 255);
    triangle(70 * scale, height - 100 * scale, 120 * scale, height - 130 * scale, 120 * scale, height - 70 * scale);
    quad(120 * scale, height - 110 * scale, 160 * scale, height - 135 * scale, 160 * scale, height - 65 * scale, 120 * scale, height - 90 * scale);
    // skip
    triangle(370 * scale, height - 100 * scale, 320 * scale, height - 130 * scale, 320 * scale, height - 70 * scale);
    quad(320 * scale, height - 110 * scale, 280 * scale, height - 135 * scale, 280 * scale, height - 65 * scale, 320 * scale, height - 90 * scale);
    // play/pause
    if (treeMode) stroke(playColour[colourIndex]);
    if (isPlaying) {
      rect(190 * scale, height - 140 * scale, 23 * scale, 81 * scale);
      rect(228 * scale, height - 140 * scale, 23 * scale, 81 * scale);    
    } else triangle(250 * scale, height - 100 * scale, 200 * scale, height - 140 * scale, 200 * scale, height - 60 * scale);
        
    if (treeMode) {
      //fire mode button
      image(fireIcon, width - 150 * scale, height - 153 * scale, 100 * scale, 100 * scale);
      
      // click here label
      if (!btnClicked && millis() - millisAtStart >= 20000 && millis() - millisAtStart < 45000) startLabel();
      
      // colour button
      noStroke();
      for (int i = 0; i < 6; i++) {
        fill(buttonColours[i]);
        arc(width - 220 * scale, height - 100 * scale, 85 * scale, 85 * scale, radians(i * 60), radians((i + 1) * 60));
      }
      
      // tree stand
      stroke(treeStandStroke[colourIndex]);
      if (fillStand[colourIndex]) fill(treeStandFill[colourIndex]);
      else noFill();
      quad(width / 2 - 65 * scale, height - 204 * scale, width / 2 + 65 * scale, height - 204 * scale, width / 2 + 40 * scale, height - 80 * scale, width / 2 - 40 * scale, height - 80 * scale);
      
      // visualiser
      visualiseTree();  
      
      // star
      pushMatrix(); translate(width / 2, 525 * scale);
      noStroke(); fill(starColour[colourIndex]);
      // scale steadily
      /* scale(starScale); rotate(radians(starRotate));
      if (isPlaying) {
        if (starScale >= 1 || starScale <= 0.875) incStar = !incStar;
        starScale = incStar ? starScale + 0.0025 : starScale - 0.0025;
        if (starRotate >= 5 || starRotate <= -5) starCW = !starCW;
        starRotate = starCW ? starRotate + 0.06 : starRotate - 0.06;
      } */
      // scale with amplitude
      if (currentSong.isPlaying()) { scale(map(amp.analyze(), 0, 1, 0.9, 1.35)); }
      triangle(-100 * scale, -65 * scale, 100 * scale, -65 * scale, 0, 120 * scale);
      triangle(-100 * scale, 65 * scale, 100 * scale, 65 * scale, 0, -120 * scale);
      popMatrix();
      
      // lights
      if (flashOn && frameCount % flashInt == 0) showLights1 = !showLights1;
      image(showLights1 ? lights1[colourIndex] : lights2[colourIndex], 0, 0, width, height);
      
      // snow
      if (colourIndex == 2) { snow(); }

    } else if (!treeMode) {
      
      visualiseFire();
      image(garland, 0, 0, width, height);
      image(bow, 0, 0, width, height);
      image(treeIcon, width - 160 * scale, height - 163 * scale, 110 * scale, 110 * scale);
      
    }//if !treeMode 
  }//else (if !started)
}//draw

void keyPressed() {
  if (started) {
    if      (keyCode == RIGHT)  skip(true);
    else if (keyCode == LEFT)   skip(false);
    else if (key     == ' ')    playPause();
    else if (keyCode == ENTER)  changeColour();
  }
}

void mousePressed() {
  scale(scale);

  if (!started) {
    bells.stop(); isPlaying = true; setSong(); started = true; millisAtStart = millis(); millisOnPlay = millis(); numSnow = 400;
  } else if (treeMode && mouseX >= width - 265 * scale && mouseX <= width - 175  * scale && mouseY >= height - 173  * scale && mouseY <= height - 57 * scale) {
    changeColour();
    btnClicked = true;
  } else if (mouseX >= width - 160 * scale && mouseX <= width - 50  * scale && mouseY >= height - 163 * scale && mouseY <= height - 53 * scale) {
    treeMode = !treeMode;
    btnClicked = true;
  }  else if (mouseX >= 187 * scale && mouseX <= 264 * scale && mouseY >= height - 144 * scale && mouseY <= height - 55 * scale) {
    playPause();
  } else if (mouseX >= 277 * scale && mouseX <= 373 * scale && mouseY >= height - 141 * scale && mouseY <= height - 58 * scale) {
    skip(true);
  } else if (mouseX >= 66 * scale && mouseX <= 165 * scale && mouseY >= height - 141 * scale && mouseY <= height - 58 * scale) {
    skip(false);
  } 
}

void playPause() {
  if (isPlaying) { currentSong.pause(); isPlaying = false; flashOn = false; }
  else           { currentSong.play();  isPlaying = true;  flashOn = true; analyseFreq(); analyseAmp(); }
}

void skip(boolean forward) {
  currentSong.stop();
  autoplayOn = false;
  millisOnPlay = millis();
  if (forward) {  currentSongIndex = currentSongIndex < (numSongs - 1) ? (currentSongIndex + 1) : 0; } 
  else if (!forward) { currentSongIndex = currentSongIndex > 0 ? currentSongIndex - 1 : numSongs - 1; }
  setSong();
}

void autoplay() {
  currentSongIndex++;
  if (currentSongIndex >= numSongs) currentSongIndex = 0;
  setSong();
}

void setSong() {
  if (currentSong != null) currentSong.stop();
  
  currentSong = new SoundFile(this, "music\\" + songFiles[currentSongIndex]);
  String[] songSplit = splitTokens(songFiles[currentSongIndex], "-.");
  currentTitle = trim(songSplit[0]);
  currentArtist = trim(songSplit[1]);
  
  if (currentTitle.equals("Rudolph The Red Nosed Reindeer")) { currentTitle = "Rudolph the Red-Nosed Reindeer"; }
  else if (currentTitle.equals("Donde Esta Santa Claus")) { currentTitle = "¿Dónde Está Santa Claus?"; }
  
  if (isPlaying) { currentSong.play(); flashOn = true; analyseFreq(); analyseAmp(); }
}

void changeColour() {
  if (colourIndex < numColourSchemes - 1) { colourIndex++; }
  else { colourIndex = 0; }
}

void analyseFreq() {
  fft = new FFT(this, bands);
  fft.input(currentSong);
}

void analyseAmp() {
  amp = new Amplitude(this);
  amp.input(currentSong);
}

void visualiseTree() {
  
  fft.analyze(spectrum);
  strokeWeight(7 * scale);
  pushMatrix();
  translate(0, height - 252);
  //stroke(black);
  
  for (int i = 0; i < spectrum.length - 12; i++) {
    float lerp = map(i, 0, spectrum.length - 1, 0, 1);
    color col = lerpColor(treeBaseColour[colourIndex], treeTopColour[colourIndex], lerp);
    stroke(col);
    if (isPlaying) {
      vary = int(random(-85, 85));
      line(width / 2, spectrum.length - (i * gapT * scale), constrain(width / 2 + map(spectrum[i], 0, 0.5, 0, width), 0, width - (width / 12) + vary), spectrum.length - (i * gapT * scale));
      line(width / 2, spectrum.length - (i * gapT * scale), constrain(width / 2 - map(spectrum[i], 0, 0.5, 0, width), width / 12 - vary, width), spectrum.length - (i * gapT * scale));
    } else { point(width / 2, spectrum.length - (i * gapT * scale)); }
  }//for loop

  popMatrix();
  
}//visualiseTree();

void visualiseFire() {
  fft.analyze(spectrumFire);
  strokeWeight(6 * scale);
  //maxHeight *= scale;
  
  for (int i = 0; i < spectrumFire.length; i++) {
    if (isPlaying) {
      line = map(spectrumFire[i], 0, 1, 0, 2000 * scale);
      redLine = line * 1.25;
      yellowLine = line / 4;
      lOrangeLine = yellowLine * 2;
      line = constrain(line, 0, maxHeight * scale + int(random(-50, 20)));
      redLine = constrain(redLine, 0, maxHeight * scale * 1.25 + int(random(-50, 20)));
      yellowLine = constrain(yellowLine, 0, maxHeight * scale * 2 / 3 + int(random(-10, 10)));
      lOrangeLine = constrain(lOrangeLine, 0, maxHeight * scale / 2 + int(random(-10, 10)));
          
      stroke(red);
      line(width / 2 + i * gapF * scale, base, width / 2 + i * gapF * scale, base - redLine);
      line(width / 2 - i * gapF * scale, base, width / 2 - i * gapF * scale, base - redLine);
      
      if (i <= spectrumFire.length * 0.95) {
        stroke(orange);
        line(width / 2 + i * gapF * scale, base, width / 2 + i * gapF * scale, base - line);
        line(width / 2 - i * gapF * scale, base, width / 2 - i * gapF * scale, base - line);
      }
      
      if (i <= spectrumFire.length * 6 / 10) { // or / 2, or * 2/3
        stroke(lOrange);
        line(width / 2 + i * gapF * scale, base, width / 2 + i * gapF * scale, base - lOrangeLine);
        line(width / 2 - i * gapF * scale, base, width / 2 - i * gapF * scale, base - lOrangeLine);
      }
      
      if (i <= spectrumFire.length / 3) {
        stroke(yellow);
        line(width / 2 + i * gapF * scale, base, width / 2 + i * gapF * scale, base - yellowLine);
        line(width / 2 - i * gapF * scale, base, width / 2 - i * gapF * scale, base - yellowLine);
      } 
      
    } else {
      stroke(i < spectrumFire.length / 3 ? yellow : i < spectrumFire.length * 6 / 10 ? lOrange : i <spectrumFire.length * 0.95 ? orange : red); // this doesn't match live widths but oh well
      point(width / 2 + i * gapF * scale, base);
      point(width / 2 - i * gapF * scale, base);
    }// else
  }// for loop
}// visualiseFire()

String[] listFileNames(String folder) {
  File file = new File(folder);
  if (file.isDirectory()) { String fileNames[] = file.list(); return fileNames; }
  else { return null; }
}

void startScreen() {
  
  // bg
  background(255);
  //scale(scale);

  fill(playColour[1]);
  rectMode(CENTER); rect(width / 2, height / 2, 1645, 1645, 50); rectMode(CORNER);
    
  //bells
  if (!bells.isPlaying()) bells.loop();
  
  // transform
  pushMatrix();
  translate(width / 2, 40 * scale);
  rotate(radians(startRotate));
  
  // bauble
  fill(255); stroke(255);
  circle(0, height / 2, 500 * scale);
  
  // string and cap
  noFill(); strokeWeight(15 * scale);
  line(0, - 50 * scale, 0, height / 2 - 300 * scale);
  rect(0 - 60 * scale, height / 2 - 300 * scale, 120 * scale, 110 * scale, 10);
  
  // play symbol
  stroke(164, 26, 2); strokeWeight(20 * scale);
  triangle(- 105 * scale, (height / 2) - 130 * scale, - 105 * scale, (height / 2) + 125 * scale, 150 * scale, height / 2);
  
  // transform
  popMatrix();
  swingBauble();
  
}

void swingBauble() {
  if (startRotate >= 2.5 || startRotate <= -2.5) swingLeft = !swingLeft;
  startRotate = swingLeft ? startRotate + 0.1 : startRotate - 0.1;
}

void snow() {
  fill(255); noStroke();
  for (int i = 0; i < numSnow; i++) {
    circle(snowX[i], snowY[i], snowSize[i] * scale);
    snowX[i] += int(random(-2, 2));
    snowY[i] += !started ? snowSpeed[i] * scale : snowSpeed[i] * 2/3;
    if (snowY[i] > height + 20) { 
      snowX[i] = int(random(0, width));
      snowY[i] = 0 - height;
      snowSize[i] = int(random(minSize, maxSize));
      snowSpeed[i] = int(random(minSpeed, maxSpeed));
    }//if
  }//for
}//snow()

void startLabel() {
  fill(248, 214, 78);
  textFont(artistFont, 40 * scale); textLeading(45);  
  text("CLICK\nTHESE!", width - 162 * scale, height - 230 * scale);
}
