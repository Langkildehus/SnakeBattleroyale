import java.util.Arrays;

void handleInput() {
  final byte[] bytes = client.readBytes();
  int nextByte = 2;
  if (int(bytes[0]) == 1) {
    // GAME LOOP
    if (int(bytes[1]) == 0) {
      // NO RESET
      
      // Update fruits
      for (int i = 0; i < fruitAmount; i++) {
        fruits.set(i, new PVector(int(bytes[nextByte]), int(bytes[nextByte + 1])));
        nextByte += 2;
      }
      
      // Update snakes
      nextByte = getSnakes(bytes, nextByte);
      
      getPowerups(bytes, nextByte);
    } else {
      // RESET
      state = 0;
    }
  } else {
    // Update variables:
    fruitAmount = int(bytes[1]);
    DIM[0] = int(bytes[2]);
    DIM[1] = int(bytes[3]);
    framerate = int(bytes[4]);
    clientSnake = int(bytes[5]);
  }
}



void getPowerups(byte[] bytes, int nextByte) {
  powerups = new ArrayList<Powerup>();
  final int powerupAmount = int(bytes[nextByte]);
  println(powerupAmount);
  nextByte++;
  
  for (int i = 0; i < powerupAmount; i++) {
    final PVector pos = new PVector(int(bytes[nextByte]), int(bytes[nextByte + 1]));
    powerups.add(new Powerup(pos, int(bytes[nextByte + 2])));
    nextByte += 3;
  }
}



void startGame() {
  final byte[] bytes = client.readBytes();
  if (int(bytes[0]) == 1) {
    state = 2;
    
    // Recieve names
    int nextByte = 2;
    final int playerCount = int(bytes[1]);
    for (int i = 0; i < playerCount; i++) {
      final int nameLength = int(bytes[nextByte]);
      nextByte++;
      final String name = new String(Arrays.copyOfRange(bytes, nextByte, nextByte + nameLength));
      nextByte += nameLength;
      snakes.add(new Snake(new PVector(-1, -1), DIM, #0000FF, #000099, name));
    }
    
    // Recieve first fruit spawns
    for (int i = 0; i < fruitAmount; i++) {
      fruits.add(new PVector(int(bytes[nextByte]), int(bytes[nextByte + 1])));
      nextByte += 2;
    }
    
    // Recieve snakes
    for (int i = 0; i < snakes.size(); i++) {
      Snake snake = snakes.get(i);
      snake.body = new ArrayList<PVector>();
      while (int(bytes[nextByte]) != 255) {
        final PVector pos = new PVector(int(bytes[nextByte]), int(bytes[nextByte + 1]));
        snake.body.add(pos);
        nextByte += 2;
      }
      snake.addTail += int(bytes[nextByte + 1]);
      snake.alive = boolean(bytes[nextByte + 2]);
      snake.powerup = int(bytes[nextByte + 3]);
      nextByte += 4;
    }
    
    // Recieve snake colors
    for (Snake snake : snakes) {
      snake.headColor = color(int(bytes[nextByte]), int(bytes[nextByte + 1]), int(bytes[nextByte + 2]));
      snake.bodyColor = color(int(bytes[nextByte + 3]), int(bytes[nextByte + 4]), int(bytes[nextByte + 5]));
      nextByte += 6;
    }
  }
  
  game = new Game(width / 2 - height / 2, 0, height, height, DIM);
}


void updateName() {
  final int reserved = 2; // 0: 1 means not a new player
                          // 1: 1 means ready
  byte[] bytes = new byte[reserved + nameBox.text.length()];
  bytes[0] = byte(1);
  bytes[1] = byte(readyButton.toggle);
  for (int i = 0; i < nameBox.text.length(); i++) {
    bytes[i + reserved] = byte(nameBox.text.charAt(i));
  }
  client.write(bytes);
}



int getSnakes(byte[] bytes, int nextByte) {
  for (int i = 0; i < snakes.size(); i++) {
    Snake snake = snakes.get(i);
    if (clientSnake != i) {
      snake.body = new ArrayList<PVector>();
    }
    
    while (int(bytes[nextByte]) != 255) {
      final PVector pos = new PVector(int(bytes[nextByte]), int(bytes[nextByte + 1]));
      if (i != clientSnake) {
        snake.body.add(pos);
      }
      nextByte += 2;
    }
    snake.addTail += int(bytes[nextByte + 1]);
    snake.alive = boolean(bytes[nextByte + 2]);
    snake.powerup = int(bytes[nextByte + 3]);
    nextByte += 4;
  }
  return nextByte;
}



void updateServer() {
  ArrayList<PVector> snakeBody = snakes.get(clientSnake).body;
  byte[] bytes = new byte[2 * snakes.get(clientSnake).body.size()];
  
  for (int i = 0; i < snakeBody.size(); i++) {
    bytes[2 * i] = byte(snakeBody.get(i).x);
    bytes[2 * i + 1] = byte(snakeBody.get(i).y);
  }
  client.write(bytes);
}
