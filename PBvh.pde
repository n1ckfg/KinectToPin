class PBvh{
  BvhParser parser;  
  PVector scaleFactor = new PVector(1,1,1);
  PVector offset = new PVector(0,0,0);
  ArrayList bonePoints;
  
  PBvh(String[] data, PVector _sf, PVector _ofs){
    parser = new BvhParser();
    parser.init();
    parser.parse(data);
    scaleFactor = _sf;
    offset = _ofs;
  }
  
  void update(int ms){
    parser.moveMsTo(ms);//30-sec loop 
    parser.update();
    draw();
  }
  
  void draw(){
    fill(255);
    
     bonePoints = new ArrayList();
    
    for(BvhBone b : parser.getBones()){
      pushMatrix();
      translate((b.absPos.x * scaleFactor.x) + offset.x, (b.absPos.y * scaleFactor.y) + offset.y, (b.absPos.z * scaleFactor.z) + offset.z);
      ellipse(0, 0, 2, 2);
      popMatrix();
      if (!b.hasChildren()){
        pushMatrix();
        translate((b.absEndPos.x * scaleFactor.x) + offset.x, (b.absEndPos.y * scaleFactor.y) + offset.y, (b.absEndPos.z * scaleFactor.z) + offset.z);
        ellipse(0, 0, 10, 10);
        popMatrix();
      }

      float x = (sW/2) + b.getAbsPosition().x;
      float y = (sH/2) + (-1* b.getAbsPosition().y);
      float z = (sD/1.75) + b.getAbsPosition().z;

      println("/*"+b.getName()+"*/ " + "point(" + x + ", " + y + ", " + z + ");");
      PVector p = new PVector(x,y,z);
      bonePoints.add(p);
    }
    
    for(int i=0;i<bonePoints.size();i++){
      PVector p = (PVector) bonePoints.get(i);
      fill(255,0,0);
      pushMatrix();
      translate(p.x,p.y,p.z);
      ellipseMode(CENTER);
      ellipse(0,0,2,2);
      popMatrix();
    }
  }

}
