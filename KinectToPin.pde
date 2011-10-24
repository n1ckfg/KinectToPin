import processing.opengl.*;
import oscP5.*;
import netP5.*;
import proxml.*;
import ddf.minim.*;

int sW = 640;
int sH = 480;
int fps = 24;
int counter = 0;
int counterMax = 400; //number of MocapFrames to record

Countdown countdown;

Minim minim;
OscP5 oscP5;
boolean found=false;

XMLInOut xmlIO;
proxml.XMLElement xmlFile;
proxml.XMLElement MotionCapture;
String xmlFileName = "mocapData.xml";

boolean limitReached = false;
boolean loaded = false;

String[] oscNames = {
  //~~~   complete list of working Joints, check updates at https://github.com/Sensebloom/OSCeleton  ~~~
  "head", "neck", "torso", "r_shoulder", "r_elbow", "r_hand", "l_shoulder", "l_elbow", "l_hand", "r_hip", "r_knee", "r_foot", "l_hip", "l_knee", "l_foot"
    //~~~
  //"r_hand","r_wrist","r_elbow","r_shoulder", "l_hand","l_wrist","l_elbow","l_shoulder","head","torso"
};

Data data;
int[] pinNums = new int[oscNames.length];
proxml.XMLElement[] oscXmlTags = new proxml.XMLElement[oscNames.length];
float posX, posY, posZ;

float[] x = new float[oscNames.length];
float[] y = new float[oscNames.length];
float[] z = new float[oscNames.length];
float depth = 200;
int circleSize = 50;

Button[] buttons = new Button[3];

boolean modePlay = true;
boolean modeRecord = false;
boolean modeExport = false;

//~~~

void setup() {
  size(sW, sH, OPENGL);
  frameRate(fps);
  ellipseMode(CENTER);
  minim = new Minim(this);
  countdown = new Countdown(8, 2);
  oscP5 = new OscP5(this, "127.0.0.1", 7110);
  buttons[0] = new Button(25, 20, 30, color(240, 10, 10), 12, "rec");
  buttons[1] = new Button(60, 20, 30, color(20, 200, 20), 12, "play");
  buttons[2] = new Button(95, 20, 30, color(50, 50, 200), 12, "save");
  xmlPlayerInit();
  xmlRecorderInit();
  flaePinInit();
}

//~~~


void draw() {
  if(modePlay){
  xmlPlayerUpdate(); 
  }
  if(modeRecord){
  xmlRecorderUpdate();
  }
  if(modeExport){
  flaePinUpdate();
  }
  buttonHandler();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void buttonHandler() {
  for (int i=0;i<buttons.length;i++) {
    buttons[i].checkButton();
    buttons[i].drawButton();
  }
  if(buttons[0].clicked){
    buttons[0].clicked=false;
    modePlay = false;
    modeRecord = true;
    modeExport = false;    
  }else if(buttons[1].clicked){
    buttons[1].clicked=false;
    modePlay = true;
    modeRecord = false;
    modeExport = false;    
  }else if(buttons[2].clicked){
    buttons[2].clicked=false;
    modePlay = false;
    modeRecord = false;
    modeExport = true;    
  }
}

void stop() {
  countdown.stop();
  minim.stop();
  super.stop();
  exit();
}

