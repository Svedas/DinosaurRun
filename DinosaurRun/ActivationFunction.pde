
enum ActivationFunctions {
  Sine,
  Sigmoid,
  Cosine,
  Square,
  Gaussian,
  Absolute, 
  AbsoluteRoot,
  Linear,
  Tanh
}

interface ActivationFunction {
  float activate(float _input);
}

class Sine implements ActivationFunction {  
  float activate(float x) {
    float y = sin(x);
    return y;
  }
}

class Sigmoid implements ActivationFunction {  
  float activate(float x) {
    float y = 1 / (1 + pow((float)Math.E, -x));
    return y;
  }
}

class Cosine implements ActivationFunction {  
  float activate(float x) {
    float y = cos(x);
    return y;
  }
}

class Square implements ActivationFunction {
  float activate(float x) {
    if (x > 0)
      return sqrt(x);
    if (x < 0)
      return -sqrt(-x);
    return 0;
  }
}

class Gaussian implements ActivationFunction {  
  float activate(float x) {
    float y = pow((float)Math.E, -(x*x*1) );
    return y;
  }
} 

class Absolute implements ActivationFunction {  
  float activate(float x) {
    float y = abs(x);
    return y;
  }
} 

class AbsoluteRoot implements ActivationFunction {  
  float activate(float x) {
    float y = sqrt(abs(x));
    return y;
  }
} 

class Linear implements ActivationFunction {  
  float activate(float x) {
    float y = x;
    return y;
  }
} 

class Tanh implements ActivationFunction {  
  float activate(float x) {
    float y = -1 + (2 / (1 + pow((float)Math.E, x)));
    return y;
  }
}
