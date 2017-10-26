void setup() {
  size(1500, 600);
  background(0);

  PImage girl = loadImage("/img/girl.jpg");
  PImage bird = loadImage("/img/bird.jpg");

  image(girl, 0, 0);
  image(threshold(girl), 300, 0);
  image(random_dither(girl), 600, 0);
  image(selective_random_dither(girl, 50), 900, 0); // only 50% of pixels
  image(pattern_dither(girl), 1200, 0);

  image(error_diff_dither(girl), 0, 300);
  image(jarvis_error_diff_dither(girl), 300, 300);
  
  image(bird, 620, 353);
  image(threshold_color(bird), 920, 353);
  image(error_diff_dither_color(bird), 1220, 353);

  textFont(createFont("Arial", 42));
  textAlign(CENTER, CENTER);
  text("Original", 150, 150);
  text("Original", 750, 450);
}

PImage threshold(PImage image) {
  PImage temp = image.copy();
  for (int i=0; i<temp.pixels.length; i++) {
    temp.pixels[i] = Threshold(brightness(temp.pixels[i]), 127);
  }
  return temp;
}

PImage random_dither(PImage image) {
  PImage temp = image.copy();
  for (int i=0; i<temp.pixels.length; i++) {
    temp.pixels[i] = Threshold(brightness(temp.pixels[i]), random(255));
  }
  return temp;
}

PImage selective_random_dither(PImage image, float selectionAmount) {
  PImage temp = image.copy();
  for (int i=0; i<temp.pixels.length; i++) {
    if (random(100) < selectionAmount) {
      temp.pixels[i] = Threshold(brightness(temp.pixels[i]), 127);
    }
  }
  return temp;
}

PImage pattern_dither(PImage image) {
  PImage temp = image.copy();
  int[][] mask = { { 8, 3, 4 }, { 6, 1, 2 }, { 7, 5, 9 } };

  for (int i=0; i<temp.width; i++) {
    for (int j=0; j<temp.height; j++) {
      int mappedValue = floor(map(brightness(temp.get(i, j)), 0, 255, 0, 9));
      if (mappedValue < mask[i%3][j%3] )
        temp.set(i, j, color(0));
      else
        temp.set(i, j, color(255));
    }
  }
  return temp;
}

PImage error_diff_dither(PImage image) {
  PImage temp = image.copy();
  for (int j=0; j<temp.height; j++) {
    for (int i=0; i<temp.width; i++) {
      float p = brightness(Threshold(brightness(temp.get(i, j)), 127));
      float e = brightness(temp.get(i, j)) - p;
      temp.set(i+1, j, color(brightness(temp.get(i+1, j)) + (7.0 / 16.0) * e));
      temp.set(i-1, j+1, color(brightness(temp.get(i-1, j+1)) + (3.0 / 16.0) * e));
      temp.set(i, j+1, color(brightness(temp.get(i, j+1)) + (5.0 / 16.0) * e));
      temp.set(i+1, j+1, color(brightness(temp.get(i+1, j+1)) + (1.0 / 16.0) * e));
    }
  }

  for (int i =0; i <temp.pixels.length; i++)
    temp.pixels[i] = color(Threshold(brightness(temp.pixels[i]), 127));

  return temp;
}

PImage jarvis_error_diff_dither(PImage image) {
  PImage temp = image.copy();
  float[][] mask = { { 0, 0, 0, 7, 5}, { 3, 5, 7, 5, 3 }, { 1, 3, 5, 3, 1 } };
  
  // apply error diffusion
  for (int j=0; j<temp.height; j++) {
    for (int i=0; i<temp.width; i++) {
      float p = brightness(Threshold(brightness(temp.get(i, j)), 127));
      float e = brightness(temp.get(i, j)) - p;
      for(int m=0; m<2; m++) {
         for(int n=-2; n<=2;n++) {
           if(m==0 && n<0) continue;
           else {
             float weight = mask[m][n+2];
             temp.set(i+n, j+m, color(brightness(temp.get(i+n, j+m)) + (weight / 48.0) * e));
           }
         }
      }
    }
  }

  // apply threshold
  for (int i =0; i <temp.pixels.length; i++)
    temp.pixels[i] = color(Threshold(brightness(temp.pixels[i]), 127));

  return temp;
}

PImage threshold_color(PImage image) {
  PImage temp = image.copy();
  for (int i=0; i<temp.pixels.length; i++) {
    float r = red(temp.pixels[i]);
    float g = green(temp.pixels[i]);
    float b = blue(temp.pixels[i]);

    if (r<127) r = 0;
    else r = 255;

    if (g<127) g = 0;
    else g = 255;

    if (b<127) b = 0;
    else b = 255;

    temp.pixels[i] = color(r, g, b);
  }
  return temp;
}


PImage error_diff_dither_color(PImage image) {
  PImage temp = image.copy();
  for (int j=0; j<temp.height; j++) {
    for (int i=0; i<temp.width; i++) {
      float redError = red(temp.get(i, j)) - red(Threshold(red(temp.get(i, j)), 127));
      float greenError = green(temp.get(i, j)) - green(Threshold(green(temp.get(i, j)), 127));
      float blueError = blue(temp.get(i, j)) - blue(Threshold(blue(temp.get(i, j)), 127));

      temp.set(i+1, j, color(
        red(temp.get(i+1, j)) + (7.0 / 16.0) * redError, 
        green(temp.get(i+1, j)) + (7.0 / 16.0) * greenError, 
        blue(temp.get(i+1, j)) + (7.0 / 16.0) * blueError)
        );

      temp.set(i-1, j+1, color(
        red(temp.get(i-1, j+1)) + (3.0 / 16.0) * redError, 
        green(temp.get(i-1, j+1)) + (3.0 / 16.0) * greenError, 
        blue(temp.get(i-1, j+1)) + (3.0 / 16.0) * blueError)
        );

      temp.set(i, j+1, color(
        red(temp.get(i, j+1)) + (5.0 / 16.0) * redError, 
        green(temp.get(i, j+1)) + (5.0 / 16.0) * greenError, 
        blue(temp.get(i, j+1)) + (5.0 / 16.0) * blueError)
        );

      temp.set(i+1, j+1, color(
        red(temp.get(i+1, j+1)) + (1.0 / 16.0) * redError, 
        green(temp.get(i+1, j+1)) + (1.0 / 16.0) * greenError, 
        blue(temp.get(i+1, j+1)) + (1.0 / 16.0) * blueError)
        );
    }
  }

  for (int i =0; i <temp.pixels.length; i++)
    temp.pixels[i] = color(
      red(Threshold(red(temp.pixels[i]), 127)), 
      green(Threshold(green(temp.pixels[i]), 127)), 
      blue(Threshold(blue(temp.pixels[i]), 127)));

  return temp;
}


color Threshold(float c, float amount) {
  if (c < amount) return color(0);
  return color(255);
}