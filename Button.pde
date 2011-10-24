class Button {
  float posX, posY, sizeXY;
  color offColor, hoverColor, clickColor, nowColor;
  PFont font;
  String label;
  int fontSize;
  boolean hovered=false;
  boolean clicked=false;
  float degLocal;

  Button(float x, float y, float s, color oc, int fs, String d) {
    posX = x;
    posY = y;
    sizeXY = s;
    offColor = oc;
    hoverColor = blendColor(offColor, color(40), ADD);
    clickColor = blendColor(offColor, color(120), ADD);
    nowColor = offColor;
    fontSize=fs;
    font = createFont("Arial", fontSize);
    label = d;
  }

  void update() {
    checkButton();
    drawButton();
  }

  void checkButton() {
    float kSize = 10;
    if (hitDetect(mouseX, mouseY, 0, 0, posX, posY, sizeXY, sizeXY)) {
      if (!mousePressed) {
        hovered=true;
        clicked=false;
      } 
      else if (mousePressed) {
        hovered=true;
        clicked=true;
      }
    } 
    else if (hitDetect(x[1], y[1], kSize, kSize, posX, posY, sizeXY, sizeXY)||hitDetect(x[4], y[4], kSize, kSize, posX, posY, sizeXY, sizeXY)) {
      hovered=true;
      clicked=false;
    } 
    else if (hitDetect(x[0], y[0], kSize, kSize, posX, posY, sizeXY, sizeXY)&&hitDetect(x[4], y[4], kSize, kSize, posX, posY, sizeXY, sizeXY)) {
      hovered=true;
      clicked=true;
    } 
    else {
      hovered=false;
      clicked=false;
    }
  }

  void drawButton() {
    ellipseMode(CENTER);
    noStroke();
    if (hovered&&!clicked) {
      nowColor = hoverColor;
    }
    else if (hovered&&clicked) {
      nowColor = clickColor;
    }
    else if (!hovered&&!clicked) {
      nowColor = offColor;
    }
    fill(0, 10);
    ellipse(posX+2, posY+2, sizeXY, sizeXY);
    fill(nowColor);
    ellipse(posX, posY, sizeXY, sizeXY);
    fill(0);
    textFont(font, fontSize);
    textAlign(CENTER, CENTER);
    text(label, posX, posY-(fontSize/4));
  }

  boolean hitDetect(float x1, float y1, float w1, float h1, float x2, float y2, float w2, float h2) {
    w1 /= 2;
    h1 /= 2;
    w2 /= 2;
    h2 /= 2; 
    if (x1 + w1 >= x2 - w2 && x1 - w1 <= x2 + w2 && y1 + h1 >= y2 - h2 && y1 - h1 <= y2 + h2) {
      return true;
    } 
    else {
      return false;
    }
  }
}

