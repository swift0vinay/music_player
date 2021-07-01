import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_player/constants.dart';
import 'package:music_player/navigation/tabs.dart';

typedef void TimeChangeHandler(Duration duration);
typedef void ErrorHandler(String message);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainNav(),
    );
  }
}
