
enum ObstacleType {
  SmallCactus1, 
  BigCactus1, 
  SmallCactus2, 
  BigCactus2, 
  SmallCactus3, 
  BigCactus3
}

class Obstacle {

  // Properties

  float x, y;
  float yAdjustment;
  int w, h;
  ObstacleType type;

  Obstacle() {
  }

  Obstacle(ObstacleType _type) {
    x = width;
    y = 0;

    type = _type; 
    switch(type) {
    case SmallCactus1:
      w = 25; //40
      h = 50; //80
      yAdjustment = 9;
      break;
    case BigCactus1:
      w = 35;
      h = 75;
      break;
    case SmallCactus2:
      w = 50;
      h = 50;
      yAdjustment = 9;
      break;
    case BigCactus2:
      w = 65;
      h = 75;
      break;
    case SmallCactus3:
      w = 75;
      h = 50;
      yAdjustment = 9;
      break;
    case BigCactus3:
      w = 95;
      h = 75;
      break;
    }
  }

  // Methods

  float posY() {
    return gameController.groundHeight - y + yAdjustment;
  }

  void show() {
    push();

    fill(#000000);
    rect(x, posY(), w, h);
    stroke(#FFFFFF);
    strokeWeight(2);
    if(type != null) {
      switch(type) {
      case SmallCactus1:
      case BigCactus1:
        break;
      case SmallCactus2:
      case BigCactus2:
        line(x, posY()+h/2, x, posY()-h/2);
        break;
      case SmallCactus3:
      case BigCactus3:
        line(x-w/4, posY()+h/2, x-w/4, posY()-h/2);
        line(x+w/4, posY()+h/2, x+w/4, posY()-h/2);
        break;
      default:
        break;
      }
    }
    pop();
  }

  void move() {
    x -= gameController.gameSpeed;
  }

  void update() {
    move();
    show();
  }

  boolean isCollided(Dinosaur player) {
    if ((abs(player.x - x) <= (player.w + w)/2) && (abs(player.posY() - posY()) <= (player.h + h)/2 )) {
      return true;
    }
    return false;
  }
}
