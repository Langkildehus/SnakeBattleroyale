// Load packages
import processing.net.*;

final int PORT = 8080;

// Declare global variables
Server server;
Game game;
ArrayList<Client> players = new ArrayList<Client>();
ArrayList<PVector> fruits;
ArrayList<Snake> snakes;
ArrayList<String> names;
int fruitAmount;
int state;
int[] DIM;
TextBox nameBox;
Button readyButton;



void setup() {
  fullScreen();
  textAlign(CENTER);
  textSize(64);
  
  // Initialize variables
  fruitAmount = 4;
  DIM = new int[2];
  DIM[0] = 25;
  DIM[1] = 25;
  snakes = new ArrayList<Snake>();
  names = new ArrayList<String>();
  names.add("");
  state = 0;
  nameBox = new TextBox(width / 4 - width / 6, round(height / 1.8), width / 3, height / 12);
  readyButton = new Button(width / 4 - width / 10, round(height / 1.5), width / 5, height / 12, "START!");
  
  generateLevel();
  
  // Start server
  server = new Server(this, 8080);
}



void draw() {
  background(69);
  if (state == 0) {
    names.set(0, nameBox.text);
    line(width / 2, 0, width / 2, height);
    text(players.size() > 0 ? str(players.size() + 1) + " players connected" : "1 player connected", width / 4, height / 2);
    readyButton.draw();
    nameBox.draw();
    
    textAlign(LEFT);
    for (int i = 0; i < names.size(); i++) {
      text(names.get(i), width / 1.75, height / 11 * (i + 1));
      text("READY", width / 1.2, height / 11 * (i + 1));
    }
    textAlign(CENTER);
      
      
      
      
      
      
      
      
      
    Client player = server.available();
    if (player != null) {
      final byte[] rbytes = player.readBytes();
      for (int i = 0; i < players.size(); i++) {
        if (players.get(i).ip().equals(player.ip())) {
          if (int(rbytes[0]) == 1) {
            String name = "";
            for (int i2 = 2; i < rbytes.length; i++) {
              name += str(rbytes[i2]);
            }
            names.set(i, name);
          }
          return;
        }
      }
      
      println(player.ip());
      byte[] bytes = new byte[5];
      bytes[0] = byte(0);
      bytes[1] = byte(fruitAmount);
      bytes[2] = byte(DIM[0]);
      bytes[3] = byte(DIM[1]);
      bytes[4] = byte(players.size() + 1);
      player.write(bytes);
      /*snakes.add(new Snake(startPos[playerAmount * 2], startPos[playerAmount * 2 + 1], DIM, colors[playerAmount * 2],
                           colors[playerAmount * 2 + 1]));*/
      players.add(player);
      names.add(player.ip());
    }
  }
}



void generateLevel() {
  fruits = new ArrayList<PVector>();
  for (int i = 0; i < snakes.size(); i++) {
    // Reset all snake positions
    //snakes.set(i, new Snake(startPos[2 * i], startPos[2 * i + 1], DIM, colors[2 * i], colors[2 * i + 1]));
  }
  
  generateFood(fruitAmount);
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
      
      for (Snake snake : snakes) {
        for (PVector pos : snake.body) {
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



void keyPressed() {
  if (state == 0) {
    nameBox.getUserInput();
  } if (state == 1) {
    nameBox.getUserInput();
  } else if (state == 2) {
    if (key == 'w' || key == 'W' || key == UP) {
      snakes.get(0).setDirection(0, -1);
    } else if (key == 'a' || key == 'A' || key == LEFT) {
      snakes.get(0).setDirection(-1, 0);
    } else if (key == 's' || key == 'S' || key == DOWN) {
      snakes.get(0).setDirection(0, 1);
    } else if (key == 'd' || key == 'D' || key == RIGHT) {
      snakes.get(0).setDirection(1, 0);
    }
  }
}



void mouseClicked() {
  if (state == 0) {
    if (readyButton.hovering() && readyButton.enabled) {
      readyButton.toggle = !readyButton.toggle;
    }
  }
}
