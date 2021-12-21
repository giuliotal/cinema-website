class Genre {
  String name;

  Genre({this.name});

  factory Genre.fromJson(Map<String,dynamic> json) {
    return Genre(
      name: json['name']
    );
  }

  Map<String,dynamic> toJson() => {
    'name': name
  };

  @override
  String toString() {
    return name;
  }

}