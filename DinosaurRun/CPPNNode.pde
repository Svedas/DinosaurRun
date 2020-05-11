
class CPPNNode {
  
  // Properties
  
  int number;
  ActivationFunction activationFunction;
  
  float input;
  float output;
  
  int layer;
  
  ArrayList<CPPNConnection> outputConnections = new ArrayList<CPPNConnection>();

  CPPNNode(int _number) {
    number = _number;
    layer = 0;
    //activationFunction = new Sigmoid();
    pickActivationFunction();
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
    
    for (CPPNConnection connection : outputConnections) {
      if (connection.isEnabled) {
        connection.nodeTo.appendInput(connection.weight * output);
      }
    }
  }
  
  boolean isConnectedTo(CPPNNode node) {
    if (this.layer == node.layer) {
      return false;
    }

    if (this.layer > node.layer) {
      for (CPPNConnection connection : node.outputConnections) {
        if (connection.nodeTo == this) { return true; }
      }
    } else {
      for (CPPNConnection connection : this.outputConnections) {
        if (connection.nodeTo == node) { return true; }
      }
    }
    return false;
  }
  
  void pickActivationFunction() {
    ActivationFunctions function = randomEnum(ActivationFunctions.class);

    switch (function) {
    case Sine:
      activationFunction = new Sine();
      break;
    case Sigmoid:
      activationFunction = new Sigmoid();
      break;
    case Cosine:
      activationFunction = new Cosine();
      break;
    case Square:
      activationFunction = new Square();
      break;
    case Gaussian:
      activationFunction = new Gaussian();
      break;
    case Absolute:
      activationFunction = new Absolute();
      break;
    case AbsoluteRoot:
      activationFunction = new AbsoluteRoot();
      break;
    case Linear:
      activationFunction = new Linear();
      break;
    case Tanh:
      activationFunction = new Tanh();
      break;
    }
  }
  
  CPPNNode clone() {
    CPPNNode clone = new CPPNNode(number);
    clone.layer = layer;
    return clone;
  }
}
