class Powerup {
  ArrayList<PVector> pos = new ArrayList<PVector>();
  int type; /* 1: SLOW
               2: SPEED
               3: INVINCIBILITY */
  
  Powerup(PVector pos, int type) {
    this.pos.add(pos);
    this.type = type;
  }
}
