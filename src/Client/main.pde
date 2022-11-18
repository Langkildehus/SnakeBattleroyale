// Load packages
import processing.net.*;

final String IP = "10.130.145.103";
final int PORT = 8080;

// Declare global variables
Client client;
Game game;
ArrayList<PVector> fruits;
ArrayList<Snake> snakes;
int fruitAmount;
int clientSnake;
int framerate;
int state;
int[] DIM;
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
    
    println("FRUGTER:");
    for (PVector fruit : fruits) println(fruit);
    println("SNAKES:");
    for (Snake snake : snakes) println(snake.body);
    
    
    game.show();
    for (Snake snake : snakes) {
      game.draw(snake.body, snake.bodyColor, snake.headColor);
    }
    game.draw(fruits, #FF0000);
    
    if (frameCount % framerate == 0) {
      snakes.get(clientSnake).move();
    }
    
    if (client.available() > 0) {
      handleInput();
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
