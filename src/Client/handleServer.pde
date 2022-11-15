void handleInput() {
  final byte[] bytes = client.readBytes();
  if (int(bytes[0]) == 1) {
    // GAME LOOP
    if (int(bytes[1]) == 0) {
      // NO RESET
    } else {
      // RESET
      state = 0;
    }
  }
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
