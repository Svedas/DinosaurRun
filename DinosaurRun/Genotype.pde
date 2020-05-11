
class Genotype {
 
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
  
  Genotype(int _nInputs, int _nOutputs, boolean crossover) {
    nInputs = _nInputs;
    nOutputs = _nOutputs;
    layers = 2;
  }
  
  Genotype(int _nInputs, int _nOutputs) {
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
  
  void mutate() {
    if (connections.isEmpty()) {
      addConnection();
    }

    float p = random(1);
    if (p < probabilityToMutateWeight) { 
      for (Connection connection : connections) {
        connection.mutate();
      }
    }
    
    p = random(1);
    if (p < probabilityToAddConnection) {
      addConnection();
    }

    p = random(1);
    if (p < probabilityToAddNode) {
      addNode();
    }
  }
  
  boolean isBadConnection(Node a, Node b) {
    if (a.layer == b.layer || a.isConnectedTo(b)) {
      return true; 
    }
    return false;
  }
  
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  void addNode() {
    if (connections.isEmpty()) {
      addConnection(); 
      return;
    }
    
    Connection randomConnection;
    do {
       int randomConnectionIndex = floor(random(connections.size()));
       randomConnection = connections.get(randomConnectionIndex);
    } while (randomConnection.nodeFrom == nodes.get(biasNodeIndex) && connections.size() != 1);

    randomConnection.isEnabled = false;

    int newNodeIndex = nextNodeIndex;
    nodes.add(new Node(newNodeIndex));
    Node newNode = getNode(newNodeIndex);
    newNode.layer = randomConnection.nodeFrom.layer + 1;
    nextNodeIndex++;
    
    // Connection from left to new node, weight 1
    int connectionInnovationNumber = innovationManager.getInnovationNumber(this, randomConnection.nodeFrom, newNode);
    connections.add(new Connection(randomConnection.nodeFrom, newNode, 1, connectionInnovationNumber));

    // Connection from from new to right node, old weight
    connectionInnovationNumber = innovationManager.getInnovationNumber(this, newNode, randomConnection.nodeTo);
    connections.add(new Connection(newNode, randomConnection.nodeTo, randomConnection.weight, connectionInnovationNumber));

    // Connection from bias to new node, weight 0 
    connectionInnovationNumber = innovationManager.getInnovationNumber(this, nodes.get(biasNodeIndex), newNode);
    connections.add(new Connection(nodes.get(biasNodeIndex), newNode, 0, connectionInnovationNumber));

    // Check if a new layer is needed
    if (newNode.layer == randomConnection.nodeTo.layer) {
      // For all exept the newest
      for (Node node : nodes.subList(0, nodes.size() - 1) ) {
        if (node.layer >= newNode.layer) {
          node.layer++;
        }
      }
      layers++;
    }
    connectNodes();
  }

  void addConnection() {
    if (isFullyConnected()) {
      println("Genotype Network is full");
      return;
    }

    Node firstNode;
    Node secondNode;
    do {
      int firstNodeIndex = floor(random(nodes.size())); 
      int secondNodeIndex = floor(random(nodes.size()));
      
      firstNode = nodes.get(firstNodeIndex);
      secondNode = nodes.get(secondNodeIndex);
    
    } while (isBadConnection(firstNode, secondNode));
    
    Node temp;                                             // TODO: Check this swap
    if (firstNode.layer > secondNode.layer) {
      temp = secondNode.clone();  ;
      secondNode = firstNode.clone();
      firstNode = temp.clone();
    }    
 
    int connectionInnovationNumber = innovationManager.getInnovationNumber(this, firstNode, secondNode);
    connections.add(new Connection(firstNode, secondNode, random(-1, 1), connectionInnovationNumber));
    connectNodes();
  }
  
  ///////////////////////////////////////////////////////////////////
  
  Genotype crossover(Genotype parent) {
    Genotype offspring = new Genotype(nInputs, nOutputs, true);
    offspring.layers = layers;
    offspring.nextNodeIndex = nextNodeIndex;
    offspring.biasNodeIndex = biasNodeIndex;
    
    ArrayList<Connection> offspringConnections = new ArrayList<Connection>();
    ArrayList<Boolean> enabledConnections = new ArrayList<Boolean>(); // TODO: Naming
    
    float p;
    for (Connection connection : connections) {
      boolean shouldBeEnabled = true;//is this node in the chlid going to be enabled

      Connection matchingConnectionFromParent = connectionFromParentWithInnovationNumber(parent, connection.innovationNumber);
      if (matchingConnectionFromParent != null) {
        if (!connection.isEnabled || !matchingConnectionFromParent.isEnabled) {
          p = random(1);
          if (p < probabilityToDisableChildConnection) {
            shouldBeEnabled = false;
          }
        }
        
        // Dominant parent
        p = random(1);
        if (p < probabilityToGetConnectionFromFirstParent) {
          offspringConnections.add(connection);
        } else {
          offspringConnections.add(matchingConnectionFromParent);
        }
        
      } else {
        offspringConnections.add(connection);
        shouldBeEnabled = connection.isEnabled;
      }
      enabledConnections.add(shouldBeEnabled);
    }

    for (Node node : nodes) {
      offspring.nodes.add(node.clone());
    }

    //for (int i = 0; i < offspringConnections.size(); i++) {
    //  Connection hereditaryConnection = offspringConnections.get(i).clone();
    //  offspring.connections.add(hereditaryConnection);
      
    //  offspring.connections.get(i).isEnabled = enabledConnections.get(i);
    //}
    
    for (int i = 0; i < offspringConnections.size(); i++) {
      offspring.connections.add(
        offspringConnections.get(i).clone(
          offspring.getNode(offspringConnections.get(i).nodeFrom.number), 
          offspring.getNode(offspringConnections.get(i).nodeTo.number)));     
      offspring.connections.get(i).isEnabled = enabledConnections.get(i);
      // TODO: better solution
    }

    offspring.connectNodes();
    return offspring;
  }
  
  Connection connectionFromParentWithInnovationNumber(Genotype parent, int innovationNumber) {
    for (Connection connection : parent.connections) {
      if (connection.innovationNumber == innovationNumber) {
        return connection;
      }
    }
    return null; //no matching connection
  }
  
  Genotype clone() {
    Genotype clone = new Genotype(nInputs, nOutputs, true);

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
