class Countdown {

  //requires Minim

  AudioSnippet foo;

  int alphaNum = 150;
  int secStart, secBeep;
  int leaderCounter = 0;
  int leaderCounterMax, leaderCounterBeep;
  int leaderCircleSize = int(sW/2.2);
  float leaderX = sW/2;
  float leaderY = sH/2;
  boolean beep = false;
  boolean go = false;

  PFont font;
  int fontSize = int(leaderCircleSize * 0.9);

  Countdown(int ss, int sb) {
    secStart = ss;
    secBeep = sb;
    leaderCounterMax = secStart * fps;
    leaderCounterBeep = (secStart-secBeep) * fps;
    foo = minim.loadSnippet("24th blip sync pop.wav");
    font = createFont("Arial",fontSize);
  }

  void update() {
    if(!go) {
      rectMode(CORNER);
      fill(200,alphaNum);
      rect(0,0,sW,sH);
    }
    if(!beep) {
      noStroke();
      fill(255,alphaNum);
      ellipseMode(CENTER);
      ellipse(leaderX,leaderY,leaderCircleSize,leaderCircleSize);
      fill(0,alphaNum);
      textFont(font,fontSize);
      text(secStart-int(leaderCounter/fps),leaderX-(fontSize/3.8),leaderY+(fontSize/2.7));
      if(leaderCounter==leaderCounterBeep) { 
        foo.play();
        beep=true;
      }
    } 

    if(leaderCounter<leaderCounterMax) {
      leaderCounter++;
    } 
    else if(leaderCounter==leaderCounterMax) {
      go=true;
    }
  }

  void stop() {
    foo.close();
  }
}

