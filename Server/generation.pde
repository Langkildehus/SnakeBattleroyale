import java.util.Collections;

void generateLevel() {
  generateSpawnpoints();
  spawnSnakes();
  fruits = new ArrayList<PVector>();
  powerups = new ArrayList<Powerup>();
  generateFood(fruitAmount);
}



void spawnSnakes() {
  for (int i = 0; i < players.size(); i++) {
    for (Player player : players) {
      player.alive = true;
      player.powerup = 0;
      player.powerupDuration = 0;
    }
    
    // Reset all snake positions
    players.get(i).snake = new Snake(spawnpoints.get(i % spawnpoints.size()), DIM,
                                     colors[(2 * i) % colors.length], colors[(2 * i + 1) % colors.length]);
    if (i != 0) {
      players.get(i).snake.addTail = 0;
    }
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



void generatePowerup() {
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
      powerups.add(new Powerup(new PVector(x, y), round(random(1, 4))));
      break;
    }
  }
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
