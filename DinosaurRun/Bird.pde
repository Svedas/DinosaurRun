
enum BirdType {
  Low,
  Middle,
  High
}

class Bird extends Obstacle {
  
  BirdType type;
  
  Bird(BirdType _type) {
    super();
    x = width;  
    w = 34;
    h = 28;
    
    type = _type;
    switch(type) {
      case Low:
        y = -10;
        break;
      case Middle:
        y = dinosaur.h/2;
        break;
      case High:
        y = dinosaur.h;
        break;
    }
  }
}
