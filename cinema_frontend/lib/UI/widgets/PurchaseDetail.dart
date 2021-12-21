import 'package:cinema_frontend/model/objects/OrderedSeat.dart';
import 'package:flutter/material.dart';

class PurchaseDetail extends StatelessWidget {

  final String time;
  final String price;
  final String title;
  final String subtitle;
  final List<OrderedSeat> orderedSeats;

  const PurchaseDetail({Key key, this.time, this.title, this.subtitle, this.orderedSeats, this.price}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    "Purchase time: $time",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    "Price: $price \$",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: "OpenSans",
                    ),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.event_seat,
            color: Theme.of(context).accentColor,
          ),
          Text(orderedSeats.toString().substring(1,orderedSeats.toString().length-1)),
        ],
      ),
    );
  }

}