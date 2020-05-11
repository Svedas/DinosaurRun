import java.util.Iterator;

enum ExperimentType {
  Time,
  Generations
}
// Global vars

boolean isShowingUI = true;
boolean isRunningNEAT = true;

ExperimentType experimentType = ExperimentType.Time;

int timeForExperiment = 3600 * 60;
int generationsForExperiment = 20;

GameController gameController;
Dinosaur dinosaur;
Population population;
InnovationManager innovationManager;

ArrayList<Obstacle> obstacles;

//////////////////////////////

void setup() {
  frameRate(60);
  size(640, 360, FX2D);
  rectMode(CENTER);
  
  setupEntities();
  gameController.groundHeight = height-100;
}

void setupEntities() {
  gameController = new GameController();
  innovationManager = new InnovationManager();
  dinosaur = new Dinosaur(nNetworkInputs);
  
  population = new Population(1000);
  
  obstacles = new ArrayList<Obstacle>();
  obstacles.add(new Obstacle(ObstacleType.SmallCactus1));
}

void draw() {
  
  if (isShowingUI) {
    drawGraphics();
  }
  
  // Game
  
  if (!gameEnded) {
    timeRunning++;
  }
  
  switch (experimentType) {
  case Time:
    if (timeRunning >= timeForExperiment && !isEnding) {
      isEnding = true;
    }
    break;
  case Generations:
    if (population.generation >= generationsForExperiment && !isEnding) {
      isEnding = true;
    }
    break;
  }
  
  if (isRunningNEAT) {
    if (!gameController.isDone() && !gameEnded) {
      gameController.updateObstacles();
      population.update();
    } else if (!isEnding){
      population.naturalSelection();
      gameController.resetObstacles();
    } else if (!gameEnded) {
      // Update last gen info, not for further evolving
      population.naturalSelection();
      population.generation--;
      gameEnded = true;
    } else {
      fill(0);
      text("Ended", width/2, height/2);
      isShowingUI = true;
    }
  } else { ////////////////////////////////////////////////////////////////////////
    if (!gameController.isDone()) {
      gameController.updateObstacles();
      gameController.screenSwoop();
      population.hyperUpdate();
    } else if (!isEnding){
      population.hyperNaturalSelection();
      gameController.resetObstacles();
    } else if (!gameEnded) {
      // Update last gen info, not for further evolving
      population.hyperNaturalSelection();
      population.generation--;
      gameEnded = true;
    } else {
      fill(0);
      text("Ended", width/2, height/2);
      isShowingUI = true;
    }
  }
}

void drawGraphics() {
  push();
  
  // Backgound
  background(#FFFFFF);
  stroke(#000000);
  strokeWeight(2);
  line(0, gameController.groundHeight + 10, width, gameController.groundHeight + 10);

  // Stats
  fill(#000000);
  text("Population Lifespan: "+population.populationLifespan+" Best score: "+population.bestScore, 10, 20);
  text("Generation: "+population.generation+ " Time: "+timeRunning/3600, 10, 40);
  text("Speed: "+gameController.gameSpeed, 10, 60);
  
  //gameController.drawGrid();
  
  pop();
  someMovement();
}

/////////////////////////////////////////////

void someMovement() {
  rect(width/2+sin(radians((frameCount%360)))*100, height-20, 10, 10);
}

/////////////////////////////////////////////

void mousePressed() {
  if (mouseButton == LEFT) {
    dinosaur.jump(false);  
  }
  else if (mouseButton == RIGHT) {
    dinosaur.jump(true); 
  } 
  else if (mouseButton == CENTER) {
    dinosaur.isDucked = true;
  }
}

void mouseReleased() {
  dinosaur.isDucked = false;
}
