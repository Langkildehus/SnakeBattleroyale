void updateClients() {
  final int reserved = 2;
  
  byte[] bytes = new byte[reserved];
  // RESERVED BYTES
  bytes[0] = byte(1);
  bytes[1] = byte(0);
  
  // Send fruits
  byte[] newBytes = concat(bytes, getFruitBytes());
  
  // Send snakes
  final byte[] finalBytes = concat(newBytes, getSnakeBytes());
  
  server.write(finalBytes);
}



int getSnakeLengths() {
  int bodies = 0;
  for (Player player : players) {
    bodies += 2 * player.snake.body.size() + 3;
  }
  return bodies;
}



byte[] getSnakeBytes() {
  // Gather bytes
  byte[] bytes = new byte[getSnakeLengths()];
  int nextByte = 0;
  for (int i = 0; i < players.size(); i++) {
    Player player = players.get(i);
    for (PVector pos : player.snake.body) {
      bytes[nextByte] = byte(pos.x);
      bytes[nextByte + 1] = byte(pos.y);
      nextByte += 2;
    }
    
    bytes[nextByte] = byte(255);
    bytes[nextByte + 1] = byte(player.snake.addTail);
    bytes[nextByte + 2] = byte(player.alive);
    if (i != 0) {
      player.snake.addTail = 0;
    }
    
    nextByte += 3;
  }
  return bytes;
}



byte[] getFruitBytes() {
  byte[] bytes = new byte[2 * fruitAmount];
  int nextByte = 0;
  for (PVector fruit : fruits) {
    bytes[nextByte] = byte(fruit.x);
    bytes[nextByte + 1] = byte(fruit.y);
    nextByte += 2;
  }
  return bytes;
}



void handlePlayer(Player player) {
  final byte[] bytes = player.client.readBytes();
  for (int i = 0; i < bytes.length / 2; i++) {
    final PVector pos = new PVector(int(bytes[2 * i]), int(bytes[2 * i + 1]));
    if (i < player.snake.body.size()) {
      player.snake.body.set(i, pos);
    } else {
      player.snake.body.add(pos);
    }
  }
}
