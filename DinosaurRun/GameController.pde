
// Global vars

boolean isShowingSpeciesInfo = false;

////////////////////////////////////////////

float excessAndDissjointCoefficient = 2;
float weightDifferenceCoefficient = 1;
float compatibilityThreshold = 6;

////////////////////////////////////////////

float probabilityNoCrossover = 0.25;
float probabilityForAcuteMutation = 0.1;
float probabilityToMutateWeight = 0.8;
float probabilityToAddConnection = 0.08;
float probabilityToAddNode = 0.02;
float probabilityToDisableChildConnection = 0.75;
float probabilityToGetConnectionFromFirstParent = 0.5;
float probabilityForBird = 0.15;

////////////////////////////////////////////

float newGameSpeed = 10.0;
int timeRunning = 0;

int nNetworkInputs = 5; 
float dropOffAge = 15;

int screenRows = 10;
int screenCollumns = 3;

boolean isEnding = false;
boolean gameEnded = false;

////////////////////////////////////////////

class GameController {
  
  int groundHeight; // Set after size init
  float gameSpeed;
  float gameGeneration;
  float obstacleTimer;
  float obstacleRandomiser;
  float randomObstacleRange;
  float minTimeForNewObstacle;
  float minLifespanForBirds;
  
  float[] screenValues = new float[screenRows * screenCollumns];
  
  GameController() {    
    gameSpeed = newGameSpeed;
    gameGeneration = 0;
    obstacleTimer = 0.0;
    obstacleRandomiser = 0.0;
    randomObstacleRange = 50;
    minTimeForNewObstacle = 50.0;
    minLifespanForBirds = 1000;
  }
  
  int startOffsetX = 65;
  int startOffsetY = 80 + 88;
  int endOffsetX = 5;
  int endOffsetY = 60;
  
  int xInterval = (width-startOffsetX - endOffsetX)/screenRows;
  int yInterval = (height-startOffsetY - endOffsetY)/screenCollumns;
  
  // Methods
  
  void drawGrid() {
    for (int i = startOffsetX; i <= width - endOffsetX; i = i + xInterval) {
      line(i, startOffsetY, i, height - endOffsetY);  
    }
    
    for (int j = startOffsetY; j <= height - endOffsetY; j = j + yInterval) {
      line(startOffsetX, j, width - endOffsetX, j);
    }
  }
  
  void screenSwoop() {
    color black = #000000;
    
    int localX = 0;
    int localY = 0;
    
    for (int j = startOffsetY; j < height - endOffsetY; j = j + yInterval) {
      localX = 0;
      for (int i = startOffsetX; i < width - endOffsetX; i = i + xInterval) {
        float value = get(i + xInterval/2, j + yInterval/2) == black ? 1 : 0;
        screenValues[ localX + (localY * screenRows) ] = value;
        localX++;
      } 
      localY++;
    }
  }
  
  void drawScreenScanning(float x, float y) {
    push();
    stroke(255,0,0);
    strokeWeight(5);
    point(x,y);
    pop();
  }
  
  // Obstacles
  
  void updateObstacles() {
    obstacleTimer++;
    gameSpeed += 0.002;
    
    if (obstacleTimer > minTimeForNewObstacle + obstacleRandomiser) {
      addObstacle();
    }
  
    moveObstacles();
    if (isShowingUI) {
      showObstacles();
    }
  }
  
  void showObstacles() {
    for (Obstacle obstacle : obstacles) {
       obstacle.show(); 
    }
  }
  
  void moveObstacles() {
    for (Iterator<Obstacle> iterator = obstacles.iterator(); iterator.hasNext();) {
      Obstacle obstacle = iterator.next();
      obstacle.move();
      if (obstacle.x < -100) {
        iterator.remove();
      }
    }  
  }
  
  void addObstacle() {
    float p = random(1);
    if (population.populationLifespan > minLifespanForBirds && p < probabilityForBird) {
      BirdType birdType = randomEnum(BirdType.class);
      obstacles.add(new Bird(birdType));
    } else {
      ObstacleType obstacleType = randomEnum(ObstacleType.class);
      obstacles.add(new Obstacle(obstacleType));
    }
    obstacleTimer = 0;
    obstacleRandomiser = floor(random(randomObstacleRange));
  }
  
  ////////////////
  // Game reset //
  
  boolean isDone() {
    return population.isDone();
  }
  
  void resetObstacles() {
    obstacles = new ArrayList<Obstacle>();
    obstacleTimer = 0;
    obstacleRandomiser = 0;
    gameSpeed = newGameSpeed;
  } 
}
