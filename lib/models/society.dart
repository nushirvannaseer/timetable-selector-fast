class Society {
  String name, username, password;
  List<Map<String, String>>? executiveTeam;
  List<Map<String, Map<String, dynamic>>>? events;


  Society(this.name, this.username, this.password) {
    this.executiveTeam = [];
    this.events = [];
  }
}
