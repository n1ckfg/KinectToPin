void xmlPlayerInit(int mfc){
  xmlIO = new XMLInOut(this);
  try {
    xmlIO.loadElement(xmlFilePath + "/" + xmlFileName + (mfc) + "." + xmlFileType); //loads the XML
  }
  catch(Exception e) {
    //if loading failed 
    println("XML file loading failed");
  }
}

//~~~

void xmlPlayerUpdate() {
  background(0);
  if(loaded){
  parseXML();
  fill(255,200);
  stroke(0);
  strokeWeight(5);
  for(int i=0;i<osceletonNames.length;i++) {
    pushMatrix();
    translate(width*x[i],height*y[i],(-sD*z[i])+abs(sD/2));
    ellipse(0,0,circleSize,circleSize);
    popMatrix();
  }
  if(counter<counterMax&&!modeStop) {
    counter++;
  } 
  else {
    counter=0;
    if(dialogueFile!="none") countdown.dialogue.play(0);
  }
}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void xmlEvent(proxml.XMLElement element) {
  //this function is ccalled by default when an XML object is loaded
  MotionCapture = element;
  //parseXML(); //appelle la fonction qui analyse le fichier XML
  loaded = true;
  xmlFirstRun();
}

void xmlFirstRun(){
  counterMax = int(MotionCapture.getAttribute("numFrames"));
}

void parseXML(){
  if(counter<counterMax){
    for(int i=0;i<oscXmlTags.length;i++) {
    String posXs, posYs, posZs;
    float posX, posY, posZ;
    oscXmlTags[i] = MotionCapture.getChild(counter).getChild(0).getChild(0).getChild(i); //gets to the child we need
    //loops through all the children that interest us
    posXs = oscXmlTags[i].getAttribute("x"); //gets the title
    posYs = oscXmlTags[i].getAttribute("y"); //gets the URL link
    posZs = oscXmlTags[i].getAttribute("z"); //gets the description
    posX = float(posXs);
    posY = float(posYs);
    posZ = float(posZs);
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
