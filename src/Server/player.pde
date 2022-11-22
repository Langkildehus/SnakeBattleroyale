import processing.net.Client;

class Player {
  Client client;
  String name = "";
  Snake snake;
  boolean ready = false;
  boolean alive = true;
  int powerup = 0;
  int powerupDuration = 0;
  
  Player(Client client) {
    this.client = client;
  }
}
