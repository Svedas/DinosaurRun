
class CPPNConnection {
  
  // Properties
  
  float weight;
  boolean isEnabled;
  
  CPPNNode nodeFrom;
  CPPNNode nodeTo;
  
  int innovationNumber;
  
  CPPNConnection(CPPNNode _nodeFrom, CPPNNode _nodeTo, float _weight, int _innovationNumber) {
    nodeFrom = _nodeFrom;
    nodeTo = _nodeTo;
    weight = _weight;
    isEnabled = true;
    innovationNumber = _innovationNumber;
  }
  
  // Methods
  
  void mutate() {
    float p = random(1);
    
    if (p < probabilityForAcuteMutation) {
      weight = random(-1, 1);
    } else {
      weight += randomGaussian()/50;
      weight = constrain(weight, -1, 1);
    }
  }
  
  CPPNConnection clone(CPPNNode _nodeFrom, CPPNNode  _nodeTo) {
    CPPNConnection clone = new CPPNConnection(_nodeFrom, _nodeTo, weight, innovationNumber);
    clone.isEnabled = isEnabled;

    return clone;
  }
}
