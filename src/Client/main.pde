// Load packages
import processing.net.*;

final String IP = "10.130.145.130";
final int PORT = 8080;

// Declare global variables
Client client;
Game game;
ArrayList<PVector> fruits;
ArrayList<Snake> snakes;
ArrayList<Powerup> powerups;
int fruitAmount;
int clientSnake;
int framerate;
int state;
int[] DIM;
int countdown;
int startFrame;
TextBox nameBox;
Button readyButton;



void setup() {
  fullScreen();
  textAlign(CENTER);
  textSize(64);
  
  // Initialize variables
  DIM = new int[2];
  snakes = new ArrayList<Snake>();
  fruits = new ArrayList<PVector>();
  powerups = new ArrayList<Powerup>();
  state = 0;
  nameBox = new TextBox(width / 2 - width / 6, height / 2, width / 3, height / 12);
  readyButton = new Button(width / 2 - width / 10, round(height / 1.5), width / 5, height / 12, "READY!");
  
  // Connect to server
  client = new Client(this, IP, PORT);
  client.write("connected");
}



void draw() {
  background(69);
  if (state == 0) {
    // Waiting for connection
    
    text("Connecting to server", width / 2, height / 2);
    
    if (client.available() > 0) {
      handleInput();
      state = 1;
    }
    
  } else if (state == 1) {
    // Connected, waiting for players
    
    text("Name:", width / 2, height / 3);
    nameBox.draw();
    readyButton.draw();
    
    if (client.available() > 0) {
      startGame();
    }
    
  } else {
    // Game running
    
    float speed = 1f;
    if (snakes.get(clientSnake).powerup == 1) {
      speed = 2f;
    } else if (snakes.get(clientSnake).powerup == 2) {
      speed = 0.5f;
    } else if (snakes.get(clientSnake).powerup == 3) {
      speed = 0.8f;
    }
    
    game.show();
    
    game.draw(fruits, 0, #FF0000);
    for (Powerup powerup : powerups) {
      game.draw(powerup.pos, 0);
    }
    
    int alive = 0;
    for (Snake snake : snakes) {
      if (snake.alive) {
        alive++;
        game.draw(snake.body, snake.powerup, snake.bodyColor, snake.headColor);
        text(snake.name, (game.w / DIM[0]) * (snake.getHead().x + 0.5) + game.x,
                          (game.h / DIM[1]) * (snake.getHead().y - 0.5));
        
        fill(255);
        textSize(32);
        textAlign(LEFT);
        text(snake.name + ": " + snake.body.size(), width / 20, height / 15 * (alive + 2));
        textSize(48);
        textAlign(CENTER);
      }
    }
    
    if (frameCount % int(framerate * speed) == 0 && snakes.get(clientSnake).alive && countdown == 0) {
      snakes.get(clientSnake).move();
      updateServer();
    } else if (countdown > 0 && (frameCount + startFrame) % 60 == 0) {
      countdown -= 1;
    }
    
    if (client.available() > 0) {
      handleInput();
    }
    
    fill(255);
    text("Remaining: " + alive, width / 10, height / 10);
    
    if (countdown > 0) {
      text(countdown, width / 2, height / 2);
    }
  }
}



void keyPressed() {
  if (state == 1) {
    if (!readyButton.toggle) {
      nameBox.getUserInput();
      updateName();
    }
  } else if (state == 2) {
    if (key == 'w' || key == 'W' || keyCode == UP) {
      snakes.get(clientSnake).setDirection(0, -1);
    } else if (key == 'a' || key == 'A' || keyCode == LEFT) {
      snakes.get(clientSnake).setDirection(-1, 0);
    } else if (key == 's' || key == 'S' || keyCode == DOWN) {
      snakes.get(clientSnake).setDirection(0, 1);
    } else if (key == 'd' || key == 'D' || keyCode == RIGHT) {
      snakes.get(clientSnake).setDirection(1, 0);
    }
  }
}



void mouseClicked() {
  if (state == 1) {
    if (readyButton.hovering()) {
      readyButton.toggle = !readyButton.toggle;
      updateName();
    }
  }
}
