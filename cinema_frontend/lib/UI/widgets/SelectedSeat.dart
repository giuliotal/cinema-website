import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SelectedSeat extends StatelessWidget {

  final String subtitle;
  final String title;
  final int seatNumber;

  const SelectedSeat({Key key, this.subtitle, this.title, this.seatNumber}) : super(key: key);

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
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
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
          Text(seatNumber.toString()),
        ],
      ),
    );
  }

}