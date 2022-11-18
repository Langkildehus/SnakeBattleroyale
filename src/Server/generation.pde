import java.util.Collections;

void generateLevel() {
  generateSpawnpoints();
  spawnSnakes();
  fruits = new ArrayList<PVector>();
  generateFood(fruitAmount);
  for (PVector fruit : fruits) println("FRUIT:", fruit);
}



void spawnSnakes() {
  for (int i = 0; i < players.size(); i++) {
    // Reset all snake positions
    players.get(i).snake = new Snake(spawnpoints.get(i % spawnpoints.size()), DIM, #0000FF, #000099);
  }
}



void generateSpawnpoints() {
  final int w = round(DIM[0] / 7);
  final int h = round(DIM[1] / 7);
  spawnpoints = new ArrayList<PVector>();
  for (int i = 0; i < w; i++) {
    for (int j = 0; j < h; j++) {
      spawnpoints.add(new PVector(w * round(i * w + w / 2), h * round(j * h + h / 2)));
    }
  }
  
  Collections.shuffle(spawnpoints);
}



void generateFood(int amount) {
  for (int i = 0; i < amount; i++) {
    while (true) {
      boolean badPos = false;
      float x = round(random(0, DIM[0] - 1));
      float y = round(random(0, DIM[1] - 1));

      for (PVector pos : fruits) {
        if (pos.x == x && pos.y == y) {
          badPos = true;
          break;
        }
      }
      
      for (Player player : players) {
        for (PVector pos : player.snake.body) {
          if (pos.x == x && pos.y == y) {
            badPos = true;
            break;
          }
        }
      }

      if (!badPos) {
        fruits.add(new PVector(x, y));
        break;
      }
    }
  }
}
