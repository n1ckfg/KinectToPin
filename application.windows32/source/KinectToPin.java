import processing.core.*; 
import processing.xml.*; 

import processing.opengl.*; 
import oscP5.*; 
import netP5.*; 
import proxml.*; 
import ddf.minim.*; 
import SimpleOpenNI.*; 

import SimpleOpenNI.*; 
import proxml.*; 
import oscP5.*; 
import netP5.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class KinectToPin extends PApplet {








//~~~~~~~~~~~~~~~~~~

boolean firstRun=true;
boolean modePreview = false;

SimpleOpenNI  context;

int masterFileCounter=0;
String[] allFiles;

int sW = 640;
int sH = 480;
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

XMLInOut xmlIO;
//proxml.XMLElement xmlFile;
proxml.XMLElement MotionCapture;
String xmlFileName = "mocapData";
String xmlFileType = "xml";
String xmlFilePath = "savexml";
String aeFileName = "aeMocapData";
String aeFilePath = "saveae";
String aeFileType = "txt";
String jsonFileName = "jsonMocapData";
String jsonFilePath = "savejson";
String jsonFileType = "txt";

boolean limitReached = false;
boolean loaded = false;

String[] osceletonNames = {
  //~~~   complete list of working joints, check updates at https://github.com/Sensebloom/OSCeleton  ~~~
  "head", "neck", "torso", "r_shoulder", "r_elbow", "r_hand", "l_shoulder", "l_elbow", "l_hand", "r_hip", "r_knee", "r_foot", "l_hip", "l_knee", "l_foot"
    //"r_hand","r_wrist","r_elbow","r_shoulder", "l_hand","l_wrist","l_elbow","l_shoulder","head","torso"
};

//SKEL_HEAD, SKEL_NECK, SKEL_TORSO, SKEL_RIGHT_SHOULDER, SKEL_RIGHT_ELBOW, SKEL_RIGHT_HAND, SKEL_LEFT_SHOULDER, SKEL_LEFT_ELBOW, SKEL_LEFT_HAND, SKEL_RIGHT_HIP, SKEL_RIGHT_KNEE, SKEL_RIGHT_FOOT, SKEL_LEFT_HIP, SKEL_LEFT_KNEE, SKEL_LEFT_FOOT
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
float depth = 200; //range of depth...FYI After Effects puppet tool doesn't use Z position
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

public void setup() {
  size(sW, sH, OPENGL);
  frameRate(fps);

  for (int i=0;i<osceletonNames.length;i++) {
    simpleOpenNiPos[i] = new PVector(0, 0, 0);
    simpleOpenNiPos_proj[i] = new PVector(0, 0, 0);
  }

  dataFolder = new File(sketchPath, "data" + "/" + xmlFilePath + "/");
  allFiles = dataFolder.list();
  for (int i=0;i<allFiles.length;i++) {
    if (allFiles[i].toLowerCase().endsWith(xmlFileType)) {
      masterFileCounter++;
    }
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
  oscP5 = new OscP5(this, "127.0.0.1", 7110);
  buttons[0] = new Button(25, height-20, 30, color(240, 10, 10), 12, "rec");
  buttons[1] = new Button(60, height-20, 30, color(200, 20, 200), 12, "osc");
  buttons[2] = new Button(width-25, height-20, 30, color(50, 50, 220), 12, "save");
  buttons[3] = new Button(width-60, height-20, 30, color(20, 200, 20), 12, "play");
  buttons[4] = new Button(95, height-20, 30, color(100, 100, 100), 12, "stop");
  buttons[5] = new Button(width/2, height-20, 30, color(200, 200, 50), 12, "cam");
  xmlPlayerInit(masterFileCounter);
  xmlRecorderInit();
  countdown = new Countdown(8, 2);
  background(0);
}

//~~~


public void draw() {
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
  text("The app will freeze for 20 sec. the first time you press REC or CAM.",width/2,(height/2)-50);
  introWarningCounter++;
  }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

public void keyPressed() {
  if (key==' '||keyCode==33||keyCode==34) { //works with pgup or pgdn used by remote clicker
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
}

public void buttonHandler() {
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

public void mouseReleased(){
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
    aePinSaveToDisk(masterFileCounter);    
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

public void buttonsRefresh() {
  for (int i=0;i<buttons.length;i++) {
    buttons[i].clicked = false;
  }
}

public void modesRefresh() {
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

public void recDot() {
  fill(200);
  textAlign(LEFT);
  text(sayTextPrefix + sayTextSeparator + sayText, 40, 35);
  text(PApplet.parseInt(frameRate) + " fps", sW-60, 35);
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

public void stop() {
  countdown.stop();
  minim.stop();
  super.stop();
  exit();
}

class Button {
  float posX, posY, sizeXY;
  int offColor, hoverColor, clickColor, nowColor;
  PFont font;
  String label;
  int fontSize;
  boolean hovered=false;
  boolean clicked=false;
  float degLocal;

  Button(float x, float y, float s, int oc, int fs, String d) {
    posX = x;
    posY = y;
    sizeXY = s;
    offColor = oc;
    hoverColor = blendColor(offColor, color(40), ADD);
    clickColor = blendColor(offColor, color(120), ADD);
    nowColor = offColor;
    fontSize=fs;
    font = createFont("Arial", fontSize);
    label = d;
  }

  public void update() {
    checkButton();
    drawButton();
  }

  public void checkButton() {
    float kSize = 10;
    if (hitDetect(mouseX, mouseY, 0, 0, posX, posY, sizeXY, sizeXY)) {
      if (!mousePressed) {
        hovered=true;
        clicked=false;
      } 
      else if (mousePressed) {
        hovered=true;
        clicked=true;
      }
    /*
    } 
    else if (hitDetect(x[1], y[1], kSize, kSize, posX, posY, sizeXY, sizeXY)||hitDetect(x[4], y[4], kSize, kSize, posX, posY, sizeXY, sizeXY)) {
      hovered=true;
      clicked=false;
    } 
    else if (hitDetect(x[0], y[0], kSize, kSize, posX, posY, sizeXY, sizeXY)&&hitDetect(x[4], y[4], kSize, kSize, posX, posY, sizeXY, sizeXY)) {
      hovered=true;
      clicked=true;
    */
    } 
    else {
      hovered=false;
      clicked=false;
    }
  }

  public void drawButton() {
    ellipseMode(CENTER);
    noStroke();
    if (hovered&&!clicked) {
      nowColor = hoverColor;
    }
    else if (hovered&&clicked) {
      nowColor = clickColor;
    }
    else if (!hovered&&!clicked) {
      nowColor = offColor;
    }
    fill(0, 10);
    ellipse(posX+2, posY+2, sizeXY, sizeXY);
    fill(nowColor);
    ellipse(posX, posY, sizeXY, sizeXY);
    fill(0);
    textFont(font, fontSize);
    textAlign(CENTER, CENTER);
    text(label, posX, posY-(fontSize/4));
  }

  public boolean hitDetect(float x1, float y1, float w1, float h1, float x2, float y2, float w2, float h2) {
    w1 /= 2;
    h1 /= 2;
    w2 /= 2;
    h2 /= 2; 
    if (x1 + w1 >= x2 - w2 && x1 - w1 <= x2 + w2 && y1 + h1 >= y2 - h2 && y1 - h1 <= y2 + h2) {
      return true;
    } 
    else {
      return false;
    }
  }
}

class Countdown {

  //requires Minim

  AudioSnippet foo;

  int alphaNum = 150;
  int secStart, secBeep;
  int leaderCounter = 0;
  int leaderCounterMax, leaderCounterBeep;
  int leaderCircleSize = PApplet.parseInt(sW/2.2f);
  float leaderX = sW/2;
  float leaderY = sH/2;
  boolean beep = false;
  boolean go = false;

  PFont font;
  int fontSize = PApplet.parseInt(leaderCircleSize * 0.9f);

  Countdown(int ss, int sb) {
    secStart = ss;
    secBeep = sb;
    leaderCounterMax = secStart * fps;
    leaderCounterBeep = (secStart-secBeep) * fps;
    foo = minim.loadSnippet("24th blip sync pop.wav");
    font = createFont("Arial",fontSize);
  }

  public void update() {
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
      textAlign(CENTER);
      textFont(font,fontSize);
      text(secStart-PApplet.parseInt(leaderCounter/fps),leaderX,leaderY+(fontSize/2.7f));
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

  public void stop() {
    foo.close();
  }
}

///////////////////////////
// DATA CLASS
// Marius Watz - http://workshop.evolutionzone.com

class Data {
  ArrayList datalist;
  String filename,data[];
  int datalineId;
 
  // begin data saving
  public void beginSave() {
    datalist=new ArrayList();
  }
 
  public void add(String s) {
    datalist.add(s);
  }
 
  public void add(float val) {
    datalist.add(""+val);
  }
 
  public void add(int val) {
    datalist.add(""+val);
  }
 
  public void add(boolean val) {
    datalist.add(""+val);
  }
 
  public void endSave(String _filename) {
    filename=_filename;
 
    data=new String[datalist.size()];
    data=(String [])datalist.toArray(data);
 
    saveStrings(filename, data);
    println("Saved data to '"+filename+
      "', "+data.length+" lines.");
  }
 
  public void load(String _filename) {
    filename=_filename;
 
    datalineId=0;
    data=loadStrings(filename);
    println("Loaded data from '"+filename+
      "', "+data.length+" lines.");
  }
 
  public float readFloat() {
    return PApplet.parseFloat(data[datalineId++]);
  }
 
  public int readInt() {
    return PApplet.parseInt(data[datalineId++]);
  }
 
  public boolean readBoolean() {
    return PApplet.parseBoolean(data[datalineId++]);
  }
 
  public String readString() {
    return data[datalineId++];
  }
 
  // Utility function to auto-increment filenames
  // based on filename templates like "name-###.txt" 
 
  public String getIncrementalFilename(String templ) {
    String s="",prefix,suffix,padstr,numstr;
    int index=0,first,last,count;
    File f;
    boolean ok;
 
    first=templ.indexOf('#');
    last=templ.lastIndexOf('#');
    count=last-first+1;
 
    if( (first!=-1)&& (last-first>0)) {
      prefix=templ.substring(0, first);
      suffix=templ.substring(last+1);
 
      // Comment out if you want to use absolute paths
      // or if you're not using this inside PApplet
      if(sketchPath!=null) prefix=savePath(prefix);
 
      index=0;
      ok=false;
 
      do {
        padstr="";
        numstr=""+index;
        for(int i=0; i< count-numstr.length(); i++) padstr+="0";
        s=prefix+padstr+numstr+suffix;
 
        f=new File(s);
        ok=!f.exists();
        index++;
 
        // Provide a panic button. If index > 10000 chances are it's an
        // invalid filename.
        if(index>10000) ok=true;
 
      }
      while(!ok);
 
      // Panic button - comment out if you know what you're doing
      if(index> 10000) {
        println("getIncrementalFilename thinks there is a problem - "+
          "Is there  more than 10000 files already in the sequence "+
          " or is the filename invalid?");
        println("Returning "+prefix+"ERR"+suffix);
        return prefix+"ERR"+suffix;
      }
    }
 
    return s;
  }
 
}
/* --------------------------------------------------------------------------
 * SimpleOpenNI User Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / zhdk / http://iad.zhdk.ch/
 * date:  02/16/2011 (m/d/y)
 * ----------------------------------------------------------------------------
 */

public void setupUser(){
  context = new SimpleOpenNI(this);
  context.setMirror(true);
   
  // enable depthMap generation 
  context.enableDepth();
  
  // enable skeleton generation for all joints
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
 
  background(200,0,0);

  stroke(0,0,255);
  strokeWeight(3);
  //smooth();
  
  //size(context.depthWidth(), context.depthHeight()); 
}

public void drawUser(){
  // update the cam
  context.update();
  
  // draw depthImageMap
  if(modePreview){
    image(context.depthImage(),0,0);
  }
  
  // draw the skeleton if it's available
  if(context.isTrackingSkeleton(1)){
    if(modePreview){
    drawSkeleton(1);
    }else if(modeRec){
    simpleOpenNiEvent(1);
    }
  }
}

// draw the skeleton with the selected joints
public void drawSkeleton(int userId){
  // to get the 3d joint data
  /*
  PVector jointPos = new PVector();
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_NECK,jointPos);
  println(jointPos);
  */
  
  stroke(0,0,255);
  strokeWeight(3);
  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  
 
}

// -----------------------------------------------------------------
// SimpleOpenNI events

public void onNewUser(int userId){
  println("onNewUser - userId: " + userId);
  println("  start pose detection");
  
  context.startPoseDetection("Psi",userId);
}

public void onLostUser(int userId){
  println("onLostUser - userId: " + userId);
}

public void onStartCalibration(int userId){
  println("onStartCalibration - userId: " + userId);
}

public void onEndCalibration(int userId, boolean successful){
  println("onEndCalibration - userId: " + userId + ", successful: " + successful);
  
  if (successful){ 
    println("  User calibrated !!!");
    context.startTrackingSkeleton(userId); 
  } else { 
    println("  Failed to calibrate user !!!");
    println("  Start pose detection");
    context.startPoseDetection("Psi",userId);
  }
}

public void onStartPose(String pose,int userId){
  println("onStartPose - userId: " + userId + ", pose: " + pose);
  println(" stop pose detection");
  
  context.stopPoseDetection(userId); 
  context.requestCalibrationSkeleton(userId, true);
 
}

public void onEndPose(String pose,int userId){
  println("onEndPose - userId: " + userId + ", pose: " + pose);
}

public void xmlPlayerInit(int mfc){
  xmlIO = new XMLInOut(this);
  try {
    xmlIO.loadElement(xmlFilePath + "/" + xmlFileName + (mfc) + "." + xmlFileType); //loads the XML
  }
  catch(Exception e) {
    //if loading failed 
    println("Loading Failed");
  }
}

//~~~

public void xmlPlayerUpdate() {
  background(0);
  if(loaded){
  parseXML();
  fill(255,200);
  stroke(0);
  strokeWeight(5);
  for(int i=0;i<osceletonNames.length;i++) {
    pushMatrix();
    translate(width*x[i],height*y[i],(-depth*z[i])+abs(depth/2));
    ellipse(0,0,circleSize,circleSize);
    popMatrix();
  }
  if(counter<counterMax&&!modeStop) {
    counter++;
  } 
  else {
    counter=0;
  }
}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

public void xmlEvent(proxml.XMLElement element) {
  //this function is ccalled by default when an XML object is loaded
  MotionCapture = element;
  //parseXML(); //appelle la fonction qui analyse le fichier XML
  loaded = true;
  xmlFirstRun();
}

public void xmlFirstRun(){
  counterMax = PApplet.parseInt(MotionCapture.getAttribute("numFrames"));
}

public void parseXML(){
  if(counter<counterMax){
    for(int i=0;i<oscXmlTags.length;i++) {
    String posXs, posYs, posZs;
    float posX, posY, posZ;
    oscXmlTags[i] = MotionCapture.getChild(counter).getChild(0).getChild(0).getChild(i); //gets to the child we need
    //loops through all the children that interest us
    posXs = oscXmlTags[i].getAttribute("x"); //gets the title
    posYs = oscXmlTags[i].getAttribute("y"); //gets the URL link
    posZs = oscXmlTags[i].getAttribute("z"); //gets the description
    posX = PApplet.parseFloat(posXs);
    posY = PApplet.parseFloat(posYs);
    posZ = PApplet.parseFloat(posZs);
    //add the data to the 2D array
    x[i] = posX;
    y[i] = posY;
    z[i] = posZ;
    if(i==0){
      println("~~~~~~~~~~~~~~~~");
    }
    println(osceletonNames[i] + "  x: " + posX + "  y: " + posY + "  z: " + posZ);
  }
  }
}
public void xmlRecorderInit() {
  xmlIO = new XMLInOut(this);
  MotionCapture = new proxml.XMLElement("MotionCapture");
  MotionCapture.addAttribute("fps", fps);
  MotionCapture.addAttribute("width", width);
  MotionCapture.addAttribute("height", height);
  MotionCapture.addAttribute("depth", depth);
  MotionCapture.addAttribute("numFrames", counter);
}

//~~~

public void xmlRecorderUpdate() {
  background(0);
  if (modeRec||(modeOsc&&found)) {
    fill(255, 200);
    stroke(0);
    strokeWeight(5);
    for (int i=0;i<osceletonNames.length;i++) {
      pushMatrix();
      translate(width*x[i], height*y[i], (-depth*z[i])+abs(depth/2));
      ellipse(0, 0, circleSize, circleSize);
      popMatrix();
    }
  } 
  if (countdown.go&&!modeStop) {
    xmlAdd();
    counter++;
  }
  countdown.update();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

public void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/joint") && msg.checkTypetag("sifff")) {
    found = true;
    for (int i=0;i<osceletonNames.length;i++) {
      if (modeOsc&&msg.get(0).stringValue().equals(osceletonNames[i])) {
        x[i] = msg.get(2).floatValue();
        y[i] = msg.get(3).floatValue();
        z[i] = msg.get(4).floatValue();
      }
    }
  }
}

public void simpleOpenNiEvent(int userId) {
      context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_HEAD,simpleOpenNiPos[0]);
      context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_NECK,simpleOpenNiPos[1]);
      context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_TORSO,simpleOpenNiPos[2]);
      context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_SHOULDER,simpleOpenNiPos[3]);
      context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_ELBOW,simpleOpenNiPos[4]);
      context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,simpleOpenNiPos[5]);
      context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_SHOULDER,simpleOpenNiPos[6]);
      context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_ELBOW,simpleOpenNiPos[7]);
      context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HAND,simpleOpenNiPos[8]);
      context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HIP,simpleOpenNiPos[9]);
      context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_KNEE,simpleOpenNiPos[10]);
      context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_FOOT,simpleOpenNiPos[11]);
      context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HIP,simpleOpenNiPos[12]);
      context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_KNEE,simpleOpenNiPos[13]);
      context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_FOOT,simpleOpenNiPos[14]);
      
    for (int i=0;i<osceletonNames.length;i++) {
        context.convertRealWorldToProjective(simpleOpenNiPos[i],simpleOpenNiPos_proj[i]);
        x[i] = simpleOpenNiPos_proj[i].x/sW;
        y[i] = simpleOpenNiPos_proj[i].y/sH;
        z[i] = simpleOpenNiPos_proj[i].z/2000; //approximate 'cause don't know real SimpleOpenNI depth max/min in pixels; will fix
    }
}

public void xmlAdd() {
  MotionCapture.addAttribute("numFrames", counter);
  proxml.XMLElement MocapFrame = new proxml.XMLElement("MocapFrame");
  MotionCapture.addChild(MocapFrame);
  MocapFrame.addAttribute("index", counter);
  proxml.XMLElement Skeleton = new proxml.XMLElement("Skeleton");
  MocapFrame.addChild(Skeleton);
  Skeleton.addAttribute("id", 0);
  proxml.XMLElement Joints = new proxml.XMLElement("Joints");
  Skeleton.addChild(Joints);
  for (int i=0;i<osceletonNames.length;i++) {
    oscXmlTags[i] = new proxml.XMLElement(osceletonNames[i]);
    Joints.addChild(oscXmlTags[i]);
    if(""+x[i]=="NaN"||""+y[i]=="NaN"||""+z[i]=="NaN"){
      oscXmlTags[i].addAttribute("x", 0.0f);
      oscXmlTags[i].addAttribute("y", 0.0f);
      oscXmlTags[i].addAttribute("z", 0.0f);
    }else{
      oscXmlTags[i].addAttribute("x", x[i]);
      oscXmlTags[i].addAttribute("y", y[i]);
      oscXmlTags[i].addAttribute("z", z[i]);
    }
  }
}


public void xmlSaveToDisk() {
  xmlIO.saveElement(MotionCapture, xmlFilePath + "/" + xmlFileName + (masterFileCounter) + "." + xmlFileType);
}

public void aePinSaveToDisk(int mfc) {
  for (int z=0;z<mfc;z++) {
    int zz=z+1;
    xmlPlayerInit(zz);
    if (loaded) {
      for (int i=0;i<pinNums.length;i++) {
        pinNums[i] = i+1;
      }
      data = new Data();
      data.beginSave();
      data.add("Adobe After Effects 8.0 Keyframe Data");
      data.add("\r");
      data.add("\t"+"Units Per Second"+"\t"+fps);
      data.add("\t"+"Source Width"+"\t"+sW);
      data.add("\t"+"Source Height"+"\t"+sH);
      data.add("\t"+"Source Pixel Aspect Ratio"+"\t"+"1");
      data.add("\t"+"Comp Pixel Aspect Ratio"+"\t"+"1");
      for (int j=0;j<osceletonNames.length;j++) {
        modesRefresh();
        data.add("\r");
        data.add("Effects" + "\t" + "Puppet #2" + "\t" + "arap #3" + "\t" + "Mesh" + "\t" + "Mesh #1" + "\t" + "Deform" + "\t" + "Pin #" + pinNums[j] + "\t" + "Position");
        data.add("\t" + "Frame" + "\t" + "X pixels" + "\t" + "Y pixels");
        for (int i=0;i<MotionCapture.countChildren();i++) { 
          data.add("\t" + i  
            + "\t" + (sW * PApplet.parseFloat(MotionCapture.getChild(i).getChild(0).getChild(0).getChild(j).getAttribute("x")))
            + "\t" + (sH * PApplet.parseFloat(MotionCapture.getChild(i).getChild(0).getChild(0).getChild(j).getAttribute("y")))); //gets to the child we need //gets to the child we need
        }
      }
      data.add("\r");
      data.add("\r");
      data.add("End of Keyframe Data");
      data.endSave("data/"+ aeFilePath + "/" + aeFileName + zz +"."+aeFileType);
    }
  }
}

/*
//json parser by Greg Borenstein, gregborenstein.com 
String toJson() {
    String result = "{\"project\" : \"skelestreamer\",";      
    result += "\"session\" : \"" + uuid + "\",";       
    result += "\"head\" : {\"x\":" + head.x + ", \"y\":" + head.y + ",\"z\":" + head.z + "},";         
    result += "\"neck\" : {\"x\":" + neck.x + ", \"y\":" + neck.y + ",\"z\":" + neck.z + "},";          
    result += "\"rightShoulder\" : {\"x\":" + rightShoulder.x + ", \"y\":" + rightShoulder.y + ",\"z\":" + rightShoulder.z + "},"; 
    result += "\"rightElbow\" : {\"x\":" + rightElbow.x + ", \"y\":" + rightElbow.y + ",\"z\":" + rightElbow.z + "},";    
    result += "\"rightHand\" : {\"x\":" + rightHand.x + ", \"y\":" + rightHand.y + ",\"z\":" + rightHand.z + "},";     
    result += "\"leftShoulder\" : {\"x\":" + leftShoulder.x + ", \"y\":" + leftShoulder.y + ",\"z\":" + leftShoulder.z + "},";  
    result += "\"leftElbow\" : {\"x\":" + leftElbow.x + ", \"y\":" + leftElbow.y + ",\"z\":" + leftElbow.z + "},";     
    result += "\"leftHand\" : {\"x\":" + leftHand.x + ", \"y\":" + leftHand.y + ",\"z\":" + leftHand.z + "},";    
    result += "\"torso\" : {\"x\":" + torso.x + ", \"y\":" + torso.y + ",\"z\":" + torso.z + "},";         
    result += "\"rightHip\" : {\"x\":" + rightHip.x + ", \"y\":" + rightHip.y + ",\"z\":" + rightHip.z + "},";      
    result += "\"rightKnee\" : {\"x\":" + rightKnee.x + ", \"y\":" + rightKnee.y + ",\"z\":" + rightKnee.z + "},";     
    result += "\"rightFoot\" : {\"x\":" + rightFoot.x + ", \"y\":" + rightFoot.y + ",\"z\":" + rightFoot.z + "},";     
    result += "\"leftHip\" : {\"x\":" + leftHip.x + ", \"y\":" + leftHip.y + ",\"z\":" + leftHip.z + "},";       
    result += "\"leftKnee\" : {\"x\":" + leftKnee.x + ", \"y\":" + leftKnee.y + ",\"z\":" + leftKnee.z + "},";     
    result += "\"leftFoot\" : {\"x\":" + leftFoot.x + ", \"y\":" + leftFoot.y + ",\"z\":" + leftFoot.z + "}";     

    result += "}";
    return result;
  }
*/

  public void jsonSaveToDisk(int mfc){
  for (int z=0;z<mfc;z++) {
    int zz=z+1;
    xmlPlayerInit(zz);
    if (loaded) {
      /*
      for (int i=0;i<pinNums.length;i++) {
        pinNums[i] = i+1;
      }
      */
      data = new Data();
      data.beginSave();
      data.add("Adobe After Effects 8.0 Keyframe Data");
      data.add("\r");
      data.add("\t"+"Units Per Second"+"\t"+fps);
      data.add("\t"+"Source Width"+"\t"+sW);
      data.add("\t"+"Source Height"+"\t"+sH);
      data.add("\t"+"Source Pixel Aspect Ratio"+"\t"+"1");
      data.add("\t"+"Comp Pixel Aspect Ratio"+"\t"+"1");
      for (int j=0;j<osceletonNames.length;j++) {
        modesRefresh();
        data.add("\r");
        data.add("Effects" + "\t" + "Puppet #2" + "\t" + "arap #3" + "\t" + "Mesh" + "\t" + "Mesh #1" + "\t" + "Deform" + "\t" + "Pin #" + pinNums[j] + "\t" + "Position");
        data.add("\t" + "Frame" + "\t" + "X pixels" + "\t" + "Y pixels");
        for (int i=0;i<MotionCapture.countChildren();i++) {
         if(MotionCapture.getChild(i).getChild(0).getChild(0).getChild(j).getAttribute("x")=="NaN"||MotionCapture.getChild(i).getChild(0).getChild(0).getChild(j).getAttribute("y")=="NaN"){
          data.add("\t" + i  
            + "\t" + 0.0f
            + "\t" + 0.0f); //gets to the child we need //gets to the child we need
         }else{ 
          data.add("\t" + i  
            + "\t" + (sW * PApplet.parseFloat(MotionCapture.getChild(i).getChild(0).getChild(0).getChild(j).getAttribute("x")))
            + "\t" + (sH * PApplet.parseFloat(MotionCapture.getChild(i).getChild(0).getChild(0).getChild(j).getAttribute("y")))); //gets to the child we need //gets to the child we need
        }
        }
      }
      data.add("\r");
      data.add("\r");
      data.add("End of Keyframe Data");
      data.endSave("data/"+ jsonFilePath + "/" + jsonFileName + zz +"."+jsonFileType);
    }
  }
}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#c0c0c0", "KinectToPin" });
  }
}
