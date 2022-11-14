import processing.net.Client;

class Player {
  Client client;
  String name = "";
  Snake snake;
  boolean ready = false;
  
  Player(Client client) {
    this.client = client;
  }
}
