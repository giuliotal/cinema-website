import 'package:cinema_frontend/UI/pages/SeatSelection.dart';
import 'package:cinema_frontend/UI/widgets/CustomVerticalDivider.dart';
import 'package:cinema_frontend/UI/widgets/InlineDetailText.dart';
import 'package:cinema_frontend/model/Model.dart';
import 'package:cinema_frontend/model/objects/Event.dart';
import 'package:cinema_frontend/model/objects/LoginState.dart';
import 'package:cinema_frontend/model/objects/ScheduledShow.dart';
import 'package:cinema_frontend/model/support/CustomTheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventPage extends StatefulWidget {

  final Event event;
  final DateTime selectedDate;
  const EventPage({Key key, this.event, this.selectedDate}) : super(key: key);

  @override
  _EventPageState createState() => _EventPageState();

}

class _EventPageState extends State<EventPage> {

  Future<List<ScheduledShow>> shows;

  refreshScheduledShows() {
    setState(() {
      shows = Model.sharedInstance.getScheduledShowsByEventAndDate(widget.event.id,widget.selectedDate);
    });
  }

  @override
  void initState() {
    super.initState();
     shows = Model.sharedInstance.getScheduledShowsByEventAndDate(widget.event.id,widget.selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.event.title,
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
        body: Stack(
          children: [
            CustomTheme.background,
            Row (
              children: [
                Flexible(
                    flex: 3,
                    child: _eventDetails(context)
                ),
                SizedBox(width: 50),
                CustomVerticalDivider(),
                SizedBox(width: 50),
                Flexible(
                    flex: 1,
                    child: _ticketDetails(context)
                ),
                SizedBox(width: 50),
              ],
            )
          ],
        )
    );
  }

  _eventDetails(context) {
    return Row (
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          child:Container(
              margin: EdgeInsets.all(8),
              alignment: Alignment.topLeft,
              child: AspectRatio(
                aspectRatio: 0.69,
                child: Image.asset(
                    "images/${widget.event.title}.jpg",
                    fit: BoxFit.fill
                ),
              )
          ),
        ),

        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 100),
              InlineDetailText(title: "Duration: ", value: "${widget.event.duration} min"),
              InlineDetailText(title: "Price: ", value: "${widget.event.price} \$"),
              InlineDetailText(title: "Content rating: ", value: "${widget.event.contentRating}"),
              InlineDetailText(title: "Genre: ", value: "${widget.event.genreSet.toString().substring(1,widget.event.genreSet.toString().length-1)}"),
              Flexible(
                child: InlineDetailText(title: "Description:\n\n", value: "${widget.event.description}"),
              )
            ],
          ),
        ),
      ],
    );
  }

  _ticketDetails(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 100),
        Flexible(
          flex: 1,
          child: Container(
            margin: EdgeInsets.all(8),
            child: Text(
                "BUY TICKETS",
                style: Theme.of(context).textTheme.headline2
            ),
          ),
        ),
        Flexible(
          flex: 3,
          child: FutureBuilder(
              future: shows,
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  if(snapshot.data.length > 0){
                    return Container(
                      alignment: Alignment.topCenter,
                      child: ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.all(4),
                            child: Consumer<LoginState>(
                                builder: (context, loginState, child) {
                                  return ElevatedButton(
                                      onPressed: () {
                                        return loginState.isLoggedIn == true ? _seatSelection(snapshot.data[index], refreshScheduledShows) : Navigator.pushNamed(context, '/login');
                                      },
                                      child: Text("${snapshot.data[index].toString()}"),
                                      style: ElevatedButton.styleFrom(
                                          primary: Theme.of(context).accentColor
                                      )
                                  );
                                }
                            ),
                          );
                        },
                      ),
                    );
                  }
                  else {
                    return Container(
                      alignment: Alignment.topCenter,
                      child: Text(
                        "Sorry, there are no tickets available for purchase",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    );
                  }
                }
                else if(snapshot.hasError) {
                  return Container(child: Text("${snapshot.error}"));
                }
                else {
                  return Container(
                      margin: EdgeInsets.all(8),
                      child: CircularProgressIndicator()
                  );
                }
              }
          ),
        )
      ],
    );
  }

  _seatSelection(ScheduledShow show, refreshState) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {return SeatSelection(scheduledShow: show, refreshScheduledShows: refreshState,);}));
  }
}
