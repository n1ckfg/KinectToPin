import processing.opengl.*;
import oscP5.*;
import netP5.*;
import proxml.*;
import ddf.minim.*;
import SimpleOpenNI.*;

//~~~~~~~~~~~~~~~~~~

//**************************
//float durationFrames = 10 * fps;
int numParticles = 100;
boolean motionBlur = true;
boolean applyEffects = false;
boolean applySmoothing = true;
//smoothing
int smoothNum = 6;
float weight = 18;
float scaleNum  = 1.0 / (weight + 2);
//---
boolean tracePath = true;
//**************************

boolean firstRun=true;
boolean modePreview = false;
int previewLevel = 5;
PImage previewImg;
int[] previewInt;

SimpleOpenNI  context;
boolean mirror = false;

int masterFileCounter=0;
String[] allFiles;

//this sketch
int sW = 640;
int sH = 480;
float sD = 200; //range of depth...FYI After Effects puppet tool doesn't use Z position

//destination After Effects comp
int dW = 1920;
int dH = 1080;

int fps = 24;
int counter = 0;
int counterMax = 0; //number of MocapFrames to record
Countdown countdown;

String sayText = "";
String sayTextPrefix = "";
String sayTextSeparator = "  ...  ";

Minim minim;
OscP5 oscP5;
boolean found=false;
String ipNumber = "127.0.0.1";
int receivePort = 7110;

XMLInOut xmlIO;
//proxml.XMLElement xmlFile;
proxml.XMLElement MotionCapture;
String xmlFileName = "mocapData";
String xmlFileType = "xml";
String xmlFilePath = "savexml";
boolean saveXml = true;
//~
String aeFileName = "AEpinData";
String aeFilePath = "saveae-pins";
String aeFileType = "txt";
boolean savePins = true;
//~
String aePointFileName = "AEpointData";
String aePointFilePath = "saveae-points";
String aePointFileType = "txt";
boolean savePoints = false;
//~
String jsonFileName = "jsonData";
String jsonFilePath = "savejson";
String jsonFileType = "txt";
boolean saveJson = false;
//~
String aeJsxFileName = "AEscript";
String aeJsxFilePath = "saveae-jsx";
String aeJsxFileType = "jsx";
boolean saveJsx = false;

String mayaFileName = "mayaScript";
String mayaFilePath = "saveMaya";
String mayaFileType = "py";
boolean saveMaya = false;

boolean limitReached = false;
boolean loaded = false;

String[] osceletonNamesNormal = {"head", "neck", "torso", "r_shoulder", "r_elbow", "r_hand", "l_shoulder", "l_elbow", "l_hand", "r_hip", "r_knee", "r_foot", "l_hip", "l_knee", "l_foot"};
String[] osceletonNamesReversed = {"head", "neck", "torso", "l_shoulder", "l_elbow", "l_hand", "r_shoulder", "r_elbow", "r_hand", "l_hip", "l_knee", "l_foot", "r_hip", "r_knee", "r_foot"};
String[] osceletonNames = new String[15];

PVector[] simpleOpenNiPos = new PVector[osceletonNames.length];
PVector[] simpleOpenNiPos_proj = new PVector[osceletonNames.length];

File dataFolder;
Data data;
int[] pinNums = new int[osceletonNames.length];
proxml.XMLElement[] oscXmlTags = new proxml.XMLElement[osceletonNames.length];
float posX, posY, posZ;

float[] x = new float[osceletonNames.length];
float[] y = new float[osceletonNames.length];
float[] z = new float[osceletonNames.length];
int circleSize = 50;

Button[] buttons = new Button[6];

boolean modeRec = false;
boolean modeOsc = false;
boolean modePlay = false;
boolean modeExport = false;
boolean modeStop = true;
boolean needsSaving = false;

int introWarningCounter = 0;
int introWarningCounterMax = 6*fps;

//~~~~~~~~~~~~~~~~~~

void initSettings(){
  Settings settings = new Settings("settings.txt");
  if(mirror){
    osceletonNames = osceletonNamesNormal;
  }else{
    osceletonNames = osceletonNamesReversed;
  }
  simpleOpenNiPos = new PVector[osceletonNames.length];
  simpleOpenNiPos_proj = new PVector[osceletonNames.length];
  pinNums = new int[osceletonNames.length];
  oscXmlTags = new proxml.XMLElement[osceletonNames.length];
  x = new float[osceletonNames.length];
  y = new float[osceletonNames.length];
  z = new float[osceletonNames.length];
}

void setup() {
  initSettings();
  size(sW, sH, OPENGL);
  frameRate(fps);

  for (int i=0;i<osceletonNames.length;i++) {
    simpleOpenNiPos[i] = new PVector(0, 0, 0);
    simpleOpenNiPos_proj[i] = new PVector(0, 0, 0);
  }

  dataFolder = new File(sketchPath, "data" + "/" + xmlFilePath + "/");
  allFiles = dataFolder.list();
  try{
  for (int i=0;i<allFiles.length;i++) {
    if (allFiles[i].toLowerCase().endsWith(xmlFileType)) {
      masterFileCounter++;
    }
  }
  }catch (Exception e){
  //
  }
  //masterFileCounter = allFiles.length;
  if (masterFileCounter==1) {
    sayTextPrefix = masterFileCounter + " existing saved XML file";
  }
  else {
    sayTextPrefix = masterFileCounter + " existing saved XML files";
  }
  ellipseMode(CENTER);
  minim = new Minim(this);
  oscP5 = new OscP5(this, ipNumber, receivePort);
  buttons[0] = new Button(25, height-20, 30, color(240, 10, 10), 12, "rec");
  buttons[1] = new Button(60, height-20, 30, color(200, 20, 200), 12, "osc");
  buttons[2] = new Button(width-25, height-20, 30, color(50, 50, 220), 12, "save");
  buttons[3] = new Button(width-60, height-20, 30, color(20, 200, 20), 12, "play");
  buttons[4] = new Button(95, height-20, 30, color(100, 100, 100), 12, "stop");
  buttons[5] = new Button(width/2, height-20, 30, color(200, 200, 50), 12, "cam");
  xmlPlayerInit(masterFileCounter);
  xmlRecorderInit();
  countdown = new Countdown(8, 2);
  
  previewImg = createImage(sW,sH,RGB);
  previewInt = new int[sW*sH];
  background(0);
}

//~~~


void draw() {
  background(0);
  if (modeRec||modePreview) {
    drawUser(); //looking for one user; may upgrade later
  }
  if (!modePreview) {
    if (modeRec||modeOsc) {
      xmlRecorderUpdate();
    }
    if (modePlay) {
      xmlPlayerUpdate();
    }
  }
  buttonHandler();
  recDot();
  sayText = xmlFileName + (masterFileCounter);
  //println(counter);
  if(introWarningCounter<introWarningCounterMax){
    textAlign(CENTER);
  text("PLEASE NOTE:",width/2,(height/2)-70);
  text("The app will freeze for ~20 sec. the first time you press REC or CAM.",width/2,(height/2)-50);
  introWarningCounter++;
  }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void keyPressed() {
  if (key==' '||keyCode==33) { //REC works with space or pgdn from clicker
    if(!modeRec){
    if (firstRun) {
      firstRun=false;
      setupUser(); //this sets up SimpleOpenNi
    }
    modesRefresh();
    xmlRecorderInit();
    modeRec = true;
    if (!needsSaving) {
      needsSaving = true;
      masterFileCounter++;
    }
    sayTextPrefix = "Record skeleton data";
  }else{
    modesRefresh();
    if (needsSaving) {
      countdown.foo.play();
      xmlSaveToDisk();
    }
    needsSaving=false;
   sayTextPrefix = "Stop recording";
  }
}

if(key=='c'||key=='C'||keyCode==34){  //CAM works with C key or pgup from clicker
    if (modePreview) {
    modesRefresh();
      //modePreview=false;
    }
    else if (!modePreview) {
    modesRefresh();
      modePreview=true;
      if (firstRun) {
        firstRun=false;
        setupUser(); //this sets up SimpleOpenNi
      }
    }
    //needsSaving=false;
}
}

void buttonHandler() {
  for (int i=0;i<buttons.length;i++) {
  if(modePreview){
    buttons[5].checkButton();
    buttons[5].drawButton();
  }else{
    buttons[i].checkButton();
    buttons[i].drawButton();
  }
  }
}

void mouseReleased(){
  if (buttons[0].clicked) { //REC
    if (firstRun) {
      firstRun=false;
      setupUser(); //this sets up SimpleOpenNi
    }
    modesRefresh();
    xmlRecorderInit();
    modeRec = true;
    if (!needsSaving) {
      needsSaving = true;
      masterFileCounter++;
    }
  }
  else if (buttons[1].clicked) {  //OSC from OSCeleton
    modesRefresh();
    xmlRecorderInit();
    modeOsc = true;
    if (!needsSaving) {
      needsSaving = true;
      masterFileCounter++;
    }
  }
  else if (buttons[2].clicked) { //SAVE
    modesRefresh();
    modeExport = true;
    if(savePins) aePinSaveToDisk(masterFileCounter);    
    if(savePoints) aePointSaveToDisk(masterFileCounter);    
    //if(saveJson) aeJsxSaveToDisk(masterFileCounter);    
    if(saveJsx) aeJsxSaveToDisk(masterFileCounter);    
    if(saveMaya) mayaSaveToDisk(masterFileCounter);
  }
  else if (buttons[3].clicked) { //PLAY
    modesRefresh();
    if (needsSaving) {
      xmlSaveToDisk();
    }
    modePlay = true;
  }
  else if (buttons[4].clicked) {  //STOP
    modesRefresh();
    if (needsSaving) {
      countdown.foo.play();
      xmlSaveToDisk();
    }
    needsSaving=false;
  }
  else if (buttons[5].clicked) {  //CAM
    if (modePreview) {
    modesRefresh();
      //modePreview=false;
    }
    else if (!modePreview) {
    modesRefresh();
      modePreview=true;
      if (firstRun) {
        firstRun=false;
        setupUser(); //this sets up SimpleOpenNi
      }
    }
    //needsSaving=false;
  }

if (buttons[0].hovered) {
    sayTextPrefix = "Record skeleton data";
}else if (buttons[1].hovered) {
    sayTextPrefix = "Record OSC data";
}else if (buttons[2].hovered) {
    sayTextPrefix = "Save all XML files for After Effects";
}else if (buttons[3].hovered) {
    sayTextPrefix = "Play back last saved XML file";
}else if (buttons[4].hovered) {
    sayTextPrefix = "Stop recording";
}else if (buttons[5].hovered) {
    sayTextPrefix = "Toggle camera view";
}
}

void buttonsRefresh() {
  for (int i=0;i<buttons.length;i++) {
    buttons[i].clicked = false;
  }
}

void modesRefresh() {
  countdown = new Countdown(8, 2);
  buttonsRefresh();
  counter=0;
  modeRec = false;
  modeOsc = false;
  modePlay = false;
  modeExport = false; 
  modeStop=false;
  modePreview=false;
}

void recDot() {
  fill(200);
  textAlign(LEFT);
  text(sayTextPrefix + sayTextSeparator + sayText, 40, 35);
  text(int(frameRate) + " fps", sW-60, 35);
  noFill();
  if (counter%2!=0) {
    if (modeRec) {
      stroke(255, 20, 0);
    }
    else if (modeOsc) {
      stroke(225, 0, 205);
    }
    else if (!modeRec&&!modeOsc) {
      stroke(35, 25, 35);
    }
  } 
  else {
    stroke(35, 25, 35);
  }
  strokeWeight(20);
  point(20, 30);
  stroke(200);
  strokeWeight(1);
  rectMode(CORNER);
  rect(3, 59, 633, 360);
  line((sW/2)-10, (sH/2), (sW/2)+10, (sH/2));
  line((sW/2), (sH/2)-10, (sW/2), (sH/2)+10);
}

void stop() {
  countdown.stop();
  minim.stop();
  super.stop();
  exit();
}

