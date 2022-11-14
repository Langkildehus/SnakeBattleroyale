// Load packages
import processing.net.*;

final int PORT = 8080;

// Declare global variables
Server server;
Game game;
ArrayList<Player> players;
ArrayList<PVector> fruits;
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
  players = new ArrayList<Player>();
  Player host = new Player(null);
  host.ready = true;
  players.add(host);
  
  state = 0;
  nameBox = new TextBox(width / 4 - width / 6, round(height / 1.8), width / 3, height / 12);
  readyButton = new Button(width / 4 - width / 10, round(height / 1.5), width / 5, height / 12, "START!");
  
  // Start server
  server = new Server(this, 8080);
}



void draw() {
  background(69);
  if (state == 0) {
    players.get(0).name = nameBox.text;
    line(width / 2, 0, width / 2, height);
    text(players.size() > 1 ? str(players.size()) + " players connected" : "1 player connected", width / 4, height / 2);
    readyButton.draw();
    nameBox.draw();
    
    textAlign(LEFT);
    for (int i = 0; i < players.size(); i++) {
      final Player player = players.get(i);
      text(player.name, width / 1.8, height / 11 * (i + 1));
      text(player.ready ? "READY" : "...", width / 1.2, height / 11 * (i + 1));
    }
    textAlign(CENTER);
      
      
      
      
      
      
      
      
      
    Client player = server.available();
    if (player != null) {
      final byte[] rbytes = player.readBytes();
      for (int i = 0; i < players.size(); i++) {
        if (players.get(i).client.ip().equals(player.ip())) {
          if (int(rbytes[0]) == 1) {
            String name = "";
            for (int i2 = 1; i < rbytes.length; i++) {
              name += str(rbytes[i2]);
            }
            players.get(i).name = name;
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
      players.add(new Player(player));
    }
  }
}



void generateLevel() {
  fruits = new ArrayList<PVector>();
  for (int i = 0; i < players.size(); i++) {
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



void keyPressed() {
  if (state == 0) {
    nameBox.getUserInput();
  } if (state == 1) {
    nameBox.getUserInput();
  } else if (state == 2) {
    if (key == 'w' || key == 'W' || key == UP) {
      players.get(0).snake.setDirection(0, -1);
    } else if (key == 'a' || key == 'A' || key == LEFT) {
      players.get(0).snake.setDirection(-1, 0);
    } else if (key == 's' || key == 'S' || key == DOWN) {
      players.get(0).snake.setDirection(0, 1);
    } else if (key == 'd' || key == 'D' || key == RIGHT) {
      players.get(0).snake.setDirection(1, 0);
    }
  }
}



void mouseClicked() {
  if (state == 0) {
    if (readyButton.hovering() && readyButton.enabled) {
      readyButton.toggle = !readyButton.toggle;
      generateLevel();
      state = 1;
    }
  }
}
