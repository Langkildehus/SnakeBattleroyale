import processing.net.Client;

class Player {
  Client client;
  String name = "";
  Snake snake;
  boolean ready = false;
  boolean alive = true;
  int powerup = 3;
  int powerupDuration = 0;
  Button kickButton;
  
  Player(Client client) {
    this.client = client;
  }
  
  void drawKickButton(float x, float y) {
    if (kickButton != null) {
      kickButton.setPos(int(x), int(y));
      kickButton.draw();
    }
  }
  
  void setKickButton(Button button) {
    kickButton = button;
  }
}
