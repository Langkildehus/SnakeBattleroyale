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
        final int x = int(bytes[nextByte]);
        final int y = int(bytes[nextByte + 1]);
        fruits.set(i, new PVector(x, y));
        nextByte += 2;
      }
      
      // Update snakes
      for (int i = 0; i < snakes.size(); i++) {
        while (int(bytes[nextByte]) != -1) {
          final PVector pos = new PVector(int(bytes[nextByte]), int(bytes[nextByte + 1]));
          snakes.get(i).body.set(i, pos);
          nextByte += 2;
        }
        nextByte++;
      }
    } else {
      // RESET
      state = 0;
    }
  }
}



void startGame() {
  final byte[] bytes = client.readBytes();
  if (int(bytes[0]) == 1) {
    state = 2;
    
    int nextByte = 1;
    final int playerCount = int(bytes[1]);
    for (int i = 0; i < playerCount; i++) {
      final int nameLength = int(bytes[nextByte]);
      nextByte++;
      final String name = new String(Arrays.copyOfRange(bytes, nextByte, nextByte + nameLength));
      nextByte += nameLength;
      snakes.add(new Snake(new PVector(12, 12), DIM, #0000FF, #000099, name));
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
