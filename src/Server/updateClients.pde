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
    bodies += 2 * player.snake.body.size() + 1;
  }
  return bodies;
}



byte[] getSnakeBytes() {
  // Gather bytes
  byte[] bytes = new byte[getSnakeLengths()];
  int nextByte = 0;
  for (Player player : players) {
    for (PVector pos : player.snake.body) {
      bytes[nextByte] = byte(pos.x);
      bytes[nextByte + 1] = byte(pos.y);
      nextByte += 2;
    }
    bytes[nextByte] = byte(255);
    nextByte++;
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
