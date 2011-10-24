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

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

