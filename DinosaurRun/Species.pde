import java.util.Collections;
import java.util.Comparator;

class Species {
  
  // Properties
  
  ArrayList<Dinosaur> speciesPopulation;
  Dinosaur bestDinosaur;
  
  float bestFitness;
  float averageFitness;
  int staleness;
  
  Genotype representer;
  CPPN cppnRepresenter;
  
  Species() {
    speciesPopulation = new ArrayList<Dinosaur>();
    
    bestFitness = 0;
    averageFitness = 0;
    staleness = 0;
  }
  
  Species(Dinosaur dinosaur, ArrayList<CPPN> CPPNs) {
    speciesPopulation = new ArrayList<Dinosaur>();
    speciesPopulation.add(dinosaur);
    
    if (isRunningNEAT) {
      representer = dinosaur.brain.clone();
    } else {
      cppnRepresenter = CPPNs.get(dinosaur.playerIndex).clone();
    }
    
    bestDinosaur = dinosaur.clone();
    
    bestFitness = dinosaur.fitness;
    averageFitness = 0;
    staleness = 0;
  }
  
  // Methods
  
  void addToSpecies(Dinosaur dinosaur) {
    speciesPopulation.add(dinosaur);
  }
  
  Dinosaur getBestDinosaur() {
    return bestDinosaur;
  }
  
  void setAverage() {
    float sum = 0;
    for (Dinosaur dinosaur : speciesPopulation) {
      sum += dinosaur.fitness;
    }
    averageFitness = (float)(sum/speciesPopulation.size());
  }
  
  void distributeFitness() {
    for (Dinosaur dinosaur : speciesPopulation) {
      dinosaur.fitness /= speciesPopulation.size();
    }
  }
  
  void exterminateTheWeak() {
    if (speciesPopulation.size() > 2) {
      speciesPopulation.subList(speciesPopulation.size()/2, speciesPopulation.size()).clear();
    }
  }
  
  void sortSpecies(ArrayList<CPPN> CPPNs) {
    if (speciesPopulation.size() == 0) {
      staleness = 200;
      return;
    }
    
    Collections.sort(speciesPopulation, new Comparator<Dinosaur>() {
      @Override
      public int compare(Dinosaur first, Dinosaur second) {
        if (first.fitness < second.fitness)
          return 1;
        if (first.fitness > second.fitness)
          return -1;
        return 0;
      }
    });

    if (speciesPopulation.get(0).fitness > bestFitness) {
      staleness = 0;
      bestFitness = speciesPopulation.get(0).fitness;
      if (isRunningNEAT) {
        representer = speciesPopulation.get(0).brain.clone();
      } else {
        cppnRepresenter = CPPNs.get(speciesPopulation.get(0).playerIndex).clone();
      }
      bestDinosaur = speciesPopulation.get(0).clone();
    } else {
      staleness++;
    }
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  Dinosaur reproduceOffspring() {
    Dinosaur dino;
    
    float p = random(1);
    if (p < probabilityNoCrossover) {
      dino = selectFitDinosaur().clone();
    } else {
      Dinosaur parent1 = selectFitDinosaur();
      Dinosaur parent2 = selectFitDinosaur();

      if (parent1.fitness < parent2.fitness) {
        dino = parent2.crossover(parent1);
      } else {
        dino = parent1.crossover(parent2);
      }
    }
    dino.brain.mutate();
    return dino;
  }
  
  CPPN makeNewHyperBrain( ArrayList<CPPN> CPPNs) {
    CPPN newBrain;
    
    float p = random(1);
    if (p < probabilityNoCrossover) {
      newBrain = CPPNs.get(selectFitDinosaur().playerIndex);
    } else {
      Dinosaur parent1 = selectFitDinosaur();
      Dinosaur parent2 = selectFitDinosaur();

      if (parent1.fitness < parent2.fitness) {
        newBrain = CPPNs.get(parent2.playerIndex).crossover(CPPNs.get(parent1.playerIndex));
      } else {
        newBrain = CPPNs.get(parent1.playerIndex).crossover(CPPNs.get(parent2.playerIndex));
      }
    }
    newBrain.generateNetwork();
    newBrain.mutate();
    return newBrain;
  }
  
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  Dinosaur selectFitDinosaur() {
    float fitnessSum = 0;
    for (Dinosaur dinosaur : speciesPopulation) {
      fitnessSum += dinosaur.fitness;
    }

    float randomThreshold = random(fitnessSum);
    float accumulatedSum = 0;

    for (Dinosaur dinosaur : speciesPopulation) {
      accumulatedSum += dinosaur.fitness;
      if (accumulatedSum > randomThreshold) {
        return dinosaur;
      }
    }
    return speciesPopulation.get(0);
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  boolean isGenotypeFromSpecies(Genotype genotype) {
    float nExcessAndDisjointGenes = getExcessAndDisjointGenesCount(genotype, representer);
    float averageWeightDifference = getAverageWeightDifference(genotype, representer);
    
    float largeGenomeNormaliser = genotype.connections.size() - 20;
    if (largeGenomeNormaliser < 1) {
      largeGenomeNormaliser = 1;
    }

    // Compatibility  formula
    float x = excessAndDissjointCoefficient * nExcessAndDisjointGenes/largeGenomeNormaliser;
    float y = weightDifferenceCoefficient * averageWeightDifference;
    float compatibility = x + y;

    return (compatibilityThreshold > compatibility);
  }
  
  boolean isGenotypeFromSpecies(CPPN genotype) {
    float nExcessAndDisjointGenes = getExcessAndDisjointGenesCount(genotype, cppnRepresenter);
    float averageWeightDifference = getAverageWeightDifference(genotype, cppnRepresenter);
    
    float largeGenomeNormaliser = genotype.connections.size() - 20;
    if (largeGenomeNormaliser < 1) {
      largeGenomeNormaliser = 1;
    }

    // Compatibility  formula
    float x = excessAndDissjointCoefficient * nExcessAndDisjointGenes/largeGenomeNormaliser;
    float y = weightDifferenceCoefficient * averageWeightDifference;
    float compatibility = x + y;

    return (compatibilityThreshold > compatibility);
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  float getExcessAndDisjointGenesCount(Genotype first, Genotype second) {
    float matchingGenes = 0.0;
    for (Connection a : first.connections) {
      for (Connection b : second.connections) {
        if (a.innovationNumber == b.innovationNumber) {
          matchingGenes++;
          break;
        }
      }
    }
    float allConnections = first.connections.size() + second.connections.size();
    return  (allConnections - (2 * matchingGenes));
  }
  
  float getExcessAndDisjointGenesCount(CPPN first, CPPN second) {
    float matchingGenes = 0.0;
    for (CPPNConnection a : first.connections) {
      for (CPPNConnection b : second.connections) {
        if (a.innovationNumber == b.innovationNumber) {
          matchingGenes++;
          break;
        }
      }
    }
    float allConnections = first.connections.size() + second.connections.size();
    return  (allConnections - (2 * matchingGenes));
  }
  
  /////////////////////////////////////////////////////////////////////////////////////////////////
  
  float getAverageWeightDifference(Genotype first, Genotype second) {
    if (first.connections.isEmpty() || second.connections.isEmpty() ) {
      return 0.0;
    }

    float weightDifference = 0.0;
    float matchingGenes = 0.0;
    for (Connection a : first.connections) {
      for (Connection b : second.connections) {
        if (a.innovationNumber == b.innovationNumber) {
          weightDifference += abs(a.weight - b.weight);
          matchingGenes++;
          break;
        }
      }
    }
    return (matchingGenes == 0) ? 100 : weightDifference;
  }
  
  float getAverageWeightDifference(CPPN first, CPPN second) {
    if (first.connections.isEmpty() || second.connections.isEmpty() ) {
      return 0.0;
    }

    float weightDifference = 0.0;
    float matchingGenes = 0.0;
    for (CPPNConnection a : first.connections) {
      for (CPPNConnection b : second.connections) {
        if (a.innovationNumber == b.innovationNumber) {
          weightDifference += abs(a.weight - b.weight);
          matchingGenes++;
          break;
        }
      }
    }
    return (matchingGenes == 0) ? 100 : weightDifference;
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

}
