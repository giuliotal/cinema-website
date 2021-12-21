import 'package:cinema_frontend/model/objects/Genre.dart';

class Event {
  int id;
  String title;
  int duration;
  double price;
  String description;
  String contentRating;
  List<Genre> genreSet; // gli insiemi non sono supportati in JSON

  Event({this.id, this.title, this.duration, this.price, this.description, this.contentRating, this.genreSet});

  factory Event.fromJson(Map<String,dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      duration: json['duration'],
      price: json['price'],
      description: json['description'],
      contentRating: json['contentRating'],
      genreSet: List<Genre>.from(json['genreSet'].map((x) => Genre.fromJson(x)).toList()),
    );
  }

  Map<String,dynamic> toJson() => {
    'id': id,
    'title': title,
    'duration': duration,
    'price': price,
    'description': description,
    'contentRating': contentRating,
    'genreSet':new List<dynamic>.from(genreSet.map((x) => x.toJson()))
  };

  @override
  String toString() {
    return title;
  }

  @override
  int get hashCode => title.hashCode;

  @override
  bool operator ==(Object o) => o is Event && title == o.title;

}