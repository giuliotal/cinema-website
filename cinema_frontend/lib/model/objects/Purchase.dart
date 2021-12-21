import 'package:cinema_frontend/model/objects/OrderedSeat.dart';
import 'package:cinema_frontend/model/objects/ScheduledShow.dart';
import 'package:cinema_frontend/model/objects/User.dart';

class Purchase {
  int id;
  String purchaseTime;
  double totalPrice;
  User user;
  ScheduledShow scheduledShow;
  List<OrderedSeat> orderedSeatList;

  Purchase({this.id, this.purchaseTime, this.user, this.totalPrice, this.orderedSeatList, this.scheduledShow});

  factory Purchase.fromJson(Map<String,dynamic> json) {
    return Purchase(
      id: json['id'],
      purchaseTime: json['purchaseTime'],
      totalPrice: json['totalPrice'],
      user: User.fromJson(json['user']),
      scheduledShow: ScheduledShow.fromJson(json['scheduledShow']),
      orderedSeatList: List<OrderedSeat>.from(json['orderedSeatList'].map((x) => OrderedSeat.fromJson(x)).toList())
    );
  }

  Map<String,dynamic> toJson() => {
    'id': id,
    'purchaseTime': purchaseTime,
    'totalPrice': totalPrice,
    'user': user.toJson(),
    'scheduledShow': scheduledShow.toJson(),
    'orderedSeatList': List<dynamic>.from(orderedSeatList.map((x) => x.toJson()))
  };

  @override
  String toString() {
    var s = new StringBuffer();
    s.write(user.firstName + user.lastName);
    s.write("Ticket purchased: $purchaseTime\n");
    for(OrderedSeat o in orderedSeatList){
      s.write("Seat n° ");
      s.write(o.toString()+"\n");
    }
    s.write("Total price: " + totalPrice.toString());
    return s.toString();
  }

}