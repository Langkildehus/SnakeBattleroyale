class Button {
  int x;
  int y;
  int buttonWidth;
  int buttonHeight;
  String text;
  boolean toggle = false;
  
  Button(int x, int y, int buttonWidth, int buttonHeight, String text) {
    this.x = x;
    this.y = y;
    this.buttonWidth = buttonWidth;
    this.buttonHeight = buttonHeight;
    this.text = text;
  }

  void draw() {
    // Draw box
    stroke(205);
    if (this.toggle) {
      fill(0, 255, 0);
    }else if (this.hovering()) {
      fill(125);
    } else {
      fill(100);
    }
    rect(this.x, this.y, this.buttonWidth, this.buttonHeight);
    
    // Draw text
    fill(255);
    text(this.text, this.x + this.buttonWidth / 2, this.y + this.buttonHeight / 2 + 20);
  }

  boolean hovering() {
    return (mouseX >= this.x && mouseX <= this.x + this.buttonWidth && mouseY >= this.y && mouseY <= this.y + this.buttonHeight);
  }
}
