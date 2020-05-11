
class Population {
  
  // Properties
  
  ArrayList<CPPN> CPPNs = new ArrayList<CPPN>();
  
  ArrayList<Dinosaur> population = new ArrayList<Dinosaur>();
  int populationSize;
  Dinosaur bestDinosaur;
  
  int generation;
  int bestScore;
  int populationLifespan;
  
  ArrayList<Dinosaur> generationDinosaurs = new ArrayList<Dinosaur>();
  ArrayList<Species> species = new ArrayList<Species>();
  
  Population(int size) {
    populationSize = size;
    if (isRunningNEAT) {
      for (int i = 0; i < size; i++) {
        population.add(new Dinosaur(nNetworkInputs));
        population.get(i).brain.mutate();
        bestDinosaur = new Dinosaur(nNetworkInputs);
      }
    } else { ////////////////////////////////////////////////////////////////////////////////////////////////////
      for (int i = 0; i < size; i++) {
        CPPNs.add(new CPPN(4, 1, i));
        CPPNs.get(i).generateNetwork();
        CPPNs.get(i).mutate();
        population.add(new Dinosaur(screenRows * screenCollumns));
        population.get(i).playerIndex = i;
        CPPNs.get(i).makeDNT(population.get(i).hyperBrain);
        
        bestDinosaur = population.get(i);
      }
      
      for (Dinosaur dinosaur : population) {
        //print(dinosaur.hyperBrain.connections.size(),"");
        dinosaur.reset();
      }
    }
  }
        
  boolean isDone() {
    for (Dinosaur dino : population) {
      if (!dino.isDead) {
        return false;
      }
    }
    return true;
  }
  
  void setBestDinosaur() {
    Dinosaur best =  species.get(0).getBestDinosaur();
    best.generation = generation;

    if (best.score > bestScore) {
      generationDinosaurs.add(best.clone());
      println("Old best score:", bestScore);
      println("New best score:", best.score);
      bestScore = best.score;
      bestDinosaur = best.clone();
    }
  }
  
  //////////
  // NEAT //
  
  void update() {
    for (Dinosaur dino : population) {
      if (!dino.isDead) {
        dino.gatherInfo();
        dino.decide();
        dino.update();
      }
    }
    populationLifespan++;
  }
  
  void naturalSelection() {
    speciate();
    
    calculateFitness();
    sortSpecies();
    
    exterminateTheWeakOfSpecies();
    setBestDinosaur();
    exterminateStaleSpecies();
    exterminateEmptySpecies();
    
    println("Generation", 
      generation, 
      "Number of mutations", 
      innovationManager.innovationHistory.size(), 
      "Species: " + species.size(), "Score: "+bestScore);
    
    repopulate();

    generation++;
    populationLifespan = 0;
    
    for (Dinosaur dinosaur : population) {
      //print(dinosaur.brain.connections.size(),"");
      dinosaur.reset();
    }
  }
  
  ///////////////
  // HyperNEAT //
  
  void hyperUpdate() {
    for (Dinosaur dino : population) {
      if (!dino.isDead) {
        dino.look();
        dino.decide();
        dino.update();
      }
    }
    populationLifespan++;
  }
  
  void hyperNaturalSelection() {
    speciate();
    
    calculateFitness();
    sortSpecies();
    
    exterminateTheWeakOfSpecies();
    setBestDinosaur();
    exterminateStaleSpecies();
    exterminateEmptySpecies();
    
    println("Generation", 
      generation, 
      "Number of mutations", 
      innovationManager.innovationHistory.size(), 
      "Species: " + species.size(), "Score: "+bestScore);
    
    roproduceCPPNs();
    
    population.clear();
    for (int i = 0; i < populationSize; i++) {
      population.add(new Dinosaur(screenRows * screenCollumns));
      CPPNs.get(i).makeDNT(population.get(i).hyperBrain);
      population.get(i).playerIndex = i;
    }

    generation++;
    populationLifespan = 0;
    
    for (Dinosaur dinosaur : population) {
      //print(dinosaur.hyperBrain.connections.size(),"");
      dinosaur.reset();
    }
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  void speciate() {
    for (Species s : species) {
      //s.speciesPopulation.subList(1, s.speciesPopulation.size()).clear();
      s.speciesPopulation.clear();
    }
    species.clear();
    
    for (Dinosaur dinosaur : population) {
      boolean isSpeciesFound = false;
      for (Species s : species) {
        if (isRunningNEAT) {
          if (s.isGenotypeFromSpecies(dinosaur.brain) ) {
            s.addToSpecies(dinosaur);
            isSpeciesFound = true;
            break;
          }
        } else {
          //if (s.isGenotypeFromSpecies(dinosaur.hyperBrain) ) {
          if (s.isGenotypeFromSpecies(CPPNs.get(dinosaur.playerIndex)) ) {
            s.addToSpecies(dinosaur);
            isSpeciesFound = true;
            break;
          }
        }
      }
      
      if (!isSpeciesFound) {
        species.add(new Species(dinosaur, CPPNs));
      }
    }
  }
  
  void repopulate() {
    float sumOfAverageFitness = getSumOfAverageFitness();
    ArrayList<Dinosaur> offsprings = new ArrayList<Dinosaur>();
    
    if (isShowingSpeciesInfo) { // INFO
      print("@ @ @ @ @\nSpecies Info: \n@ @ @ @ @\n");
    } 
    
    for (Species s : species) {
      // Offspring formula
      int nOffsprings = floor(s.averageFitness/sumOfAverageFitness * population.size()) -1;
      
      offsprings.add(s.bestDinosaur.clone());
      for (int i = 0; i < nOffsprings; i++) {        
        offsprings.add(s.reproduceOffspring());
      }
      
      if (isShowingSpeciesInfo) { // INFO
        println("Fitness: ", s.bestFitness, "\tcount:", s.speciesPopulation.size());
      }
    }
    if (isShowingSpeciesInfo) { // INFO
      print("@ @ @ @ @\nSpecies count:", species.size(), "Population:", population.size(), "\n@ @ @ @ @\n");
    }
    
    // Offspring formula can slightly reduce population, this equalizes it
    while (offsprings.size() < population.size()) { 
      offsprings.add(species.get(0).reproduceOffspring());            
    }
    
    population.clear();
    population = (ArrayList<Dinosaur>)offsprings.clone();
  }
  
  ///////////////////////////////////////////////////////
  
  void roproduceCPPNs() {
    float sumOfAverageFitness = getSumOfAverageFitness();
    ArrayList<CPPN> newCPPNs = new ArrayList<CPPN>();
    
    for (Species s : species) {
      // Offspring formula
      int nOffsprings = floor(s.averageFitness/sumOfAverageFitness * CPPNs.size()) -1;
      
      newCPPNs.add(CPPNs.get(s.bestDinosaur.playerIndex).clone());
      for (int i = 0; i < nOffsprings; i++) {        
        newCPPNs.add(s.makeNewHyperBrain(CPPNs));
      }
      
      if (isShowingSpeciesInfo) { // INFO
        println("Fitness: ", s.bestFitness, "\tcount:", s.speciesPopulation.size());
      }
    }
    if (isShowingSpeciesInfo) { // INFO
      print("@ @ @ @ @\nSpecies count:", species.size(), "Population:", population.size(), "\n@ @ @ @ @\n");
    }
    
    // Offspring formula can slightly reduce population, this equalizes it
    while (newCPPNs.size() < CPPNs.size()) { 
      newCPPNs.add(species.get(0).makeNewHyperBrain(CPPNs));            
    }
    
    CPPNs.clear();
    CPPNs = (ArrayList<CPPN>)newCPPNs.clone();
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  void calculateFitness() {
    for (Dinosaur dino : population) {
      dino.calculateFitness();
    }
  }
  
  void sortSpecies() {
    //sort the players within a species
    for (Species s : species) {
      s.sortSpecies(CPPNs);
    }
    
    Collections.sort(species, new Comparator<Species>() {
      @Override
      public int compare(Species first, Species second) {
        if (first.bestFitness < second.bestFitness)
          return 1;
        if (first.bestFitness > second.bestFitness)
          return -1;
        // Sorting by another value
        if (first.speciesPopulation.size() < second.speciesPopulation.size())
          return 1;
        if (first.speciesPopulation.size() > second.speciesPopulation.size())
          return -1;
        return 0;
      }
    });
  }
  
  void exterminateStaleSpecies() {
    for (int i = 0; i < species.size(); i++) {
      if (species.get(i).staleness >= dropOffAge) {
        species.remove(i);
        i--;
      }
    }
  }
  
  void exterminateEmptySpecies() {
    float sumOfAverageFitness = getSumOfAverageFitness();

    for (int i = 0; i < species.size(); i++) {
      // Offspring formula
      if (species.get(i).averageFitness/sumOfAverageFitness * population.size() < 1) { 
        species.remove(i);
        i--;
      }
    }
  }
  
  float getSumOfAverageFitness() {
    float sumOfAverageFitness = 0;
    for (Species s : species) {
      sumOfAverageFitness += s.averageFitness;
    }
    return sumOfAverageFitness;
  }

  void exterminateTheWeakOfSpecies() {
    for (Species s : species) {
      s.exterminateTheWeak();
      s.distributeFitness();
      s.setAverage();
    }
  }
}
