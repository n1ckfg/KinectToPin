void xmlRecorderInit() {
  xmlIO = new XMLInOut(this);
  MotionCapture = new proxml.XMLElement("MotionCapture");
  MotionCapture.addAttribute("fps", fps);
  MotionCapture.addAttribute("width", width);
  MotionCapture.addAttribute("height", height);
  MotionCapture.addAttribute("depth", depth);
  MotionCapture.addAttribute("numFrames", counter);
}

//~~~

void xmlRecorderUpdate() {
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

void oscEvent(OscMessage msg) {
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

void simpleOpenNiEvent(int userId) {
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

void xmlAdd() {
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
    if(""+x[i]=="NaN"){
      oscXmlTags[i].addAttribute("x", 0.0);
    }else{
      oscXmlTags[i].addAttribute("x", x[i]);
    }    
    if(""+y[i]=="NaN"){
      oscXmlTags[i].addAttribute("y", 0.0);
    }else{
      oscXmlTags[i].addAttribute("y", y[i]);
    }    
    if(""+z[i]=="NaN"){
      oscXmlTags[i].addAttribute("z", 0.0);
    }else{
      oscXmlTags[i].addAttribute("z", z[i]);
    }
  }
}


void xmlSaveToDisk() {
  xmlIO.saveElement(MotionCapture, xmlFilePath + "/" + xmlFileName + (masterFileCounter) + "." + xmlFileType);
}

void aePinSaveToDisk(int mfc) {
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
            + "\t" + (sW * float(MotionCapture.getChild(i).getChild(0).getChild(0).getChild(j).getAttribute("x")))
            + "\t" + (sH * float(MotionCapture.getChild(i).getChild(0).getChild(0).getChild(j).getAttribute("y")))); //gets to the child we need //gets to the child we need
        }
      }
      data.add("\r");
      data.add("\r");
      data.add("End of Keyframe Data");
      data.endSave("data/"+ aeFilePath + "/" + aeFileName + zz +"."+aeFileType);
    }
  }
}

