import proxml.*;

Data data;

int sW = 720;
int sH = 405;
int destW = sW;
int destH = sH;
float multW = destW/sW;
float multH  = destH/sH;
int fps = 24;
float depthMax = 1000;

proxml.XMLElement keyFrameList;
XMLInOut xmlIO;
boolean loaded = false;

String[] attributeNames = {
  "index","tweenSnap","x","y","scaleX","scaleY","rotation"
};

float posX = destW/2;
float posY = destH/2;
float posZ = 0;
float rot = 0;


void setup() {
  //size(sW,sH);
  //frameRate(fps);

  xmlIO = new XMLInOut(this);
  try {
    xmlIO.loadElement("flash_keys.xml"); //loads the XML
  } 
  catch(Exception e) {
    //if loading failed 
    println("Loading Failed");
  }
  
  data = new Data();
  data.beginSave();
  data.add("Adobe After Effects 8.0 Keyframe Data");
  data.add("\r");
  data.add("\t"+"Units Per Second"+"\t"+fps);
  data.add("\t"+"Source Width"+"\t"+"100");
  data.add("\t"+"Source Height"+"\t"+"100");
  data.add("\t"+"Source Pixel Aspect Ratio"+"\t"+"1");
  data.add("\t"+"Comp Pixel Aspect Ratio"+"\t"+"1");
}

void xmlEvent(proxml.XMLElement element) {
  //this function is ccalled by default when an XML object is loaded
  keyFrameList = element;
  //parseXML(); //appelle la fonction qui analyse le fichier XML
  loaded = true;

  data.add("\r");
  data.add("Transform"+"\t"+"Position");
  data.add("\t"+"Frame"+"\t"+"X pixels"+"\t"+"Y pixels"+"\t"+"Z pixels");	

for(int i=1;i<keyFrameList.countChildren();i++) {
  try{
        posX += multW * float(keyFrameList.getChild(i).getAttribute(attributeNames[2]));
  }  catch(Exception e) { }
   try{
     posY += multH * float(keyFrameList.getChild(i).getAttribute(attributeNames[3]));
   }  catch(Exception e) { }
  try{
    posZ = (depthMax-(depthMax*((float(keyFrameList.getChild(i).getAttribute(attributeNames[4])) + float(keyFrameList.getChild(i).getAttribute(attributeNames[5])))/2)));
  }  catch(Exception e) { }
  data.add(
        "\t" + keyFrameList.getChild(i).getAttribute(attributeNames[0])
        + "\t" + posX
        + "\t" + posY
        + "\t" + posZ);
  }
  
  data.add("\r");
  data.add("Transform"+"\t"+"Orientation");
  data.add("\t"+"Frame"+"\t"+"X degrees"+"\t"+"Y degrees"+"\t"+"Z degrees");	

for(int j=1;j<keyFrameList.countChildren();j++) {
  try{
        rot += float(keyFrameList.getChild(j).getAttribute(attributeNames[6]));
  }  catch(Exception e) {
//
  }
        data.add(
        "\t" + keyFrameList.getChild(j).getAttribute(attributeNames[0])
        + "\t" + 0 + "\t" + 0 
        + "\t" + rot);
  }
    
  
  data.add("\r");
  data.add("\r");
  data.add("End of Keyframe Data");
  data.endSave(
  data.getIncrementalFilename(
  sketchPath("save"+
    java.io.File.separator+
    "data ####.txt")));
  exit();

}

