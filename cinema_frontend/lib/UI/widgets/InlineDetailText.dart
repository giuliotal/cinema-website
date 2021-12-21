import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InlineDetailText extends StatelessWidget {
  
  final String title;
  final String value;

  const InlineDetailText({Key key, this.title, this.value}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return RichText(
        maxLines: 20,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
            text: title, style: Theme.of(context).textTheme.subtitle1.copyWith(
            color: Theme.of(context).accentColor,
            fontWeight: FontWeight.bold
        ),
            children: <TextSpan>[
              TextSpan(text: value+"\n", style: Theme.of(context).textTheme.bodyText1)
            ]
        )
    );
  }
  
}