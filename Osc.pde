void oscSetup() {
    oscP5 = new OscP5(this, receivePort);
    myRemoteLocation = new NetAddress(ipNumber, sendPort);
    if(oscLocalEcho) myRemoteLocationEcho = new NetAddress("127.0.0.1", sendPort); 
}

void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/joint") && msg.checkTypetag("sifff")) {
    found = true;
    for (int i=0;i<osceletonNames.length;i++) {
      if (modeOsc&&msg.get(0).stringValue().equals(osceletonNames[i])) {
        x[i] = msg.get(2).floatValue();
        y[i] = msg.get(3).floatValue();
        z[i] = msg.get(4).floatValue();
      }
    }
  }
}

void oscSendHandler(OscMessage _myMessage){
  try{
    oscP5.send(_myMessage, myRemoteLocation);
  }catch(Exception e){ }
  
  try{
  if(oscLocalEcho){
    oscP5.send(_myMessage, myRemoteLocationEcho);
  }
  }catch(Exception e){ }
}

void oscSend(int skel) {
    OscMessage myMessage;

    int counter = 0;
    
    for (int i=0;i<osceletonNames.length;i++) {
      try{
      if(oscChannelFormat.equals("Isadora")){     
      counter++;
      myMessage = new OscMessage("/isadora/"+counter); // x
      myMessage.add(x[i]);
      oscSendHandler(myMessage); 

      counter++;
      myMessage = new OscMessage("/isadora/"+counter); // x
      myMessage.add(y[i]);
      oscSendHandler(myMessage);

      counter++;
      myMessage = new OscMessage("/isadora/"+counter); // x
      myMessage.add(z[i]);
      oscSendHandler(myMessage);

       }else if(oscChannelFormat.equals("OSCeleton")){
        myMessage = new OscMessage("/joint"); // x
        myMessage.add(osceletonNames[i]);
        myMessage.add(skel);
        myMessage.add(x[i]);
        myMessage.add(y[i]);
        myMessage.add(z[i]);
        oscSendHandler(myMessage);
      }
      println("Sending OSC, format \""+ oscChannelFormat +"\", to " + myRemoteLocation + " " + osceletonNames[i] + " x: " + x[i] + " y: " + y[i] + " z: " + z[i]);
   }catch(Exception e){ }
    }
}

