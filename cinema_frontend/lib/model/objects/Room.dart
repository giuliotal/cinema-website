class Room {
  int id;
  String name;
  int totalSeats;
  int rowSeats;

  Room({this.id, this.name, this.totalSeats, this.rowSeats});

  factory Room.fromJson(Map<String,dynamic> json) {
    return Room(
      id: json['id'],
      name: json['name'],
      totalSeats: json['totalSeats'],
      rowSeats: json['rowSeats']
    );
  }

  Map<String,dynamic> toJson() => {
    'id': id,
    'name': name,
    'totalSeats': totalSeats,
    'rowSeats': rowSeats
  };

  @override
  String toString() {
    return "Room "+name;
  }
}