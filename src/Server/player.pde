import processing.net.Client;

class Player {
  Client client;
  String name = "";
  Snake snake;
  boolean ready = false;
  boolean alive = true;
  
  Player(Client client) {
    this.client = client;
  }
}
