import org.openkinect.*;
import org.openkinect.processing.*;

int sW = 640;
int sH = 480;
int fps = 30;
int sWbutton = 240;
int sHbutton = 180;
int translateX = 200;
int translateY = 300;

Button bob, mary,louise;
PFont degFont;
int degFontSize = 50;
float deg = 0;  // orig 15, goes -30 to 30
boolean firstRun = true;

//--Kinect sectup
Kinect kinect;
boolean depth = true;
boolean rgbSwitch = false;
boolean ir = false;
boolean process = false;
int[] depthArray;
int pixelCounter = 1;
PImage displayImg;
int maxDepthValue = 1040;  // full range 0-2047, rec'd 530-1040
int minDepthValue = 530; 
//--

void setup() {
  size(sW,sH);
  frameRate(fps);
  smooth();
  displayImg = createImage(sW,sH,RGB);
  bob = new Button((sWbutton/2)-75,sHbutton/1.5,50,color(200,50,0),18,-30);
  mary = new Button(sWbutton/2,sHbutton/1.5,50,color(0,50,200),18,0);
  louise = new Button((sWbutton/2)+75,sHbutton/1.5,50,color(50,200,0),18,15);
  initKinect();
  degFont = createFont("Arial",degFontSize);
}

void draw() {
  background(0);
  depthArray = kinect.getRawDepth();
  imageProcess();
  image(displayImg,-4,0);
  fill(255);
  textFont(degFont,int(degFontSize/4));
  text(int(frameRate)+" fps",width-30,20);
  translate(translateX,translateY);
  fill(135,135,155,200);
  rect(0,0,sWbutton,sHbutton);
  bob.update();
  mary.update();
  louise.update();
  if(!firstRun){
  fill(0);
  textFont(degFont,degFontSize);
  text(int(deg),sWbutton/2,(sHbutton/2)-degFontSize);
  kinect.tilt(deg);
  //exit();
  }else{
  fill(0);
  textFont(degFont,degFontSize);
  text("?",sWbutton/2,(sHbutton/2)-degFontSize);
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
    if(hitDetect(mouseX,mouseY,0,0,posX+translateX,posY+translateY,sizeXY,sizeXY)) {
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

void imageProcess() {
  for(int i=0;i<depthArray.length;i++) {
    float q = map(depthArray[i],minDepthValue,maxDepthValue,255,0);
    depthArray[i] = color(q);
  }
  displayImg.pixels = depthArray;
  displayImg.updatePixels();
  //displayImg.filter(GRAY);
  //displayImg.filter(INVERT);
}

void initKinect() {
  kinect = new Kinect(this);
  kinect.start();
  kinect.enableDepth(depth);
  kinect.enableRGB(rgbSwitch);
  kinect.enableIR(ir);
  kinect.processDepthImage(process);
  //kinect.tilt(deg);
}

void stop() {
  kinect.quit();
  super.stop();
  exit();
}

