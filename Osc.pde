void oscSetup() {
  oscP5 = new OscP5(this, receivePort);
  myRemoteLocation = new NetAddress(ipNumber, sendPort);
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

void oscSend(int skel) {
    OscMessage myMessage;

    int counter = 0;
    
    for (int i=0;i<osceletonNames.length;i++) {
      if(oscChannelFormat.equals("Isadora")){     
      counter++;
      myMessage = new OscMessage("/isadora/"+counter); // x
      myMessage.add(x[i]);
      oscP5.send(myMessage, myRemoteLocation); 

      counter++;
      myMessage = new OscMessage("/isadora/"+counter); // x
      myMessage.add(y[i]);
      oscP5.send(myMessage, myRemoteLocation); 

      counter++;
      myMessage = new OscMessage("/isadora/"+counter); // x
      myMessage.add(z[i]);
      oscP5.send(myMessage, myRemoteLocation);

      println("Sending OSC to " + myRemoteLocation + " " + osceletonNames[i] + " x: " + x[i] + " y: " + y[i] + " z: " + z[i]);
      }else if(oscChannelFormat.equals("OSCeleton")){
        //OSCeleton-style message goes here
      }
   }
}

