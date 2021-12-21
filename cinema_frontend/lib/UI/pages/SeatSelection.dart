import 'package:cinema_frontend/UI/widgets/ButtonMouseCursor.dart';
import 'package:cinema_frontend/UI/widgets/InlineDetailText.dart';
import 'package:cinema_frontend/UI/widgets/SelectedSeat.dart';
import 'package:cinema_frontend/model/Model.dart';
import 'package:cinema_frontend/model/objects/LoginState.dart';
import 'package:cinema_frontend/model/objects/OrderedSeat.dart';
import 'package:cinema_frontend/model/objects/Purchase.dart';
import 'package:cinema_frontend/model/objects/ScheduledShow.dart';
import 'package:cinema_frontend/model/objects/User.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SeatSelection extends StatefulWidget {

  final ScheduledShow scheduledShow;
  final Function refreshScheduledShows;

  const SeatSelection({Key key, this.scheduledShow, this.refreshScheduledShows}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SeatSelectionState();

}

class _SeatSelectionState extends State<SeatSelection> {

  // scheduled show come stato per poterlo aggiornare ad ogni acquisto effettuato?

  double _totalPrice = 0;
  List<bool> _selections;
  List<int> _selectedSeatNumbers = [];
  Set<int> _alreadyBookedSeatNumbers = {};

  @override
  void initState() {
    super.initState();
    _selections = List.generate(widget.scheduledShow.room.totalSeats, (index) => false);
    // N.B utilizzo gli orderedSeat dal lato dello schedule
    for(OrderedSeat seat in widget.scheduledShow.orderedSeatSet){
      _alreadyBookedSeatNumbers.add(seat.seatNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Select your seats",
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
      backgroundColor: Theme.of(context).primaryColorDark,
      body: Row(
        children: [
          Flexible(
            flex: 3,
            child: Container(
              margin: EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    height: 30,
                    margin: EdgeInsets.only(bottom: 20),
                    alignment: Alignment.center,
                    color: Theme.of(context).primaryColor,
                    child: Text("SCREEN"),
                  ),
                  Flexible(
                    child: GridView.count(
                      crossAxisCount: widget.scheduledShow.room.rowSeats,
                      childAspectRatio: 1,
                      children: List.generate(widget.scheduledShow.room.totalSeats, (index) {
                        return Container(
                          margin: EdgeInsets.all(10),
                          child: MaterialButton(
                            child: _checkBookingText(index),
                            color: _checkBookingColor(index),
                            disabledColor: Theme.of(context).primaryColorLight,
                            mouseCursor: ButtonMouseCursor(),
                            onPressed: _alreadyBookedSeatNumbers.contains(index+1) ? null : () {
                              setState(() {
                                if(_selections[index]) {
                                  _selectedSeatNumbers.remove(index+1);
                                  _totalPrice -= widget.scheduledShow.event.price;
                                }
                                else {
                                  _selectedSeatNumbers.add(index+1);
                                  _totalPrice += widget.scheduledShow.event.price;
                                }
                                _selections[index] = !_selections[index];
                              });
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            )
          ),
          SizedBox(width: 30),
          const VerticalDivider(
            color: Colors.white,
            indent: 20,
            endIndent: 20,
          ),
          SizedBox(width: 30),
          Flexible(
            flex: 1,
            child: Container(
              margin: EdgeInsets.all(20),
              color: Theme.of(context).primaryColor,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Text(
                        "SELECTED SEATS",
                        style: Theme.of(context).textTheme.headline2
                    ),
                  ),
                  Divider(
                      color: Colors.white,
                      indent: 20,
                      endIndent: 20
                  ),
                  Flexible(
                    child: ListView.builder(
                      itemCount: _selectedSeatNumbers.length,
                      itemBuilder: (context, index) {
                        return SelectedSeat(title: widget.scheduledShow.event.title, subtitle: widget.scheduledShow.startDateTime, seatNumber: _selectedSeatNumbers[index]);
                      },
                    ),
                  ),
                  Divider(
                      color: Colors.white,
                      indent: 20,
                      endIndent: 20
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 3,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(left: 20, top: 10, bottom: 10),
                          child: InlineDetailText(title: "TOTAL: ", value: _totalPrice.toStringAsFixed(2))
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 20, right: 10),
                          alignment: Alignment.centerRight,
                          child: OutlinedButton(
                            onPressed:
                              _selectedSeatNumbers.isEmpty ? null : () => _makePurchase(),
                            child: Text("PURCHASE", style: Theme.of(context).textTheme.headline2)
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _checkBookingText(index) {
    return Text(
      "${index+1}",
      style: _alreadyBookedSeatNumbers.contains(index+1) ? 
        Theme.of(context).textTheme.bodyText1.copyWith(
          fontStyle: FontStyle.italic,
          color: Colors.white.withOpacity(0.7)) : 
        Theme.of(context).textTheme.bodyText1
    );
  }

  _checkBookingColor(int index) {
    return _selections[index] ? Theme.of(context).accentColor :
      Theme.of(context).primaryColor;
  }

  _makePurchase() {
    List<OrderedSeat> orderedSeats = [];
    for(int seatNumber in _selectedSeatNumbers){
      OrderedSeat o = new OrderedSeat(seatNumber: seatNumber); // lo show cui si riferisce verrà impostato nel backend
      orderedSeats.add(o);
    }
    User currentUser = Provider.of<LoginState>(context, listen: false).user;
    Purchase p = new Purchase(totalPrice: _totalPrice, user: currentUser, orderedSeatList: orderedSeats, scheduledShow: widget.scheduledShow);
    Model.sharedInstance.addPurchase(p)
      .then((value) {
        String title = value.split("\n")[0];
        showDialog(context: context, builder: (_) => AlertDialog(
          title: Text(title),
          content: Text(value.substring(title.length)+"\n\nYour purchase will be visible in your profile page."),
          actions: [
            TextButton(onPressed:() {
              widget.refreshScheduledShows();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
              child: Text("OK"))
          ],
        ));
    })
    .onError((error, stackTrace) => showDialog(context: context, builder: (_) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.error, color: Theme.of(context).accentColor),
          SizedBox(width: 10),
          Text("ERROR"),
        ],
      ),
      content: Text("${error.toString()}\nYou are going to be redirected to the event page. Please choose a different seat number."),
      actions: [
        TextButton(
            onPressed:() {
              widget.refreshScheduledShows();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text("OK")
        )
      ],
      ))
    );
  }

}