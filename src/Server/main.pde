// Load packages
import processing.net.*;
import java.util.Arrays;

final int PORT = 8080;

final color[] colors = {
  #000099, #0000FF,
  #009900, #00FF00,
  #009999, #00FFFF,
  #996633, #885522,
  #888800, #999911,
};

// Declare global variables
Server server;
Game game;
ArrayList<Player> players;
ArrayList<PVector> fruits;
ArrayList<PVector> spawnpoints;
int fruitAmount;
int state;
int framerate;
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
  framerate = 10;
  players = new ArrayList<Player>();
  Player host = new Player(null);
  host.ready = true;
  players.add(host);
  
  game = new Game(width / 2 - height / 2, 0, height, height, DIM);
  
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
    
    // Update ready/name list
    Client player = server.available();
    if (player != null) {
      final byte[] rbytes = player.readBytes();
      for (int i = 1; i < players.size(); i++) {
        Player p = players.get(i);
        if (p.client.ip().equals(player.ip())) {
          if (int(rbytes[0]) == 1) {
            p.ready = boolean(rbytes[1]);
            p.name = new String(Arrays.copyOfRange(rbytes, 2, rbytes.length));
          }
          return;
        }
      }
      
      // Accept new players
      byte[] bytes = new byte[6];
      bytes[0] = byte(0);
      bytes[1] = byte(fruitAmount);
      bytes[2] = byte(DIM[0]);
      bytes[3] = byte(DIM[1]);
      bytes[4] = byte(framerate);
      bytes[5] = byte(players.size());
      player.write(bytes);
      players.add(new Player(player));
    }
  } else if (state == 1) {
    // Game running
    
    boolean update = false;
    
    for (int i = 1; i < players.size(); i++) {
      Player player = players.get(i);
      if (player.alive && player.client.available() > 0) {
        update = true;
        handlePlayer(player);
      }
    }
    
    if (frameCount % framerate == 0 && players.get(0).alive) {
      update = true;
      players.get(0).snake.move();
    }
    
    if (update) {
      for (int p = 0; p < players.size(); p++) {
        Player player = players.get(p);
        if (!player.alive) {
          continue;
        }
        
        final PVector head = player.snake.getHead();
        
        // Check if fruit has been eaten
        for (int i = 0; i < fruitAmount; i++) {
          if (head.x == fruits.get(i).x && head.y == fruits.get(i).y) {
            player.snake.addTail++;
            fruits.remove(i);
            generateFood(1);
          }
        }
        
        // Check if snake hit another snake
        for (int i = 0; i < players.size(); i++) {
          Player player2 = players.get(i);
          if (i == p || !player2.alive) {
            continue;
          } else if (!player.alive) {
            break;
          }
          
          for (PVector body : player2.snake.body) {
            if (head.x == body.x && head.y == body.y) {
              player.alive = false;
              break;
            }
          }
        }
      }
    }
    
    if (frameCount % 3 == 0) {
      updateClients();
    }
    
    game.show();
    for (Player player : players) {
      if (player.alive) {
        game.draw(player.snake.body, player.snake.bodyColor, player.snake.headColor);
      }
    }
    game.draw(fruits, #FF0000);
  }
}



void keyPressed() {
  if (state == 0) {
    nameBox.getUserInput();
  } else if (state == 1) {
    if (key == 'w' || key == 'W' || keyCode == UP) {
      players.get(0).snake.setDirection(0, -1);
    } else if (key == 'a' || key == 'A' || keyCode == LEFT) {
      players.get(0).snake.setDirection(-1, 0);
    } else if (key == 's' || key == 'S' || keyCode == DOWN) {
      players.get(0).snake.setDirection(0, 1);
    } else if (key == 'd' || key == 'D' || keyCode == RIGHT) {
      players.get(0).snake.setDirection(1, 0);
    }
  }
}



void mouseClicked() {
  if (state == 0) {
    if (readyButton.hovering()) {
      readyButton.toggle = !readyButton.toggle;
      generateLevel();
      startGame();
      state = 1;
    }
  }
}



void startGame() {
  final int reserved = 2;
  int nameLen = 0;
  for (Player p : players) {
    nameLen += p.name.length() + 1;
  }
  byte[] bytes = new byte[reserved + nameLen];
  bytes[0] = byte(1);
  bytes[1] = byte(players.size());
  
  // Send player names
  int nextByte = reserved;
  for (Player player : players) {
    bytes[nextByte] = byte(player.name.length());
    nextByte++;
    for (int i = 0; i < player.name.length(); i++) {
      bytes[nextByte] = byte(player.name.charAt(i));
      nextByte++;
    }
  }
  
  // Send fruits
  final byte[] frbytes = concat(bytes, getFruitBytes());
  
  // Send snakes
  final byte[] sbytes = concat(frbytes, getSnakeBytes());
  
  nextByte = 0;
  // Send snake colors
  byte[] colorBytes = new byte[6 * players.size()];
  for (Player player : players) {
    colorBytes[nextByte] = byte((player.snake.headColor >> 16) & 0xFF);      // Faster way of getting red(headColor)
    colorBytes[nextByte + 1] = byte((player.snake.headColor >> 8) & 0xFF);   // Faster way of getting green(headColor)
    colorBytes[nextByte + 2] = byte(player.snake.headColor & 0xFF);          // Faster way of getting blue(headColor)
    
    colorBytes[nextByte + 3] = byte((player.snake.bodyColor >> 16) & 0xFF);  // Faster way of getting red(bodyColor)
    colorBytes[nextByte + 4] = byte((player.snake.bodyColor >> 8) & 0xFF);   // Faster way of getting green(bodyColor)
    colorBytes[nextByte + 5] = byte(player.snake.bodyColor & 0xFF);          // Faster way of getting blue(bodyColor)
    nextByte += 6;
  }
  
  final byte[] fbytes = concat(sbytes, colorBytes);
  
  server.write(fbytes);
}
