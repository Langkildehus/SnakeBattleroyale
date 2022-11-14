import processing.net.*;

Server server;
ArrayList<Client> players = new ArrayList<Client>();

Game game;
ArrayList<Fruit> fruits;
ArrayList<Snake> snakes = new ArrayList<Snake>();
int state = 0;
int playerAmount = 1;

final int[] DIM = {25, 25};
final int fruitAmount = 4;

final color[] colors = {
  #009900, #00FF00,
  #000099, #0000FF,
  #FCC203, #FCF003
};

final int[] startPos = {
  5, 12,
  19, 12,
  12, 12
};

void setup() {
  fullScreen();
  server = new Server(this, 8080);

  snakes.add(new Snake(startPos[0], startPos[1], DIM, colors[0], colors[1]));
  game = new Game(width / 2 - height / 2, 0, height, height, DIM);
  generateLevel();

  textAlign(CENTER);
  textSize(64);
}

void draw() {
  if (state == 2) {
    // Game over
    
    background(0);
    game.show();
    for (Snake snake : snakes) {
      game.draw(snake.body, snake.bodyColor, snake.headColor);
    }
    for (Fruit fruit : fruits) {
      game.draw(fruit.pos, #FF0000);
    }

    text("Game Over", width / 2, height / 2);
  } else if (state == 1) {
    // Game running
    
    if (frameCount % 10 == 0) {
      snakes.get(0).move();
      
      background(0);
      game.show();
      for (Snake snake : snakes) {
        game.draw(snake.body, snake.bodyColor, snake.headColor);
      }
      for (Fruit fruit : fruits) {
        game.draw(fruit.pos, #FF0000);
      }
      
      updatePlayers(0);
    }

    /*if (server.available() != null) {
      final byte[] bytes = player2.readBytes();
      
      ArrayList<PVector> newBody = new ArrayList<PVector>();
      for (int i = 0; i < bytes.length; i += 2) {
        final PVector newPos = new PVector(int(bytes[i]), int(bytes[i + 1]));
        newBody.add(newPos);
      }
      snake2.body = newBody;
          
      final PVector head = snake2.getHead();
      for (int i = 0; i < fruits.size(); i++) {
        if (fruits.get(i).pos.get(0).x == head.x && fruits.get(i).pos.get(0).y == head.y) {
          fruits.remove(i);
          snake2.newTail++;
          generateFood(1);
          break;
        }
      }

      int hits = 0;
      for (PVector body : snake2.body) {
        if (body.x == head.x && body.y == head.y) {
          hits++;
        }
      }

      for (PVector body : snake1.body) {
        if (body.x == head.x && body.y == head.y) {
          hits++;
        }
      }
      
      if (hits > 1) {
        // GAME OVER
        state = 2;
        updatePlayer2(fruits, snake1.body, 1);
        
      }
    }*/
  
  } else {
    // Waiting for player
    
    background(69);
    text("Waiting for players", width / 2, height / 2);
    text(playerAmount > 1 ? str(playerAmount) + " players" : "1 player", width / 2, height / 1.5);

    //Client player = null;
    Client player = server.available();
    if (player != null) {
      player.readBytes();
      byte[] bytes = new byte[5];
      bytes[0] = byte(0);
      bytes[1] = byte(fruitAmount);
      bytes[2] = byte(DIM[0]);
      bytes[3] = byte(DIM[1]);
      bytes[4] = byte(playerAmount);
      player.write(bytes);
      snakes.add(new Snake(startPos[playerAmount * 2], startPos[playerAmount * 2 + 1], DIM, colors[playerAmount * 2],
                           colors[playerAmount * 2 + 1]));
      playerAmount++;
    }
  }
}

void keyPressed() {
  if (key == 'w' || key == 'W' || keyCode == UP) {
    snakes.get(0).setDirection(0, -1);
  } else if (key == 'a' || key == 'A' || keyCode == LEFT) {
    snakes.get(0).setDirection(-1, 0);
  } else if (key == 's' || key == 'S' || keyCode == DOWN) {
    snakes.get(0).setDirection(0, 1);
  } else if (key == 'd' || key == 'D' || keyCode == RIGHT) {
    snakes.get(0).setDirection(1, 0);
  } else if (key == ' ') {
    if (state == 0) {
      state = 1;
    }
    generateLevel();
    state = 1;
    updatePlayers(1);
  }
}

void generateFood(int amount) {
  for (int i = 0; i < amount; i++) {

    while (true) {
      boolean badPos = false;
      float x = round(random(0, DIM[0] - 1));
      float y = round(random(0, DIM[1] - 1));

      for (Fruit fruit : fruits) {
        if (fruit.pos.get(0).x == x && fruit.pos.get(0).y == y) {
          badPos = true;
          break;
        }
      }
      
      for (Snake snake : snakes) {
        for (PVector pos : snake.body) {
          if (pos.x == x && pos.y == y) {
            badPos = true;
            break;
          }
        }
      }

      if (!badPos) {
        fruits.add(new Fruit(x, y));
        break;
      }
    }
  }
}

void updatePlayers(int reset) {
  final int reserved = 4; // First reserved byte: PLAYERUPDATE = {0, 1}
                          // Second reserved byte: STATE      = {0, 1, 2}
                          // Third reserved byte: Game reset  = {0, 1}
  
  int len = 2 * fruits.size() + reserved;
  for (Snake snake : snakes) {
    len += 2 * snake.body.size() + 2;
  }
  
  int currentByte = reserved;
  byte[] bytes = new byte[len];
  bytes[0] = byte(0);
  bytes[1] = byte(state);
  bytes[2] = byte(reset);
  
  for (int i = 0; i < fruitAmount; i++) {
    final PVector pos = fruits.get(i).pos.get(0);
    bytes[currentByte + 2 * i] = byte(pos.x);
    bytes[currentByte + 2 * i + 1] = byte(pos.y);
  }
  currentByte += 2 * fruitAmount;
  
  for (Snake snake : snakes) {
    bytes[currentByte] = byte(snake.body.size());
    bytes[currentByte + 1] = byte(snake.newTail);
    currentByte += 2;
    for (int i = 0; i < snake.body.size(); i++) {
      final PVector pos = snake.body.get(i);
      bytes[currentByte + 2 * i] = byte(pos.x);
      bytes[currentByte + 2 * i + 1] = byte(pos.y);
    }
  }
  
  server.write(bytes);
}

void generateLevel() {
  fruits = new ArrayList<Fruit>();
  for (int i = 0; i < snakes.size(); i++) {
    snakes.set(i, new Snake(startPos[2 * i], startPos[2 * i + 1], DIM, colors[2 * i], colors[2 * i + 1]));
  }
  
  generateFood(fruitAmount);
}
