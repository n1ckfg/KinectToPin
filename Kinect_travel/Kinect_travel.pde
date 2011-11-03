import org.openkinect.*;
import org.openkinect.processing.*;

Button bob, mary,louise;
PFont degFont;
int degFontSize = 50;
float deg = 0;  // orig 15, goes -30 to 30
Kinect kinect;
boolean firstRun = true;

void setup() {
  size(240,180);
  smooth();
  bob = new Button((width/2)-75,height/1.5,50,color(200,50,0),18,-30);
  mary = new Button(width/2,height/1.5,50,color(0,50,200),18,0);
  louise = new Button((width/2)+75,height/1.5,50,color(50,200,0),18,15);
  kinect = new Kinect(this);
  kinect.start();
  degFont = createFont("Arial",degFontSize);
}

void draw() {
  background(135,135,155);
    bob.update();
  mary.update();
  louise.update();
  if(!firstRun){
  fill(0);
  textFont(degFont,degFontSize);
  text(int(deg),width/2,(height/2)-degFontSize);
  kinect.tilt(deg);
  //exit();
  }else{
  fill(0);
  textFont(degFont,degFontSize);
  text("?",width/2,(height/2)-degFontSize);
  }
}

void mouseReleased(){
    bob.degKinect();
  mary.degKinect();
  louise.degKinect();
}

class Button {
  float posX,posY,sizeXY;
  color offColor,hoverColor,clickColor,nowColor;
  PFont font;
  String label;
  int fontSize;
  boolean hovered=false;
  boolean clicked=false;
  float degLocal;

  Button(float x, float y, float s, color oc, int fs, float d) {
    posX = x;
    posY = y;
    sizeXY = s;
    offColor = oc;
    hoverColor = blendColor(offColor,color(40),ADD);
    clickColor = blendColor(offColor,color(120),ADD);
    nowColor = offColor;
    fontSize=fs;
    font = createFont("Arial",fontSize);
    label = ""+int(d);
    degLocal = d;
  }

  void update() {
    checkButton();
    drawButton();
    //degKinect();
  }

  void degKinect() {
    if(clicked) {
      firstRun=false;
      deg = degLocal;
    }
  }

  void checkButton() {
    if(hitDetect(mouseX,mouseY,0,0,posX,posY,sizeXY,sizeXY)) {
      if(!mousePressed) {
        hovered=true;
        clicked=false;
      } 
      else if(mousePressed) {
        hovered=true;
        clicked=true;
      }
    } 
    else {
      hovered=false;
      clicked=false;
    }
  }

  void drawButton() {
    ellipseMode(CENTER);
    noStroke();
    if(hovered&&!clicked) {
      nowColor = hoverColor;
    }
    else if(hovered&&clicked) {
      nowColor = clickColor;
    }
    else if(!hovered&&!clicked) {
      nowColor = offColor;
    }
    fill(0,10);
    ellipse(posX+2,posY+2,sizeXY,sizeXY);
    fill(nowColor);
    ellipse(posX,posY,sizeXY,sizeXY);
    fill(0);
    textFont(font,fontSize);
    textAlign(CENTER,CENTER);
    text(label,posX,posY-(fontSize/4));
  }

  boolean hitDetect(float x1, float y1, float w1, float h1, float x2, float y2, float w2, float h2) {
    w1 /= 2;
    h1 /= 2;
    w2 /= 2;
    h2 /= 2; 
    if(x1 + w1 >= x2 - w2 && x1 - w1 <= x2 + w2 && y1 + h1 >= y2 - h2 && y1 - h1 <= y2 + h2) {
      return true;
    } 
    else {
      return false;
    }
  }
}

void keyPressed(){
  firstRun=false;
if (keyCode==UP){
  if(deg<30){
    deg++;
  }
}
if (keyCode==DOWN){
  if(deg>-30){
    deg--;
  }
}
}

void stop() {
  kinect.quit();
  super.stop();
}

