
class Connection {
 
  // Properties
  
  float weight;
  boolean isEnabled;
  
  Node nodeFrom;
  Node nodeTo;
  
  int innovationNumber;
  
  Connection(Node _nodeFrom, Node _nodeTo, float _weight, int _innovationNumber) {
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
  
  Connection clone(Node _nodeFrom, Node  _nodeTo) {
    Connection clone = new Connection(_nodeFrom, _nodeTo, weight, innovationNumber);
    clone.isEnabled = isEnabled;

    return clone;
  }
  
  //Connection clone() {
  //  Connection clone = new Connection(nodeFrom, nodeTo, weight, innovationNumber);
  //  clone.isEnabled = isEnabled;

  //  return clone;
  //}
}
