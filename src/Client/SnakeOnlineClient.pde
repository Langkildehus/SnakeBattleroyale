import processing.net.*;
Client client;

Game game;
boolean gameReset = false;

ArrayList<Fruit> fruits = new ArrayList<Fruit>();
int state = -1;

int[] DIM = new int[2];
int fruitAmount;
int thisSnake;

ArrayList<Snake> snakes = new ArrayList<Snake>();

void setup() {
  fullScreen();
  client = new Client(this, "10.130.146.18", 8080);
  client.write(" ");
  
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
      snakes.get(thisSnake).move();
      if (!gameReset) {
        sendBody(snakes.get(thisSnake).body);
      }
      
      final PVector head = snakes.get(thisSnake).getHead();
      for (int i = 0; i < fruits.size(); i++) {
        if (fruits.get(i).pos.get(0).x == head.x && fruits.get(i).pos.get(0).y == head.y) {
          fruits.get(i).pos.get(0).y = -2;
          break;
        }
      }
      
      background(0);
      game.show();
      for (Snake snake : snakes) {
        game.draw(snake.body, snake.bodyColor, snake.headColor);
      }
      for (Fruit fruit : fruits) {
        game.draw(fruit.pos, #FF0000);
      }
    }
  } else if (state == 0) {
    // State = 0, waiting for players

   
  } else if (state == -1) {
    // Connecting
    
    if (client.available() > 0) {
      final byte[] bytes = client.readBytes();
      if (int(bytes[0]) == 0) {
        fruitAmount = int(bytes[1]);
        DIM[0] = int(bytes[2]);
        DIM[1] = int(bytes[3]);
        thisSnake = int(bytes[4]);
        
        game = new Game(width / 2 - height / 2, 0, height, height, DIM);
        state = 0;
      }
    }
  }
  
  
  
  if (client.available() > 0) {
    final byte[] bytes = client.readBytes();
    if (int(bytes[0]) == 1) {
      final int reserved = 3;     // First reserved byte: PLAYERUPDATE = {0, 1}
                                  // Second reserved byte: STATE      = {0, 1, 2}
                                  // Third reserved byte: Game reset  = {0, 1}
      state = int(bytes[1]);
      if (int(bytes[2]) == 1) {
        gameReset = true;
      }
      
      ArrayList<PVector> newBody = new ArrayList<PVector>();
      for (int i = 0; i < fruitAmount; i++) {
        fruits.get(i).pos.get(0).x = int(bytes[reserved + 2 * i]);
        fruits.get(i).pos.get(0).y = int(bytes[reserved + 2 * i + 1]);
      }
      for (int i = 0; i < (bytes.length - 2 * fruitAmount - reserved) / 2; i++) {
        final PVector newPos = new PVector(int(bytes[reserved + 2 * i + 2 * fruitAmount]), int(bytes[reserved + 2 * i + 1 + 2 * fruitAmount]));
        newBody.add(newPos);
      }
      //snake1.body = newBody;
    }
  }
}

void sendBody(ArrayList<PVector> arr) {
  final int len = arr.size() * 2;
  byte[] bytes = new byte[len];
  for (int i = 0; i < arr.size(); i++) {
    bytes[2 * i] = byte(arr.get(i).x);
    bytes[2 * i + 1] = byte(arr.get(i).y);
  }
  client.write(bytes);
}

void keyPressed() {
  if (key == 'w' || key == 'W') {
    snakes.get(thisSnake).setDirection(0, -1);
  } else if (key == 'a' || key == 'A') {
    snakes.get(thisSnake).setDirection(-1, 0);
  } else if (key == 's' || key == 'S') {
    snakes.get(thisSnake).setDirection(0, 1);
  } else if (key == 'd' || key == 'D') {
    snakes.get(thisSnake).setDirection(1, 0);
  }
}
