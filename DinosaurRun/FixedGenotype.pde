
class FixedGenotype {
  
  // Properties 
  
  ArrayList<Node> nodes = new ArrayList<Node>();
  ArrayList<Connection> connections = new ArrayList<Connection>();
  
  int nInputs;  // number of inputs
  int nOutputs;
  
  int layers;
  
  int nextNodeIndex = 0;
  int biasNodeIndex;

  ArrayList<Node> network = new ArrayList<Node>();
  
  // Constructors
  
  FixedGenotype(int _nInputs, int _nOutputs, boolean crossover) {
    nInputs = _nInputs;
    nOutputs = _nOutputs;
    layers = 2;
  }
  
  FixedGenotype(int _nInputs, int _nOutputs) {
    nInputs = _nInputs;
    nOutputs = _nOutputs;
    layers = 2;
    
    for (int i = 0; i < nInputs; i++) {
      nodes.add(new Node(i));
      nodes.get(i).layer = 0;
      nextNodeIndex++;
    }
    
    for (int i = 0; i < nOutputs; i++) {
      nodes.add(new Node(i + nInputs));
      nodes.get(i + nInputs).layer = 1;
      nextNodeIndex++;
    }
    
    nodes.add(new Node(nextNodeIndex));
    nodes.get(nextNodeIndex).layer = 0;
    biasNodeIndex = nextNodeIndex; 
    nextNodeIndex++;
  }
  
  // Methods
  
  void addConnection(Node nodeFrom, Node nodeTo, float weight) {
    if (isFullyConnected()) {
      println("FixedGenotype Network is full");
      return;
    }

    Node firstNode = nodes.get(nodeFrom.number);
    Node secondNode = nodes.get(nodeTo.number);   
 
    connections.add(new Connection(firstNode, secondNode, weight, 0));
    connectNodes();
  }
  
  // Methods
  
  Node getNode(int nodeNumber) {
    for (Node node : nodes) {
      if (node.number == nodeNumber) {
        return node;
      }
    }
    return null;
  }
  
  void connectNodes() {
    for (Node node : nodes) {
      node.outputConnections.clear();
    }

    for (Connection connection : connections) {
      connection.nodeFrom.outputConnections.add(connection);
    }
  }
  
  void generateNetwork() {
    connectNodes();
    network = new ArrayList<Node>();
    
    for (int layer = 0; layer < layers; layer++) {
      for (Node node : nodes) {
        if (node.layer == layer) {
          network.add(node);
        }
      }
    }
  }
  
  boolean isFullyConnected() {
    int maxConnections = 0;
    int[] nodesInLayer = new int[layers];

    for (Node node : nodes) {
      nodesInLayer[node.layer]++;
    }

    for (int i = 0; i < layers - 1; i++) {
      int nodesInHigherLayer = 0;
      for (int j = i + 1; j < layers; j++) {
        nodesInHigherLayer += nodesInLayer[j];
      }
      maxConnections += nodesInLayer[i] * nodesInHigherLayer;
    }

    if (maxConnections == connections.size()) {
      return true;
    }
    return false;
  }
  
  ///////////////////////////////
  // ANN Functionality Methods //
  
  float[] feedForward(float[] inputs) {  
    for (int i = 0; i < nInputs; i++) {
      nodes.get(i).output = inputs[i];
    }
    nodes.get(biasNodeIndex).output = 1;

    for (Node node : network) {
      node.activate();
    }

    float[] outputs = new float[nOutputs];
    for (int i = 0; i < nOutputs; i++) {
      outputs[i] = nodes.get(nInputs + i).output;
    }

    for (Node node : nodes) {
      node.resetInput();
    }

    return outputs;
  }
  
  ///////////////////////////////////////////////////////////////////
  
  FixedGenotype clone() {
    FixedGenotype clone = new FixedGenotype(nInputs, nOutputs, true);

    for (Node node : nodes) {
      clone.nodes.add(node.clone());
    }

    for (Connection connection : connections) {
      Connection toBeAdded = connection.clone(clone.getNode(connection.nodeFrom.number), clone.getNode(connection.nodeTo.number));
      //Connection toBeAdded = connection.clone();
      clone.connections.add(toBeAdded);
    }

    clone.layers = layers;
    clone.nextNodeIndex = nextNodeIndex;
    clone.biasNodeIndex = biasNodeIndex;
    clone.connectNodes();

    return clone;
  }
}
