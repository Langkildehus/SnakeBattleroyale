void updateClients() {
  final int reserved = 2;
  
  byte[] bytes = new byte[reserved];
  // RESERVED BYTES
  bytes[0] = byte(1);
  bytes[1] = byte(0);
  
  // Send fruits
  final byte[] newBytes = concat(bytes, getFruitBytes());
  
  // Send snakes
  final byte[] tempBytes = concat(newBytes, getSnakeBytes());
  
  final byte[] finalBytes = concat(tempBytes, getPowerups());
  
  server.write(finalBytes);
}



byte[] getPowerups() {
  byte[] bytes = new byte[getPowerupBytes()];
  
  bytes[0] = byte(powerups.size());
  for (int i = 0; i < powerups.size(); i++) {
    bytes[3 * i + 1] = byte(powerups.get(i).pos.get(0).x);
    bytes[3 * i + 2] = byte(powerups.get(i).pos.get(0).y);
    bytes[3 * i + 3] = byte(powerups.get(i).type);
  }
  
  return bytes;
}



int getPowerupBytes() {
  int bytes = 1;
  bytes += 3 * powerups.size();
  return bytes;
}



int getSnakeLengths() {
  int bodies = 0;
  for (Player player : players) {
    bodies += 2 * player.snake.body.size() + 4;
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
    bytes[nextByte + 3] = byte(player.powerup);
    if (i != 0) {
      player.snake.addTail = 0;
    }
    
    nextByte += 4;  
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
