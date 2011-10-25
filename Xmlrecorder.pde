void xmlRecorderInit() {
  xmlIO = new XMLInOut(this);
  xmlFile = new proxml.XMLElement("MotionCapture");
  xmlFile.addAttribute("numFrames",counterMax);
  xmlFile.addAttribute("fps",fps);
  xmlFile.addAttribute("width",width);
  xmlFile.addAttribute("height",height);
  xmlFile.addAttribute("depth",depth);
}

//~~~

void xmlRecorderUpdate() {
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
  if(countdown.go&&!modeStop) {
      xmlAdd();
      counter++;
  }
  countdown.update();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/joint") && msg.checkTypetag("sifff")) {
    found = true;
    for(int i=0;i<oscNames.length;i++) {
      if (modeOsc&&msg.get(0).stringValue().equals(oscNames[i])) {
        x[i] = msg.get(2).floatValue();
        y[i] = msg.get(3).floatValue();
        z[i] = msg.get(4).floatValue();
      }
    }
  }
}

void skeletonEvent(){
//
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
void allSaveToDisk(){
  xmlSaveToDisk(); //1.  save out xml file
  xmlPlayerInit(); //2.  load saved xml file
  aePinSave(); //3.  convert to ae format
  modesRefresh();//4.  reset switches
}

void xmlSaveToDisk() {
  xmlIO.saveElement(xmlFile, xmlFileName);
}

void aePinSave() {
if(loaded) {
  for(int i=0;i<pinNums.length;i++){
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
    for(int j=0;j<oscNames.length;j++){
    modesRefresh();
    data.add("\r");
    data.add("Effects" + "\t" + "Puppet #2" + "\t" + "arap #3" + "\t" + "Mesh" + "\t" + "Mesh #1" + "\t" + "Deform" + "\t" + "Pin #" + pinNums[j] + "\t" + "Position");
    data.add("\t" + "Frame" + "\t" + "X pixels" + "\t" + "Y pixels");
    for(int i=0;i<MotionCapture.countChildren();i++) { 
      data.add("\t" + i  
      + "\t" + (sW * float(MotionCapture.getChild(i).getChild(0).getChild(0).getChild(j).getAttribute("x")))
      + "\t" + (sH * float(MotionCapture.getChild(i).getChild(0).getChild(0).getChild(j).getAttribute("y")))); //gets to the child we need //gets to the child we need
    }
    }
    data.add("\r");
    data.add("\r");
    data.add("End of Keyframe Data");
    data.endSave(aeFilePath + "/" + aeFileName);
  }
}
