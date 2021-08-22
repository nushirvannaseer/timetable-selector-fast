class Society {
  String name, username, password;
  Map<String, String>? executiveTeam;
  Map<String, dynamic>? events;

  Society(this.name, this.username, this.password) {
    this.executiveTeam = {};
    this.events = {};
  }

  
}
