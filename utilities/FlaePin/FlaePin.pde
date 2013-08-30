import proxml.*;

Data data;

int sW = 640;
int sH = 480;
int fps = 24;

proxml.XMLElement MotionCapture;
XMLInOut xmlIO;
boolean loaded = false;

String[] oscNames = {
  //~~~   complete list of working joints, check updates at https://github.com/Sensebloom/OSCeleton  ~~~
"head","neck","torso","r_shoulder","r_elbow","r_hand","l_shoulder","l_elbow","l_hand","r_hip","r_knee","r_foot","l_hip","l_knee","l_foot"
  //~~~
  //"head","r_shoulder","r_elbow","r_hand","l_shoulder","l_elbow","l_hand"
};

int[] pinNums = new int[oscNames.length];

float posX, posY, posZ;


void setup() {
  for(int i=0;i<pinNums.length;i++){
  pinNums[i] = i+1;
}
  //size(sW,sH);
  //frameRate(fps);

  xmlInit();

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

void xmlInit() {
  xmlIO = new XMLInOut(this);
  try {
    xmlIO.loadElement("mocapData.xml"); //loads the XML
  }
  catch(Exception e) {
    //if loading failed 
    println("Loading Failed");
  }
}

void xmlEvent(proxml.XMLElement element) {
  //this function is ccalled by default when an XML object is loaded
  MotionCapture = element;
  //parseXML(); //appelle la fonction qui analyse le fichier XML
  loaded = true;
  xmlFirstRun();
}

void xmlFirstRun() {
//
}

void draw() {
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
    data.getIncrementalFilename(
    sketchPath("save"+
      java.io.File.separator+
      "data ####.txt")));
    exit();
  }
}
