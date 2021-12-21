import 'package:flutter/material.dart';

class CustomTheme {

  static final BoxDecoration inputFieldDecoration = BoxDecoration(
    color: const Color(0xFF62727b),
    borderRadius: BorderRadius.circular(10.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 6.0,
        offset: Offset(0, 2),
      ),
    ],
  );

  static final TextStyle inputFieldHintStyle = TextStyle(
    fontStyle: FontStyle.italic,
    color: Colors.white.withOpacity(0.7)
  );

  static final Container background = Container(
    decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // end: Alignment.bottomCenter,
          colors: [
            const Color(0xff667279),
            const Color(0xFF102027)
            // const Color(0xFFb6bcbc),
            // const Color(0xff667279)
          ],
        )
    ),
  );

}