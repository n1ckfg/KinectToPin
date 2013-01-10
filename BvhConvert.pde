int startTime = 0;

void bvhConvert(){
    println(bvh1.parser.frame + " " + bvh1.frameMax);
    if(bvh1.parser.frame<bvh1.frameMax){
    bvh1.update(millis());
    xmlRecorderUpdate();
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~
    }else{
    xmlSaveToDisk();
    delay(saveDelayInterval);
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
  bvh1 = new PBvh(loadStrings((String) bvhNames.get(bvhConversionCounter)),bvhScaleFactor,bvhOffset);
  xmlRecorderInit();
  startTime = millis();
  //countdown.go = true;
  //countdown.beep = true;
  //parserA = new BvhParser();
}

