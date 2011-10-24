import processing.opengl.*;
import oscP5.*;
import netP5.*;
import proxml.*;
import ddf.minim.*;

int stageWidth = 640;
int stageHeight = 480;
int fps = 24;
int counter = 0;
int counterMax = 400; //number of MocapFrames to record

Countdown countdown;

Minim minim;
OscP5 oscP5;
boolean found=false;

XMLInOut xmlIO;
proxml.XMLElement xmlFile;
String xmlFileName = "mocapData.xml";

boolean limitReached = false;

String[] oscNames = {
//~~~   complete list of working Joints, check updates at https://github.com/Sensebloom/OSCeleton  ~~~
"head","neck","torso","r_shoulder","r_elbow","r_hand","l_shoulder","l_elbow","l_hand","r_hip","r_knee","r_foot","l_hip","l_knee","l_foot"
//~~~
//"r_hand","r_wrist","r_elbow","r_shoulder", "l_hand","l_wrist","l_elbow","l_shoulder","head","torso"
};
proxml.XMLElement[] oscXmlTags = new proxml.XMLElement[oscNames.length];

float[] x = new float[oscNames.length];
float[] y = new float[oscNames.length];
float[] z = new float[oscNames.length];
float depth = 200;
int circleSize = 50;

void setup() {
  size(stageWidth,stageHeight,OPENGL);
  frameRate(fps);
  minim = new Minim(this);
  countdown = new Countdown(8,2);
  oscP5 = new OscP5(this, "127.0.0.1", 7110);
  xmlInit();
  ellipseMode(CENTER);
}

void draw() {
  background(0);
  if(found) {
    fill(255,200);
    stroke(0);
    strokeWeight(5);
    for(int i=0;i<oscNames.length;i++) {
      pushMatrix();
      translate(width*x[i],height*y[i],(-depth*z[i])+abs(depth/2));
      ellipse(0,0,circleSize,circleSize);
      popMatrix();
    }
  } 
  if(countdown.go) {
    if(counter<counterMax) {
      xmlAdd();
      counter++;
    } 
    else {
      if(!limitReached) {
        limitReached = true;
        xmlSaveToDisk();
        println("saved file " + xmlFileName);
        stop();
      }
    }
  }
  countdown.update();
}

void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/joint") && msg.checkTypetag("sifff")) {
    found = true;
    for(int i=0;i<oscNames.length;i++) {
      if (msg.get(0).stringValue().equals(oscNames[i])) {
        x[i] = msg.get(2).floatValue();
        y[i] = msg.get(3).floatValue();
        z[i] = msg.get(4).floatValue();
      }
    }
  }
}

void xmlInit() {
  xmlIO = new XMLInOut(this);
  xmlFile = new proxml.XMLElement("MotionCapture");
  xmlFile.addAttribute("numFrames",counterMax);
  xmlFile.addAttribute("fps",fps);
  xmlFile.addAttribute("width",width);
  xmlFile.addAttribute("height",height);
  xmlFile.addAttribute("depth",depth);
}

void xmlAdd() {
  proxml.XMLElement MocapFrame = new proxml.XMLElement("MocapFrame");
  xmlFile.addChild(MocapFrame);
  MocapFrame.addAttribute("index",counter);
  proxml.XMLElement Skeleton = new proxml.XMLElement("Skeleton");
  MocapFrame.addChild(Skeleton);
  Skeleton.addAttribute("id",0);
  proxml.XMLElement Joints = new proxml.XMLElement("Joints");
  Skeleton.addChild(Joints);
  for(int i=0;i<oscNames.length;i++) {
    oscXmlTags[i] = new proxml.XMLElement(oscNames[i]);
    Joints.addChild(oscXmlTags[i]);
    oscXmlTags[i].addAttribute("x",x[i]);
    oscXmlTags[i].addAttribute("y",y[i]);
    oscXmlTags[i].addAttribute("z",z[i]);
  }
}

/* saves the XML list to disk */
void xmlSaveToDisk() {
  xmlIO.saveElement(xmlFile, xmlFileName);
}  

void stop() {
  countdown.stop();
  minim.stop();
  super.stop();
  exit();
}

