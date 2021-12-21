import 'package:cinema_frontend/model/objects/Event.dart';
import 'package:cinema_frontend/model/objects/OrderedSeat.dart';
import 'package:cinema_frontend/model/objects/Room.dart';

class ScheduledShow {
  int id;
  String startDateTime;
  String endDateTime;
  Event event;
  Room room;
  int availableSeats;
  List<OrderedSeat> orderedSeatSet; // gli insiemi non sono supportati in JSON


  ScheduledShow({this.id, this.startDateTime, this.endDateTime, this.event, this.room, this.availableSeats, this.orderedSeatSet});

  factory ScheduledShow.fromJson(Map<String,dynamic> json){
    return ScheduledShow(
      id: json['id'],
      startDateTime: json['startDateTime'],
      endDateTime: json['endDateTime'],
      event: Event.fromJson(json['event']),
      room: Room.fromJson(json['room']),
      availableSeats: json['availableSeats'],
      orderedSeatSet: List<OrderedSeat>.from(json['orderedSeatSet'].map((x) => OrderedSeat.fromJson(x)).toList())
    );
  }

  Map<String,dynamic> toJson() => {
    'id': id,
    'startDateTime': startDateTime,
    'endDateTime': endDateTime,
    'event': event.toJson(),
    'room': room.toJson(),
    'availableSeats': availableSeats,
    'orderedSeatSet': List<dynamic>.from(orderedSeatSet.map((x) => x.toJson()))
  };

  @override
  String toString() {
    return startDateTime + "    |    " + room.toString();
  }
}