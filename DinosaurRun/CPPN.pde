
class CPPN {
  
  // Properties
  
  int playerIndex;
  
  ArrayList<CPPNNode> nodes = new ArrayList<CPPNNode>();
  ArrayList<CPPNConnection> connections = new ArrayList<CPPNConnection>();
  
  int nInputs = 4;  // hepercube
  int nOutputs = 1;
  
  int layers;
  
  int nextNodeIndex = 0;
  int biasNodeIndex;

  ArrayList<CPPNNode> network = new ArrayList<CPPNNode>();
  
  // Constructors
  
  CPPN(int _nInputs, int _nOutputs, boolean isCrossover) {
    nInputs = _nInputs;
    nOutputs = _nOutputs;
    layers = 2;
  }
  
  CPPN(int _nInputs, int _nOutputs, int _playerIndex) {
    nInputs = _nInputs;
    nOutputs = _nOutputs;
    layers = 2;
    playerIndex = _playerIndex;
    
    for (int i = 0; i < nInputs; i++) {
      nodes.add(new CPPNNode(i));
      nodes.get(i).layer = 0;
      nextNodeIndex++;
    }
    
    for (int i = 0; i < nOutputs; i++) {
      nodes.add(new CPPNNode(i + nInputs));
      nodes.get(i + nInputs).layer = 1;
      nextNodeIndex++;
    }
    
    nodes.add(new CPPNNode(nextNodeIndex));
    nodes.get(nextNodeIndex).layer = 0;
    biasNodeIndex = nextNodeIndex; 
    nextNodeIndex++;
  }
  
  // Methods
  
  CPPNNode getNode(int nodeNumber) {
    for (CPPNNode node : nodes) {
      if (node.number == nodeNumber) {
        return node;
      }
    }
    return null;
  }
  
  void connectNodes() {
    for (CPPNNode node : nodes) {
      node.outputConnections.clear();
    }

    for (CPPNConnection connection : connections) {
      connection.nodeFrom.outputConnections.add(connection);
    }
  }
  
  void generateNetwork() {
    connectNodes();
    network = new ArrayList<CPPNNode>();
    
    for (int layer = 0; layer < layers; layer++) {
      for (CPPNNode node : nodes) {
        if (node.layer == layer) {
          network.add(node);
        }
      }
    }
  }
  
  boolean isFullyConnected() {
    int maxConnections = 0;
    int[] nodesInLayer = new int[layers];

    for (CPPNNode node : nodes) {
      if (layers + 1 > node.layer) {
        nodesInLayer[node.layer]++;
      } else {
        println("Error, array out of bounds.");
      }
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
  
  float feedForward(float[] inputs) {  
    for (int i = 0; i < nInputs; i++) {
      nodes.get(i).output = inputs[i];
    }
    nodes.get(biasNodeIndex).output = 1;

    for (CPPNNode node : network) {
      node.activate();
    }

    float output = 0;
    for (int i = 0; i < nOutputs; i++) {
      output = nodes.get(nInputs + i).output;
    }

    for (CPPNNode node : nodes) {
      node.resetInput();
    }

    return output;
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  /* Substrate
  
        *  *  *  *  *  *  *  *  *  *      *
        *  *  *  *  *  *  *  *  *  *  ->  *
        *  *  *  *  *  *  *  *  *  *      *
        *
  
  */
  
  void makeDNT(FixedGenotype fixedGenotype) {
    for (int j = 0; j < screenCollumns; j++) {
      for (int i = 0; i < screenRows; i++) {
        for (int k = 0; k < 3; k++) {
          float[] transformedArray = new float[]{ map(i+1, 1, screenRows, -1, 1) , map(j+1, 1, screenCollumns, -1, 1) , 0 , k };
          float output = feedForward( transformedArray );
          if (output != 0) {
            fixedGenotype.addConnection(
              fixedGenotype.nodes.get(i + j * screenRows ), 
              fixedGenotype.nodes.get(k + screenRows*screenCollumns), 
              output);   
          }
        }
      }
    }
    
    for (int i = 0; i < 3; i++) {
      float output = feedForward( new float[]{-1, 1, 0, i} ); //map(k+1, 1, 3, -1, 1) (0,3) -> (-1,1)
        fixedGenotype.addConnection(
          fixedGenotype.nodes.get(3 + screenRows*screenCollumns), 
          fixedGenotype.nodes.get(i + screenRows*screenCollumns), 
          output);
    }
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  void mutate() {
    if (connections.isEmpty()) {
      addConnection();
    }

    float p = random(1);
    if (p < probabilityToMutateWeight) { 
      for (CPPNConnection connection : connections) {
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
  
  boolean isBadConnection(CPPNNode a, CPPNNode b) {
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
    
    CPPNConnection randomConnection;
    do {
       int randomConnectionIndex = floor(random(connections.size()));
       randomConnection = connections.get(randomConnectionIndex);
    } while (randomConnection.nodeFrom == nodes.get(biasNodeIndex) && connections.size() != 1);

    randomConnection.isEnabled = false;

    int newNodeIndex = nextNodeIndex;
    nodes.add(new CPPNNode(newNodeIndex));
    CPPNNode newNode = getNode(newNodeIndex);
    newNode.layer = randomConnection.nodeFrom.layer + 1;
    nextNodeIndex++;
    
    // Connection from left to new node, weight 1
    int connectionInnovationNumber = innovationManager.getInnovationNumber(this, randomConnection.nodeFrom, newNode);
    connections.add(new CPPNConnection(randomConnection.nodeFrom, newNode, 1, connectionInnovationNumber));

    // Connection from from new to right node, old weight
    connectionInnovationNumber = innovationManager.getInnovationNumber(this, newNode, randomConnection.nodeTo);
    connections.add(new CPPNConnection(newNode, randomConnection.nodeTo, randomConnection.weight, connectionInnovationNumber));

    // Connection from bias to new node, weight 0 
    connectionInnovationNumber = innovationManager.getInnovationNumber(this, nodes.get(biasNodeIndex), newNode);
    connections.add(new CPPNConnection(nodes.get(biasNodeIndex), newNode, 0, connectionInnovationNumber));

    // Check if a new layer is needed
    if (newNode.layer == randomConnection.nodeTo.layer) {
      // For all exept the newest
      for (CPPNNode node : nodes.subList(0, nodes.size() - 1) ) {
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
      println("CPPN Network is full");
      addNode();
      return;
    }

    CPPNNode firstNode;
    CPPNNode secondNode;
    do {
      int firstNodeIndex = floor(random(nodes.size())); 
      int secondNodeIndex = floor(random(nodes.size()));
      
      firstNode = nodes.get(firstNodeIndex);
      secondNode = nodes.get(secondNodeIndex);
    
    } while (isBadConnection(firstNode, secondNode));
    
    CPPNNode temp;
    if (firstNode.layer > secondNode.layer) {
      temp = secondNode.clone();  ;
      secondNode = firstNode.clone();
      firstNode = temp.clone();
    }    
 
    int connectionInnovationNumber = innovationManager.getInnovationNumber(this, firstNode, secondNode);
    connections.add(new CPPNConnection(firstNode, secondNode, random(-1, 1), connectionInnovationNumber));
    connectNodes();
  }
  
  ///////////////////////////////////////////////////////////////////
  
  CPPN crossover(CPPN parent) {
    CPPN offspring = new CPPN(nInputs, nOutputs, true);
    offspring.layers = layers;
    offspring.nextNodeIndex = nextNodeIndex;
    offspring.biasNodeIndex = biasNodeIndex;
    
    ArrayList<CPPNConnection> offspringConnections = new ArrayList<CPPNConnection>();
    ArrayList<Boolean> enabledConnections = new ArrayList<Boolean>(); // TODO: Naming
    
    float p;
    for (CPPNConnection connection : connections) {
      boolean shouldBeEnabled = true; // Node in the child going to be enabled

      CPPNConnection matchingConnectionFromParent = connectionFromParentWithInnovationNumber(parent, connection.innovationNumber);
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

    for (CPPNNode node : nodes) {
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
  
  CPPNConnection connectionFromParentWithInnovationNumber(CPPN parent, int innovationNumber) {
    for (CPPNConnection connection : parent.connections) {
      if (connection.innovationNumber == innovationNumber) {
        return connection;
      }
    }
    return null;
  }
  
  CPPN clone() {
    CPPN clone = new CPPN(nInputs, nOutputs, true);

    for (CPPNNode node : nodes) {
      clone.nodes.add(node.clone());
    }

    for (CPPNConnection connection : connections) {
      CPPNConnection toBeAdded = connection.clone(clone.getNode(connection.nodeFrom.number), clone.getNode(connection.nodeTo.number));
      //CPPNConnection toBeAdded = connection.clone();
      clone.connections.add(toBeAdded);
    }

    clone.layers = layers;
    clone.nextNodeIndex = nextNodeIndex;
    clone.biasNodeIndex = biasNodeIndex;
    clone.connectNodes();

    return clone;
  }
}
