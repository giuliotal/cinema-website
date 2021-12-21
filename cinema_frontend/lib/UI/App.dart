import 'package:cinema_frontend/UI/pages/Home.dart';
import 'package:cinema_frontend/UI/pages/Login.dart';
import 'package:cinema_frontend/model/support/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'behaviors/AppLocalizations.dart';

class App extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.APP_NAME,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
        primaryColor: const Color(0xff3c4850),
        primaryColorDark: const Color(0xFF102027),
        primaryColorLight: const Color(0xff667279),
        accentColor: const Color(0xFFff5722),

        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
          headline2: TextStyle(fontSize: 16, color: Colors.white),
          headline3: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
          bodyText1: TextStyle(fontSize: 14, color: Colors.white),
          bodyText2: TextStyle(fontSize: 12, color: Colors.white, fontStyle: FontStyle.italic),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(15.0),
            primary: const Color(0xFFff5722)
          )
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.white.withOpacity(0.6))
          )
        )
      ),

      initialRoute: '/',
      routes: {
        '/': (context) => Home(title: Constants.APP_NAME),
        '/login': (context) => Login()
      }
    );
  }


}