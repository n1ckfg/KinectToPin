import java.util.ArrayList;
import java.util.List;
import processing.core.PMatrix3D;
import processing.core.PVector;

class BvhBone {

  String _name;
  
  PVector absPos = new PVector();
  PVector absEndPos = new PVector();
  
  float _offsetX = 0;
  float _offsetY = 0;
  float _offsetZ = 0;
  
  int _nbChannels;
  List<String> _channels;
  
  float _endOffsetX = 0;
  float _endOffsetY = 0;
  float _endOffsetZ = 0;
  
  BvhBone _parent;
  List<BvhBone> _children;
  
  float _Xposition = 0;
  float _Yposition = 0;
  float _Zposition = 0;
  float _Xrotation = 0;
  float _Yrotation = 0;
  float _Zrotation = 0;
  
  PMatrix3D global_matrix;
  
  BvhBone(BvhBone __parent) 
  {
    _parent = __parent;
    _channels = new ArrayList<String>();
    _children = new ArrayList<BvhBone>();
  }
  
  BvhBone()
  {
    _parent = null;
    _channels = new ArrayList<String>();
    _children = new ArrayList<BvhBone>();
  }
  
  String toString() 
  {
    return "[BvhBone] " + _name;
  }
  
  String structureToString()
  {
    return structureToString(0);
  }
  
  String structureToString(int __indent)
  {
    String res = "";
    for (int i = 0; i < __indent; i++)
      res += "=";
    
    res = res + "> " + _name + "  " + _offsetX + " " + _offsetY+ " " + _offsetZ + "\n";
    for (BvhBone child : _children)
    res += child.structureToString(__indent+1);
    
    return res;
  }
  
  String getName()
  {
    return _name;
  }
  
  void setName( String value)
  {
    _name = value;
  }
  
  Boolean isRoot()
  {
    return (_parent == null);
  }
  
  Boolean hasChildren()
  {
    return _children.size() > 0;
  }
  
  
  List<BvhBone> getChildren()
  {
    return _children;
  }
  
  void setChildren(List<BvhBone> value)
  {
    _children = value;
  }
  
  BvhBone getParent()
  {
    return _parent;
  }
  
  
  void setParent(BvhBone value)
  {
    _parent = value;
  }
  
  List<String> getChannels()
  {
    return _channels;
  }
  
  void setChannels(List<String> value)
  {
    _channels = value;
  }
  
  int getNbChannels()
  {
    return _nbChannels;
  }
  
  void setnbChannels( int value )
  {
    _nbChannels = value;
  }
  
  //------ position
  
  float getZrotation()
  {
    return _Zrotation;
  }
  
  void setZrotation(float value)
  {
    _Zrotation = value;
  }
  
  float getYrotation()
  {
    return _Yrotation;
  }
  
  
  void setYrotation(float value)
  {
    _Yrotation = value;
  }
  
  float getXrotation()
  {
    return _Xrotation;
  }
  
  
  void setXrotation(float value)
  {
    _Xrotation = value;
  }
  
  
  
  float getZposition()
  {
    return _Zposition;
  }
  
  void setZposition(float value)
  {
    _Zposition = value;
  }
  
  float getYposition()
  {
    return _Yposition;
  }
  
  void setYposition(float value)
  {
    _Yposition = value;
  }
  
  float getXposition()
  {
    return _Xposition;
  }
  
  void setXposition(float value)
  {
    _Xposition = value;
  }
  
  float getEndOffsetZ()
  {
    return _endOffsetZ;
  }
  void setEndOffsetZ(float value)
  {
    _endOffsetZ = value;
  }
  
  float getEndOffsetY()
  {
    return _endOffsetY;
  }
  
  void setEndOffsetY(float value)
  {
    _endOffsetY = value;
  }
  
  float getEndOffsetX()
  {
    return _endOffsetX;
  }
  
  void setEndOffsetX(float value)
  {
    _endOffsetX = value;
  }
  
  float getOffsetZ()
  {
    return _offsetZ;
  }
  
  void setOffsetZ(float value)
  {
    _offsetZ = value;
  }
  
  float getOffsetY()
  {
    return _offsetY;
  }
  
  void setOffsetY(float value)
  {
    _offsetY = value;
  }
  
  float getOffsetX()
  {
    return _offsetX;
  }
  
  void setOffsetX(float value)
  {
    _offsetX = value;
  }

  void setAbsPosition(PVector pos) {
    absPos = pos;
  }  
  
  PVector getAbsPosition()
  {
    return absPos;
  }
  

  void setAbsEndPosition( PVector pos)
  {
    absEndPos = pos;
  }
  
  PVector getAbsEndPosition()
  {
    return absEndPos;
  }
}
