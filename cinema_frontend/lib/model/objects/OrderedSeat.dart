class OrderedSeat {
  int id;
  int seatNumber;

  OrderedSeat({this.id, this.seatNumber});

  factory OrderedSeat.fromJson(Map<String,dynamic> json) {
    return OrderedSeat(
      id: json['id'],
      seatNumber: json['seatNumber'],
    );
  }

  Map<String,dynamic> toJson() => {
    'id': id,
    'seatNumber': seatNumber,
  };

  @override
  String toString() {
    return seatNumber.toString();
  }

}