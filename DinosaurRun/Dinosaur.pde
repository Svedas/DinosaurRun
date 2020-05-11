
class Dinosaur {
 
  // Properties
  
  int playerIndex;
  
  float x, y;
  float yAdjustment;
  float vX, vY;
  float aX, aY;
  int w, h;
  
  float fitness;
  int lifespan;
  int generation;
  int score;
  
  boolean isDead;
  boolean isDucked;
  
  // AI Properties
  
  Genotype brain;
  FixedGenotype hyperBrain;
  
  int nInputs;
  // 0: Distance to next obstacle
  // 1: Height of obstacle
  // 2: Width
  // 3: Bird Height
  // 4: Players Y pos
  
  int nOutputs;
  // 0: Small jump
  // 1: Big jump
  // 2: Duck
  
  float[] inputs; 
  float[] outputs;
  
  Dinosaur(int _nInputs) {
    nInputs = _nInputs;
    nOutputs = 3;
    
    inputs = new float[nInputs]; 
    outputs = new float[nOutputs];
    
    if (isRunningNEAT) {
      brain = new Genotype(nInputs, nOutputs);
      brain.generateNetwork();
    } else {
      hyperBrain = new FixedGenotype(nInputs, nOutputs);
      hyperBrain.generateNetwork();
    }
    
    x = 95;
    y = 0;
    
    vX = 0;
    vY = 0;
    
    aX = 0;
    aY = 1.2;
    
    w = 55;
    h = 70;
    
    fitness = 0;
    lifespan = 0;
    generation = 0;
    score = 0;
    isDead = false;
    isDucked = false;
  }
  
  // Methods
  
  float posY() { 
    return gameController.groundHeight - y + yAdjustment; // real coordinate on screen
  }
  
  void show() {
    push();
    
    if (isDucked) {
      w = 90;
      h = 40;
      yAdjustment = 15;
    } else {
      w = 55;
      h = 70;
      yAdjustment = 0;
    }
    
    fill(#000000);
    rect(x, posY(), w, h);
    noFill();
    stroke(#FFFFFF);
    rect(x, posY(), w-5, h-5);
    
    pop();
  }
  
  void move() {
    y += vY;
    if (y > 0) {
      vY -= aY;
    } else {
      vY = 0;
      y = 0;
    }
    
    for (Obstacle obstacle : obstacles) {
      if (obstacle.isCollided(this)) {
        isDead = true;
      }
    }
  }
  
  void update() {
    increaseScore();
    move();
    if (isShowingUI) {
      show();
    }
  }
  
  void jump(boolean bigJump) {
    if (y == 0) {
      if (bigJump) {
        aY = 1;
        vY = 18;
      } else {
        aY = 1.1;
        vY = 16;
      }
    }
  }
  
  void duck() {
    if (y != 0 && isDucked) {
      aY = 2;
      isDucked = true;
    }
  }
  
  void increaseScore() {
    lifespan++;
    score += ((lifespan % 5 == 0) ? 1 : 0);
  }
  
  /////////////////////
  // Desicion making //
  
  void gatherInfo() {
    //float temp = 0;
    float minDistance = MAX_FLOAT;
    Obstacle nearestObstacle = null;
    boolean bird = false;
    
    //inputs[4] = y;
    inputs[4] = map(y, 0, dinosaur.h*2, 0, 1);
    
    for (Obstacle obstacle : obstacles) {
      float distance = obstacle.x + obstacle.w/2 - x + w/2;
      if (distance < minDistance && distance > 0 ) {
        minDistance = distance;
        nearestObstacle = obstacle;
        if (obstacle instanceof Bird) { bird = true; }
      }
    }
    
    if (nearestObstacle == null) {
      inputs[0] = 0; 
      inputs[1] = 0;
      inputs[2] = 0;
      inputs[3] = 0;
      
      return;
    } 
    
    //inputs[0] = 1.0/(minDistance/10.0);
    inputs[0] = map(minDistance, 100, width, 1, 0);
    
    //inputs[1] = nearestObstacle.h;
    inputs[1] = map(nearestObstacle.h, 0, 75, 0, 1);
    
    //inputs[2] = nearestObstacle.w;
    inputs[2] = map(nearestObstacle.w, 0, 95, 0, 1);
    
    if (bird && ((Bird)nearestObstacle).type != BirdType.Low) {
      //inputs[3] = nearestObstacle.y;
      inputs[3] = map(nearestObstacle.y, 0, dinosaur.h, 0, 1);
    } else {
      inputs[3] = 0;
    }
  }
  
  void look() {
    
    for (int j = 0; j < screenCollumns; j++) {
      for (int i = 0; i < screenRows; i++) {
        float value = gameController.screenValues[ i + (j * screenRows) ];
        inputs[ i + (j * screenRows) ] = value;
      } 
    }
  }
    
  void decide() {
    float maxOutput = 0;
    int maxOutputIndex = 0;
    if (isRunningNEAT) {
      outputs = brain.feedForward(inputs);
    } else {
      outputs = hyperBrain.feedForward(inputs);
    }

    for (int i = 0; i < outputs.length; i++) {
      if (outputs[i] > maxOutput) {
        maxOutput = outputs[i];
        maxOutputIndex = i;
      }
    }

    if (maxOutput < 0.7) {
      isDucked = false;
      return;
    }

    switch(maxOutputIndex) {
    case 0:
      jump(false);
      break;
    case 1:
      jump(true);
      break;
    case 2:
      duck();
      break;
    }
  }
  
  // NEAT Methods
  
  void reset() {
    lifespan = 0;
    score = 0;
    fitness = 0;
  }
  
  void calculateFitness() {
    fitness = score*score;
  }
  
  Dinosaur crossover(Dinosaur parent) {
    Dinosaur offspring = new Dinosaur(nNetworkInputs);
    if (isRunningNEAT) {
      offspring.brain = brain.crossover(parent.brain);
      offspring.brain.generateNetwork();
    } else {
      //offspring.hyperBrain = hyperBrain.crossover(parent.hyperBrain);
      //offspring.hyperBrain.generateNetwork();
    }
    
    
    return offspring;
  }
  
  Dinosaur clone() {
    Dinosaur clone = new Dinosaur(nNetworkInputs);
    if (isRunningNEAT) {
      clone.brain = brain.clone();
      clone.brain.generateNetwork();
    } else {
      clone.hyperBrain = hyperBrain.clone();
      clone.hyperBrain.generateNetwork();
    }
    clone.fitness = fitness;
    clone.score = score;
    clone.lifespan = lifespan;
    clone.generation = generation;
    return clone;
  }
}
