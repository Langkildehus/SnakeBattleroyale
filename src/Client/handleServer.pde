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
      getSnakes(bytes, nextByte);
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
    for (int i = 0; i < fruitAmount; i++) {
      fruits.add(new PVector(0, 0));
    }
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
      println(int(bytes[nextByte]), int(bytes[nextByte + 1]));
      println("#####################");
    }
    
    // Recieve snakes
    for (int i = 0; i < snakes.size(); i++) {
      snakes.get(i).body = new ArrayList<PVector>();
      while (int(bytes[nextByte]) != 255) {
        final PVector pos = new PVector(int(bytes[nextByte]), int(bytes[nextByte + 1]));
        snakes.get(i).body.add(pos);
        nextByte += 2;
      }
      println(snakes.get(i).body);
      println("---------------");
      nextByte++;
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



void getSnakes(byte[] bytes, int nextByte) {
  for (int i = 0; i < snakes.size(); i++) {
    if (clientSnake != i) {
      snakes.get(i).body = new ArrayList<PVector>();
    }
    
    while (int(bytes[nextByte]) != 255) {
      final PVector pos = new PVector(int(bytes[nextByte]), int(bytes[nextByte + 1]));
      if (i != clientSnake) {
        snakes.get(i).body.add(pos);
      }
      nextByte += 2;
    }
    nextByte++;
  }
}
