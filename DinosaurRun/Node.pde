
class Node {
  
  // Properties
  
  int number;
  ActivationFunction activationFunction = new Sigmoid();
  
  float input;
  float output;
  
  int layer;
  
  ArrayList<Connection> outputConnections = new ArrayList<Connection>();

  Node(int _number) {
    number = _number;
    layer = 0;
  }
  
  // Methods
  
  void appendInput(float value) {
    input += value;
  }
  
  void resetInput() {
    input = 0;
  }
  
  void activate() {
    if (layer != 0) {
      output = activationFunction.activate(input);
    }
    
    for (Connection connection : outputConnections) {
      if (connection.isEnabled) { //<>//
        connection.nodeTo.appendInput(connection.weight * output);
      }
    }
  }
  
  boolean isConnectedTo(Node node) {
    if (this.layer == node.layer) {
      return false;
    }

    if (this.layer > node.layer) {
      for (Connection connection : node.outputConnections) {
        if (connection.nodeTo == this) { return true; }
      }
    } else {
      for (Connection connection : this.outputConnections) {
        if (connection.nodeTo == node) { return true; }
      }
    }
    return false;
  }
  
  Node clone() {
    Node clone = new Node(number);
    clone.layer = layer;
    return clone;
  }
}
