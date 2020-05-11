
class InnovationManager {

  // Properties
  
  ArrayList<InnovationHistory> innovationHistory = new ArrayList<InnovationHistory>();
  int nextConnectionNumber = 1000;
  
  private InnovationManager() {} 
  
  // Methods
  
  // DNT
  
  int getInnovationNumber(Genotype genotype, Node nodeFrom, Node nodeTo) {
    boolean isNew = true;
    int connectionInnovationNumber = nextConnectionNumber;
    
    for (InnovationHistory innovation : innovationHistory) {
      if (innovation.matches(genotype, nodeFrom, nodeTo)) {
        isNew = false;
        connectionInnovationNumber = innovation.innovationNumber;
        break;
      }
    }

    if (isNew) {
      ArrayList<Integer> newInnovationNumbers = new ArrayList<Integer>();
      
      for (Connection connection : genotype.connections) {
        newInnovationNumbers.add(connection.innovationNumber);
      }

      innovationHistory.add(new InnovationHistory(nodeFrom.number, nodeTo.number, connectionInnovationNumber, newInnovationNumbers));
        
      nextConnectionNumber++;
    }
    return connectionInnovationNumber;
  }
  
  // CPPN 
  
  int getInnovationNumber(CPPN cppn, CPPNNode nodeFrom, CPPNNode nodeTo) {
    boolean isNew = true;
    int connectionInnovationNumber = nextConnectionNumber;
    
    for (InnovationHistory innovation : innovationHistory) {
      if (innovation.matches(cppn, nodeFrom, nodeTo)) {
        isNew = false;
        connectionInnovationNumber = innovation.innovationNumber;
        break;
      }
    }

    if (isNew) {
      ArrayList<Integer> newInnovationNumbers = new ArrayList<Integer>();
      
      for (CPPNConnection connection : cppn.connections) {
        newInnovationNumbers.add(connection.innovationNumber);
      }

      innovationHistory.add(new InnovationHistory(nodeFrom.number, nodeTo.number, connectionInnovationNumber, newInnovationNumbers));
        
      nextConnectionNumber++;
    }
    return connectionInnovationNumber;
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class InnovationHistory {
  int fromNode;
  int toNode;
  int innovationNumber;

  ArrayList<Integer> innovationNumbers = new ArrayList<Integer>();

  InnovationHistory(int _fromNode, int _toNode, int _innovationNumber, ArrayList<Integer> _innovationNumbers) {
    fromNode = _fromNode;
    toNode = _toNode;
    innovationNumber = _innovationNumber;
    innovationNumbers = (ArrayList)_innovationNumbers.clone();
  }
  
  // DNT
  
  boolean matches(Genotype genotype, Node from, Node to) {
    if (genotype.connections.size() == innovationNumbers.size()) { 
      
      if (from.number == fromNode && to.number == toNode) {
        for (Connection connection : genotype.connections) {
          if (!innovationNumbers.contains(connection.innovationNumber)) {
            return false;
          }
        }
        return true;
      }
    }
    return false;
  }
  
  // CPPN
  
  boolean matches(CPPN cppn, CPPNNode from, CPPNNode to) {
    if (cppn.connections.size() == innovationNumbers.size()) {       
      if (from.number == fromNode && to.number == toNode) {
        for (CPPNConnection connection : cppn.connections) {
          if (!innovationNumbers.contains(connection.innovationNumber)) {
            return false;
          }
        }
        return true;
      }
    }
    return false;
  }
}
