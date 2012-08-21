class Settings {

  Data settings;

  Settings(String _s) {
    try {
      settings = new Data();
      settings.load(_s);
      for (int i=0;i<settings.data.length;i++) {
        if (settings.data[i].equals("mirror")) mirror = setBoolean(settings.data[i+1]);
        if (settings.data[i].equals("ipNumber")) ipNumber = setString(settings.data[i+1]);
        if (settings.data[i].equals("receivePort")) receivePort = setInt(settings.data[i+1]);
        if (settings.data[i].equals("saveXml")) saveXml = setBoolean(settings.data[i+1]);
        if (settings.data[i].equals("savePins")) savePins = setBoolean(settings.data[i+1]);
        if (settings.data[i].equals("savePoints")) savePoints = setBoolean(settings.data[i+1]);
        //if (settings.data[i].equals("saveJson")) saveJson = setBoolean(settings.data[i+1]);
        if (settings.data[i].equals("saveJsx")) saveJsx = setBoolean(settings.data[i+1]);
        if (settings.data[i].equals("saveMaya")) saveMaya = setBoolean(settings.data[i+1]);
        if (settings.data[i].equals("sW")) sW = setInt(settings.data[i+1]);
        if (settings.data[i].equals("sH")) sH = setInt(settings.data[i+1]);
        if (settings.data[i].equals("sD")) sD = setFloat(settings.data[i+1]);
        if (settings.data[i].equals("dW")) dW = setInt(settings.data[i+1]);
        if (settings.data[i].equals("dH")) dH = setInt(settings.data[i+1]);
        if (settings.data[i].equals("fps")) fps = setInt(settings.data[i+1]);
        if (settings.data[i].equals("previewLevel")) previewLevel = setInt(settings.data[i+1]);
        if (settings.data[i].equals("motionBlur")) motionBlur = setBoolean(settings.data[i+1]);
        if (settings.data[i].equals("applyEffects")) applyEffects = setBoolean(settings.data[i+1]);
        if (settings.data[i].equals("smoothNum")) smoothNum = setInt(settings.data[i+1]);
       }
    } 
    catch(Exception e) {
      println("Couldn't load settings file. Using defaults.");
    }
  }

  int setInt(String _s) {
    return int(_s);
  }

  float setFloat(String _s) {
    return float(_s);
  }

  boolean setBoolean(String _s) {
    return boolean(_s);
  }
  
  String setString(String _s) {
    return ""+(_s);
  }
  
  String[] setStringArray(String _s) {
    int commaCounter=0;
    for(int j=0;j<_s.length();j++){
          if (_s.charAt(j)==char(',')){
            commaCounter++;
          }      
    }
    //println(commaCounter);
    String[] buildArray = new String[commaCounter+1];
    commaCounter=0;
    for(int k=0;k<buildArray.length;k++){
      buildArray[k] = "";
    }
    for (int i=0;i<_s.length();i++) {
        if (_s.charAt(i)!=char(' ') && _s.charAt(i)!=char('(') && _s.charAt(i)!=char(')') && _s.charAt(i)!=char('{') && _s.charAt(i)!=char('}') && _s.charAt(i)!=char('[') && _s.charAt(i)!=char(']')) {
          if (_s.charAt(i)==char(',')){
            commaCounter++;
          }else{
            buildArray[commaCounter] += _s.charAt(i);
         }
       }
     }
     println(buildArray);
     return buildArray;
  }

  color setColor(String _s) {
    color endColor = color(0);
    int commaCounter=0;
    String sr = "";
    String sg = "";
    String sb = "";
    String sa = "";
    int r = 0;
    int g = 0;
    int b = 0;
    int a = 0;

    for (int i=0;i<_s.length();i++) {
        if (_s.charAt(i)!=char(' ') && _s.charAt(i)!=char('(') && _s.charAt(i)!=char(')')) {
          if (_s.charAt(i)==char(',')){
            commaCounter++;
          }else{
          if (commaCounter==0) sr += _s.charAt(i);
          if (commaCounter==1) sg += _s.charAt(i);
          if (commaCounter==2) sb += _s.charAt(i); 
          if (commaCounter==3) sa += _s.charAt(i);
         }
       }
     }

    if (sr!="" && sg=="" && sb=="" && sa=="") {
      r = int(sr);
      endColor = color(r);
    }
    if (sr!="" && sg!="" && sb=="" && sa=="") {
      r = int(sr);
      g = int(sg);
      endColor = color(r, g);
    }
    if (sr!="" && sg!="" && sb!="" && sa=="") {
      r = int(sr);
      g = int(sg);
      b = int(sb);
      endColor = color(r, g, b);
    }
    if (sr!="" && sg!="" && sb!="" && sa!="") {
      r = int(sr);
      g = int(sg);
      b = int(sb);
      a = int(sa);
      endColor = color(r, g, b, a);
    }
      return endColor;
  }
}

