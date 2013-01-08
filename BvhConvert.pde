void bvhConvert(){
    bvh1.update(millis());
    println("fooooo");
    for (int j=0;j<osceletonNames.length;j++) {
      
      PVector p = (PVector) bvh1.bonePoints.get(j);
      x[j] = p.x/sW;
      y[j] = p.y/sH;
      z[j] = p.z/(sD*10); //approximate 'cause don't know real SimpleOpenNI depth max/min in pixels; will fix
      
    }
  
    xmlRecorderUpdate();
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if(random(1)>0.99){
    xmlSaveToDisk();
    bvhConversionCounter++;
    if(bvhConversionCounter<bvhConversionCounterMax){
      bvhBegin(); 
    }else{
      doButtonStop();
    }
  }
}

void bvhBegin(){
  masterFileCounter++;
  xmlRecorderInit();
  
  parserA = new BvhParser();
  bvh1 = new PBvh(loadStrings((String) bvhNames.get(bvhConversionCounter)),new PVector(6,-6, 6),new PVector(sW/2,sH/1.5,0));
}

