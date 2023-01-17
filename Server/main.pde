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
ArrayList<Powerup> powerups;
int fruitAmount;
int powerupAmount;
int state;
int framerate;
int[] DIM;
int countdown;
int startFrame;
int alive;
TextBox nameBox;
Button readyButton;
Button restartButton;



void setup() {
  fullScreen();
  textAlign(CENTER);
  textSize(64);
  
  // Initialize variables
  fruitAmount = 10;
  powerupAmount = 4;
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
  restartButton = new Button(width / 2 - width / 10, height / 2 - height / 24, width / 5, height / 12, "RESTART");
  
  // Start server
  server = new Server(this, PORT);
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
            
            if (p.name.length() > 20 & p.name != "Mangus Langkildehus") {
              p.name = p.name.substring(0, 20);
            }
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
    
    float speed = 1f;
    if (players.get(0).powerup == 1) {
      speed = 2f;
    } else if (players.get(0).powerup == 2) {
      speed = 0.5f;
    } else if (players.get(0).powerup == 3) {
      speed = 0.8f;
    }
    
    boolean update = false;
    
    for (int i = 0; i < players.size(); i++) {
      Player player = players.get(i);
      if (player.powerupDuration > 0) {
        player.powerupDuration -= 1;
      } else {
        player.powerup = 0;
      }
      
      if (i == 0) {
        continue;
      }
      
      if (player.alive && player.client.available() > 0) {
        update = true;
        handlePlayer(player);
      }
    }
    
    if (frameCount % int(framerate * speed) == 0 && players.get(0).alive && countdown == 0) {
      update = true;
      players.get(0).snake.move();
    } else if (countdown > 0 && (frameCount + startFrame) % 60 == 0) {
      countdown -= 1;
    }
    
    if (update) {
      for (int p = 0; p < players.size(); p++) {
        Player player = players.get(p);
        
        final PVector head = player.snake.getHead();
        
        // Check if fruit has been eaten
        for (int i = 0; i < fruitAmount; i++) {
          if (head.x == fruits.get(i).x && head.y == fruits.get(i).y) {
            player.snake.addTail++;
            fruits.remove(i);
            generateFood(1);
          }
        }
        
        for (int i = 0; i < powerups.size(); i++) {
          if (head.x == powerups.get(i).pos.get(0).x && head.y == powerups.get(i).pos.get(0).y) {
            if (powerups.get(i).type == 4) {
              player.snake.addTail += 5;
            } else {
              player.powerup = powerups.get(i).type;
              player.powerupDuration = 300;
            }
            powerups.remove(i);
          }
        }
        
        if (!player.alive || player.powerup == 3) {
          continue;
        }
        
        // Check if snake hit another snake
        for (int i = 0; i < players.size(); i++) {
          Player player2 = players.get(i);
          if (!player2.alive) {
            continue;
          } else if (!player.alive) {
            break;
          }
          
          int iter = 0;
          for (PVector body : player2.snake.body) {
            if (head.x == body.x && head.y == body.y) {
              if (i == p) {
                if (iter != player2.snake.body.size() - 1) {
                  player.alive = false;
                  
                  println("DIED TO YOURSELF:");
                  println(head.x, head.y);
                  println(body.x, body.y);
                  println("Body piece:", iter);
                  println("Snake length:", player.snake.body.size());
                  println(player.snake.body);
                  break;
                }
              } else {
                player.alive = false;
                player2.snake.addTail += (player.snake.body.size() + player.snake.addTail);
                break;
              }
            }
            iter++;
          }
        }
      }
    }
    
    if (frameCount % framerate == 0) {
      updateClients();
      for (Player player : players) {
        if (player.powerup == 4) {
          player.powerup = 0;
        }
      }
    }
    
    if (frameCount % (framerate * 30) == 0 && powerups.size() < powerupAmount) {
      generatePowerup();
    }
    
    game.show();
    
    game.draw(fruits, 0, #FF0000);
    for (Powerup powerup : powerups) {
      game.draw(powerup.pos, 0);
    }
    
    alive = 0;
    for (Player player : players) {
      if (player.alive) {
        alive++;
        game.draw(player.snake.body, player.powerup, player.snake.bodyColor, player.snake.headColor);
        text(player.name, (game.w / DIM[0]) * (player.snake.getHead().x + 0.5) + game.x,
                          (game.h / DIM[1]) * (player.snake.getHead().y - 0.5));
        
        fill(255);
        textSize(32);
        textAlign(LEFT);
        text(player.name + ": " + player.snake.body.size(), width / 20, height / 15 * (alive + 2));
        textSize(48);
        textAlign(CENTER);
      }
    }
    
    fill(255);
    text("Remaining: " + alive, width / 10, height / 10);
    
    if (countdown > 0) {
      text(countdown, width / 2, height / 2);
    } else if (alive <= 0) {
      restartButton.draw();
    }
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
  } else if (state == 1 && alive <= 0 && countdown == 0) {
    if (restartButton.hovering()) {
      alive = 1;
      generateLevel();
      startGame();
    }
  }
}



void startGame() {
  countdown = 3;
  startFrame = frameCount;
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
  players.get(0).snake.move();
}
