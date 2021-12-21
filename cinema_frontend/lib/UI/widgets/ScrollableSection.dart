import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class ScrollableSection extends StatelessWidget {
  final Text header;
  final Widget headerWidget;
  final Widget body;

  const ScrollableSection({Key key, this.header, this.headerWidget, this.body}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverStickyHeader (
      header: Container(
          height: 60.0,
          color: Theme.of(context).primaryColor,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: header,
              ),
              Flexible(
                  child: headerWidget
              ),
            ],
          )
      ),
      sliver: body
    );
  }
}