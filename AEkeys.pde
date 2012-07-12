String aeJsxFileName = "AEscript";
String aeJsxFilePath = scriptsFilePath;
String aeJsxFileType = "jsx";

//provided for example only; replaced here by aeJsxSaveToDisk function
void AEkeysMain() {
  AEkeysBegin();
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
      AEkeyPos(i,j);
      AEkeyRot(i,j);
    }
}
    AEkeysEnd();   
}

float AEkeyTime(int currentFrame, int totalFrames){
  return (float(currentFrame)/float(totalFrames)) * (float(totalFrames)/float(fps));
}

void AEkeyPos(int spriteNum, int frameNum){
  
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
       data.add("\t\t" + "p.setValueAtTime(" + AEkeyTime(frameNum) + ", [ " + centerNum.x + ", " + centerNum.y + "]);" + "\r");
     }
     */
}

void AEkeyRot(int spriteNum, int frameNum){
/*
   float lower, upper, centerNum;

     centerNum = particle[spriteNum].AErot[frameNum];

     if(applySmoothing && frameNum>smoothNum && frameNum<counterMax-smoothNum){
       lower = particle[spriteNum].AErot[frameNum-smoothNum];
       upper = particle[spriteNum].AErot[frameNum+smoothNum];
       centerNum = (lower + weight*centerNum + upper)*scaleNum;
     }
     
     if(frameNum%smoothNum==0||frameNum==0||frameNum==counterMax-1){
      data.add("\t\t" + "r.setValueAtTime(" + AEkeyTime(frameNum) + ", " + centerNum +");" + "\r");
     }
     */
}

void AEeffects(){
     data.add("\t" + "var myEffect = solid.property(\"Effects\").addProperty(\"Fast Blur\")(\"Blurriness\").setValue(61);");
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void AEkeysBegin() {
  data = new Data();
  data.beginSave();
  data.add("{  //start script" + "\r");
  data.add("\t" + "app.beginUndoGroup(\"foo\");" + "\r");
  data.add("\r");
  data.add("\t" + "// create project if necessary" + "\r");
  data.add("\t" + "var proj = app.project;" + "\r");
  data.add("\t" + "if(!proj) proj = app.newProject();" + "\r");
  data.add("\r");
  data.add("\t" + "// create new comp named 'my comp'" + "\r");
  data.add("\t" + "var compW = " + dW + "; // comp width" + "\r");
  data.add("\t" + "var compH = " + dH + "; // comp height" + "\r");
  data.add("\t" + "var compL = " + (counterMax/fps) + ";  // comp length (seconds)" + "\r");
  data.add("\t" + "var compRate = " + fps + "; // comp frame rate" + "\r");
  data.add("\t" + "var compBG = [0/255,0/255,0/255] // comp background color" + "\r");
  data.add("\t" + "var myItemCollection = app.project.items;" + "\r");
  data.add("\t" + "var myComp = myItemCollection.addComp('my comp',compW,compH,1,compL,compRate);" + "\r");
  data.add("\t" + "myComp.bgColor = compBG;" + "\r");
  data.add("\r");  
}

void AEkeysEnd() {
  data.add("\r");
  data.add("\t" + "app.endUndoGroup();" + "\r");
  data.add("}  //end script" + "\r");
  data.endSave("data/" + aeJsxFilePath + "/" + aeJsxFileName + "." + aeJsxFileType);
}


