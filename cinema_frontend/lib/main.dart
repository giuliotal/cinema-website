import 'package:flutter/material.dart';
import 'package:cinema_frontend/UI/App.dart';
import 'package:provider/provider.dart';

import 'model/objects/LoginState.dart';

void main() {
  runApp(
    ChangeNotifierProvider<LoginState>(
      create: (context) => LoginState(),
      child: App()
    )
  );
}
