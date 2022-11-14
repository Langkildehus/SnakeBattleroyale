// Load packages
import processing.net.*;

final String IP = "83.92.102.115";
final int PORT = 8080;

// Declare global variables
Client client;
Game game;
ArrayList<PVector> fruits;
ArrayList<Snake> snakes;
ArrayList<String> names;
int fruitAmount;
int clientSnake;
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
      final byte[] bytes = client.readBytes();
      // First byte reserved for new users
      if (int(bytes[0]) == 0) {
        fruitAmount = int(bytes[1]);
        DIM[0] = int(bytes[2]);
        DIM[1] = int(bytes[3]);
        clientSnake = int(bytes[4]);
        
        game = new Game(width / 2 - height / 2, 0, height, height, DIM);
        state = 1;
      }
    }
    
  } else if (state == 1) {
    // Connected, waiting for players
    
    text("Name:", width / 2, height / 3);
    nameBox.draw();
    readyButton.draw();
    
  } else {
    // Game running
    
    game.show();
    for (Snake snake : snakes) {
      game.draw(snake.body, snake.bodyColor, snake.headColor);
    }
    game.draw(fruits, #FF0000);
    
    if (frameCount % 10 == 0) {
      snakes.get(clientSnake).move();
    }
  }
}



void keyPressed() {
  if (state == 1) {
    nameBox.getUserInput();
    updateName();
  } else if (state == 2) {
    if (key == 'w' || key == 'W' || key == UP) {
      snakes.get(clientSnake).setDirection(0, -1);
    } else if (key == 'a' || key == 'A' || key == LEFT) {
      snakes.get(clientSnake).setDirection(-1, 0);
    } else if (key == 's' || key == 'S' || key == DOWN) {
      snakes.get(clientSnake).setDirection(0, 1);
    } else if (key == 'd' || key == 'D' || key == RIGHT) {
      snakes.get(clientSnake).setDirection(1, 0);
    }
  }
}



void mouseClicked() {
  if (state == 1) {
    if (readyButton.hovering()) {
      /* Sends message:
        0:    clientID
        1:    ready(1 or 0)
        OPTIONAL:
        2..:  name
      */
      
      final int reservedBytes = 2;
      byte[] bytes;
      readyButton.toggle = !readyButton.toggle;
      if (readyButton.toggle) {
        bytes = new byte[nameBox.text.length() + reservedBytes];
        bytes[0] = byte(clientSnake);
        bytes[1] = byte(1);
        for (int i = reservedBytes; i < nameBox.text.length() + reservedBytes; i++) {
          bytes[i] = byte(nameBox.text.charAt(i - reservedBytes));
        }
      } else {
        bytes = new byte[reservedBytes];
        bytes[0] = byte(clientSnake);
        bytes[1] = byte(0);
      }
      
      client.write(bytes);
    }
  }
}



void updateName() {
  final int reserved = 1; // 0: 1 means not a new player
  byte[] bytes = new byte[reserved + 1];
  bytes[0] = byte(1);
  for (int i = 0; i < nameBox.text.length(); i++) {
    bytes[i + reserved] = byte(nameBox.text.charAt(i));
  }
}
