import 'package:cinema_frontend/UI/pages/UserPage.dart';
import 'package:cinema_frontend/UI/widgets/EventCard.dart';
import 'package:cinema_frontend/UI/widgets/ScrollableSection.dart';
import 'package:cinema_frontend/model/Model.dart';
import 'package:cinema_frontend/model/objects/Event.dart';
import 'package:cinema_frontend/model/objects/LoginState.dart';
import 'package:cinema_frontend/model/objects/Purchase.dart';
import 'package:cinema_frontend/model/objects/User.dart';
import 'package:cinema_frontend/model/support/CustomTheme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:provider/provider.dart';

class Home extends StatefulWidget {

  final String title;

  const Home({Key key, this.title}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();

}

class _HomeState extends State<Home> {

  DateTime selectedDate;
  Future<List<Event>> onScreenEvents;
  Future<List<Event>> comingSoonEvents;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    comingSoonEvents = Model.sharedInstance.getComingSoonEvents();
    onScreenEvents = Model.sharedInstance.getEventsByDate("${DateFormat('dd-MM-yyyy').format(
        selectedDate.toLocal())}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            CustomTheme.background,
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Image.asset("images/home_banner.jpg", fit: BoxFit.fitWidth),
                  ),
                  floating: false,
                  pinned: true,
                  snap: false,
                  backgroundColor: Theme.of(context).primaryColorDark,
                  titleSpacing: 0.0,
                  title: Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.all(10.0),
                    child: Container(
                      child: Text(widget.title, style: Theme.of(context).textTheme.headline1),
                      padding: EdgeInsets.all(8),
                      color: const Color(0xFFff5722),
                    ),

                  ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Consumer<LoginState>(
                        builder: (context, loginState, child) {
                          return loginState.isLoggedIn == true ? _loggedIn() : _loginButton();
                        },
                      )
                    )
                  ],
                ),
                ScrollableSection (
                    header: Text("On screen", style: Theme.of(context).textTheme.headline2,),
                    headerWidget: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(child: Icon(Icons.event, color: Theme.of(context).accentColor,)),
                        SizedBox(width: 5),
                        Flexible(child: Text("SELECT DATE: ")),
                        SizedBox(width: 10),
                        Flexible(
                          child: ElevatedButton (
                            onPressed: () => _selectDate(context),
                            child: Text (
                                "${DateFormat('EEEE  dd - MM - yyyy').format(
                                    selectedDate.toLocal())}"
                            ),
                          ),
                        ),
                      ],
                    ),
                    body: _eventGrid(onScreenEvents)
                ),
                ScrollableSection(
                    header: Text("Coming soon", style: Theme.of(context).textTheme.headline2),
                    headerWidget: SizedBox(),
                    body: _eventGrid(comingSoonEvents)
                ),
                SliverToBoxAdapter(child: _cinemaInfo())
              ],
            )
          ],
        )
    );
  }

  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 7))
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        onScreenEvents = Model.sharedInstance.getEventsByDate("${DateFormat('dd-MM-yyyy').format(
            selectedDate.toLocal())}");
      });
  }

  _loginButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/login');
      },
      child: Text("Sign in", style: Theme.of(context).textTheme.bodyText1),
    );
  }

  _loggedIn() {
    return ElevatedButton (
      onPressed: () {
        User currentUser = Provider.of<LoginState>(context, listen: false).user;
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              Future<List<Purchase>> lastMonthPurchaseList = Model.sharedInstance.getLastMonthPurchaseHistory(currentUser);
              return UserPage(user: currentUser, lastMonthPurchaseList: lastMonthPurchaseList);
            })
        );
      },
      child: Row(
        children: [
          Icon(Icons.account_circle),
          Text("My profile", style: Theme.of(context).textTheme.bodyText1),
        ],
      )
    );
  }

  _eventGrid(Future<List<Event>> events) {
    return FutureBuilder(
      future: events,
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          if(snapshot.data.length > 0){
            return SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  Event event = snapshot.data[index];
                  return EventCard(event: event, selectedDate: selectedDate);
                },
                childCount: snapshot.data.length
              ),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 497,
                mainAxisExtent: 720,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
              ),
            );
          }
          else {
            return SliverToBoxAdapter(child: Container(
              color: Theme.of(context).primaryColorLight,
              height: 200,
              alignment: Alignment.center,
              child: Text(
                "There are no films on screen on this day",
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ));
          }
        }
        else if(snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Container(
              color: Theme.of(context).primaryColorLight,
              height: 200,
              child: Row(
                children: [
                  SizedBox(width: 30),
                  Icon(
                    Icons.warning,
                    color: Theme.of(context).accentColor,
                  ),
                  SizedBox(width: 30),
                  Text(
                    "CONNECTION ERROR\nPlease check your internet connection.\nIf the problem persists, please contact the administrator",
                    style: Theme.of(context).textTheme.bodyText1,
                    textAlign: TextAlign.left,
                  ),
                ]
              ),
            ),
          );
        }
        return SliverToBoxAdapter(child: LinearProgressIndicator(color: Theme.of(context).accentColor));
      }
    );
  }

  _cinemaInfo() {
    return Container(
      height: 150,
      alignment: Alignment.bottomLeft,
      color: Theme.of(context).primaryColorDark,
      child: Row(
        children: [
          Flexible(
            child: Container(
              margin: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text("CINEMA CITRIGNO (CS)", style: Theme.of(context).textTheme.headline2,),
                  Text("All rights reserved")
                ],
              ),
            ),
          ),
          Flexible(
            child: Container(
              margin: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  Text("CONTACT US", style: Theme.of(context).textTheme.headline2.copyWith(color: Theme.of(context).accentColor)),
                  Text("Via Adige 13, Cosenza"),
                  Text("0984 25085"),
                  SizedBox(height: 20,),
                  Row(
                    children: [
                      Icon(Icons.email, color: Colors.white, size: 15,),
                      SizedBox(width: 8,),
                      Text("cinemacitrignocs@gmail.com")
                    ]
                  )
                ]
              ),
            ),
          )
        ],
      )
    );
  }
}


