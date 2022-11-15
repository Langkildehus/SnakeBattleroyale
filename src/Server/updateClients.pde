void updateClients() {
  final int reserved = 2;
  byte[] bytes = new byte[reserved + 2 * fruitAmount];
  // RESERVED BYTES
  bytes[0] = byte(1);
  bytes[1] = byte(0);
  
  int nextIndex = reserved;
  
  // Send fruits
  for (PVector fruit : fruits) {
    bytes[nextIndex] = byte(fruit.x);
    bytes[nextIndex + 1] = byte(fruit.y);
    nextIndex += 2;
  }
  
  // Send snakes
  for (Player player : players) {
    for (PVector pos : player.snake.body) {
      bytes[nextIndex] = byte(pos.x);
      bytes[nextIndex + 1] = byte(pos.y);
      nextIndex += 2;
    }
    bytes[nextIndex] = byte(-1);
    nextIndex++;
  }
  
  server.write(bytes);
}
