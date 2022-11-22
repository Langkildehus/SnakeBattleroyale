class Snake {
  // Declare variables
  int[] DIM;
  color bodyColor;
  color headColor;
  PVector delayedTurn;
  String name;
  
  ArrayList<PVector> body = new ArrayList<PVector>();
  PVector direction = new PVector(0, -1);
  boolean hasMoved = false;
  boolean alive = true;
  int addTail = 3;
  int powerup = 0;
  
  Snake(PVector startPos, int[] DIM, color bodyColor, color headColor, String name) {
    this.body.add(startPos);
    this.DIM = DIM;
    this.bodyColor = bodyColor;
    this.headColor = headColor;
    this.name = name;
  }
  
  void move() {
    // Generate new head
    final PVector oldHead = this.getHead();
    this.body.add(new PVector((this.DIM[0] + oldHead.x + this.direction.x) % this.DIM[0],
                              (this.DIM[1] + oldHead.y + this.direction.y) % this.DIM[1]));
    
    // If no new body pieces need to be created, remove the last body piece
    if (this.addTail > 0) {
      this.addTail -= 1;
    } else {
      this.body.remove(0);
    }
    
    this.hasMoved = true;
    if (this.delayedTurn != null) {
      this.setDirection(round(this.delayedTurn.x), round(this.delayedTurn.y));
      this.delayedTurn = null;
    }
  }
  
  void setDirection(int x, int y) {
    if (this.direction.x == x && this.direction.y == -y || this.direction.x == -x && this.direction.y == y) {
      return;
    }
    
    // if snake hasn't moved since last direction change, save the direction for later
    if (!this.hasMoved) {
      this.delayedTurn = new PVector(x, y);
    } else {
      this.direction.x = x;
      this.direction.y = y;
      this.hasMoved = false;
    }
  }
  
  PVector getHead() {
    return this.body.get(this.body.size() - 1);
  }
}
