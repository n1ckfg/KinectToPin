class PBvh{
  BvhParser parser;  
  PVector scaleFactor = new PVector(1,1,1);
  PVector offset = new PVector(0,0,0);
  int frame = 0;
  int frameMax = 0;
  
  PBvh(String[] data, PVector _sf, PVector _ofs){
    parser = new BvhParser();
    parser.init();
    parser.parse(data);
    //parser.setMotionLoop(false);
    frameMax = parser._nbFrames;
    scaleFactor = _sf;
    offset = _ofs;
  }
  
  void update(int ms){
    parser.moveMsTo(ms - startTime); 
    parser.update();
    frame = parser.frame;
    int counter = 0;
    
      for(BvhBone b : parser.getBones()){
        pushMatrix();
        translate((b.absPos.x * scaleFactor.x) + offset.x, (b.absPos.y * scaleFactor.y) + offset.y, (b.absPos.z * scaleFactor.z) + offset.z);
        //ellipse(0, 0, 10, 10);
        popMatrix();
        if (!b.hasChildren()){
          pushMatrix();
          translate((b.absEndPos.x * scaleFactor.x) + offset.x, (b.absEndPos.y * scaleFactor.y) + offset.y, (b.absEndPos.z * scaleFactor.z) + offset.z);
          //ellipse(0, 0, 10, 10);
          popMatrix();
        }
       boolean writeCoords = false;
       for (int i=0;i<osceletonNames.length;i++) {
         String name1 = "" + b.getName();
         String name2 = "" + osceletonNames[i];
         String name3 = "" + cmuBvhNames[i];
         String name4 = "" + brekelNames[i];
         if(name1.equals(name2) || name1.equals(name3) || name1.equals(name4)){
           writeCoords = true;
           counter=i;
         }
       }
      if(writeCoords){
        x[counter] = ((b.getAbsPosition().x * scaleFactor.x) + offset.x)/sW;
        y[counter] = ((b.getAbsPosition().y * scaleFactor.y) + offset.y)/sH;
        z[counter] = ((b.getAbsPosition().z * scaleFactor.z) + offset.z)/sD;///(sD*10); //approximate 'cause don't know real SimpleOpenNI depth max/min in pixels; will fix
        //if(counter<osceletonNames.length-1d) counter++;
         println(scaleFactor + " " + offset + " " + b.getName() + " " + osceletonNames[counter] + " " + x[counter] + " " + y[counter] + " " + z[counter]);
      }    
    } 
  }

}
