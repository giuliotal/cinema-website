import 'package:cinema_frontend/UI/pages/EventPage.dart';
import 'package:cinema_frontend/model/objects/Event.dart';
import 'package:flutter/material.dart';


class EventCard extends StatelessWidget {

  const EventCard({Key key, this.event, this.selectedDate});

  //total height
  static const height = 700.0;
  static const width = 650.0;

  final Event event;
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: SizedBox(
          height: EventCard.height,
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return EventPage(event: event, selectedDate: selectedDate);
                    })
                );
              },
              splashColor:
              Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
              highlightColor: Colors.transparent,
              child: EventCardContent(event: event),
            ),
          ),
        ),
      ),
    );
  }

}

class EventCardContent extends StatelessWidget {
  const EventCardContent({Key key, @required this.event})
      : assert(event != null),
        super(key: key);

  final Event event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.headline5;
    final descriptionStyle = theme.textTheme.subtitle1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 600,
          child: Stack(
            children: [
              Positioned.fill(
                child: Ink.image(
                  image: AssetImage(
                      "images/${event.title}.jpg"
                  ),
                  fit: BoxFit.fill,
                  child: Container(),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: DefaultTextStyle(
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: descriptionStyle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    "Duration: ${event.duration.toString()} min",
                    style: descriptionStyle,
                  ),
                ),
                Text(event.title, style: titleStyle),
              ],
            ),
          ),
        ),
      ],
    );
  }
}



