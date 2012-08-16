//provided for example only; replaced here by aeJsxSaveToDisk function
void mayaKeysMain() {
/*
mayaKeysBegin();
  for (int i=0;i<numParticles;i++) {
    data.add("\t" + "var solid = myComp.layers.addSolid([1.0, 1.0, 0], \"my square\", 50, 50, 1);" + "\r");
    if(motionBlur){
      data.add("\t" + "solid.motionBlur = true;" + "\r");
    }
    if(applyEffects){
      AEeffects();
    }
    data.add("\r");
    data.add("\t" + "var p = solid.property(\"position\");" + "\r");
    data.add("\t" + "var r = solid.property(\"rotation\");" + "\r");
    data.add("\r");

    for (int j=0;j<counterMax;j++) {
      mayaKeyPos(i,j);
      mayaKeyRot(i,j);
    }
}
    mayaKeysEnd();   
    */
}

float mayaKeyTime(int currentFrame, int totalFrames){
  return (float(currentFrame)/float(totalFrames)) * (float(totalFrames)/float(fps));
}

void mayaKeyPos(int spriteNum, int frameNum){
  
     // smoothing algorithm by Golan Levin

   /*
   PVector lower, upper, centerNum;

     centerNum = new PVector(particle[spriteNum].AEpath[frameNum].x,particle[spriteNum].AEpath[frameNum].y);

     if(applySmoothing && frameNum>smoothNum && frameNum<counterMax-smoothNum){
       lower = new PVector(particle[spriteNum].AEpath[frameNum-smoothNum].x,particle[spriteNum].AEpath[frameNum-smoothNum].y);
       upper = new PVector(particle[spriteNum].AEpath[frameNum+smoothNum].x,particle[spriteNum].AEpath[frameNum+smoothNum].y);
       centerNum.x = (lower.x + weight*centerNum.x + upper.x)*scaleNum;
       centerNum.y = (lower.y + weight*centerNum.y + upper.y)*scaleNum;
     }
     
     if(frameNum%smoothNum==0||frameNum==0||frameNum==counterMax-1){
       data.add("\t\t" + "p.setValueAtTime(" + mayaKeyTime(frameNum) + ", [ " + centerNum.x + ", " + centerNum.y + "]);" + "\r");
     }
     */
}

void mayaKeyRot(int spriteNum, int frameNum){
/*
   float lower, upper, centerNum;

     centerNum = particle[spriteNum].AErot[frameNum];

     if(applySmoothing && frameNum>smoothNum && frameNum<counterMax-smoothNum){
       lower = particle[spriteNum].AErot[frameNum-smoothNum];
       upper = particle[spriteNum].AErot[frameNum+smoothNum];
       centerNum = (lower + weight*centerNum + upper)*scaleNum;
     }
     
     if(frameNum%smoothNum==0||frameNum==0||frameNum==counterMax-1){
      data.add("\t\t" + "r.setValueAtTime(" + mayaKeyTime(frameNum) + ", " + centerNum +");" + "\r");
     }
     */
}

void mayaEffects(){
     //this is AE here
     //data.add("\t" + "var myEffect = solid.property(\"Effects\").addProperty(\"Fast Blur\")(\"Blurriness\").setValue(61);");
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void mayaKeysBegin() {
  data = new Data();
  data.beginSave();
  data.add("from maya.cmds import *" + "\r");
  data.add("from random import uniform as rnd" + "\r");
  data.add("#select(all=True)" + "\r");
  data.add("#delete()" + "\r");
  data.add("playbackOptions(minTime=\"0\", maxTime=\"" + counterMax + "\")" + "\r");
  data.add("#grav = gravity()" + "\r");  
  data.add("\r");  
}

void mayaKeysEnd(int qq) {
  data.add("#floor = polyPlane(w=30,h=30)" + "\r");
  data.add("#rigidBody(passive=True)" + "\r");
  data.add("#move(0,0,0)" + "\r");
  data.endSave("data/" + mayaFilePath + "/" + mayaFileName + qq + "." + mayaFileType);
}


