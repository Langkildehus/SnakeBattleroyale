class TextBox{
  private int x, y, boxWidth, boxHeight = 40;
  private int textLimit = 160;
  private String text = "";
  private char c = '\'';
  private boolean keyReleased = true;
  
  TextBox(int x, int y, int boxWidth, int boxHeight){
    this.x = x;
    this.y = y;
    this.boxWidth = boxWidth;
    this.boxHeight = boxHeight;
  }

  void draw(){
    // Draw box
    stroke(205);
    fill(100);
    rect(this.x, this.y, this.boxWidth, this.boxHeight);
    
    // Draw text
    fill(255);
    text(this.text, this.x + this.boxWidth / 2, this.y + this.boxHeight / 2 + 15);
    
    if(!keyPressed){
      this.keyReleased = true;
      this.c = '\'';
    }
  }

  void getUserInput(){
    if ((this.c != BACKSPACE && this.c == key) || key == CODED) {
      return;
    }

    this.c = key;

    if (this.c == BACKSPACE && this.text.length() > 0){
      this.text = this.text.substring(0, this.text.length() - 1);
    } else if (this.c >= ' ' && this.text.length() < this.textLimit) {
      this.text += str(this.c);
    }

    this.keyReleased = false;
  }

  boolean hovering(){
    return (mouseX >= this.x && mouseX <= this.x + this.boxWidth && mouseY >= this.y && mouseY <= this.y + this.boxHeight);
  }
}
