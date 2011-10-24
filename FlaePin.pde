
void flaePinInit() {
  for(int i=0;i<pinNums.length;i++){
  pinNums[i] = i+1;
}
  //size(sW,sH);
  //frameRate(fps);

  //xmlPlayerInit();

  data = new Data();
  data.beginSave();
  data.add("Adobe After Effects 8.0 Keyframe Data");
  data.add("\r");
  data.add("\t"+"Units Per Second"+"\t"+fps);
  data.add("\t"+"Source Width"+"\t"+sW);
  data.add("\t"+"Source Height"+"\t"+sH);
  data.add("\t"+"Source Pixel Aspect Ratio"+"\t"+"1");
  data.add("\t"+"Comp Pixel Aspect Ratio"+"\t"+"1");
}

void flaePinUpdate() {
  if(loaded) {
    
    for(int j=0;j<oscNames.length;j++){
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
    data.endSave(
    data.getIncrementalFilename(sketchPath("save"+java.io.File.separator+"data####.txt")));
    modePlay = true;
    modeRecord = false;
    modeExport = false;
  }
}
