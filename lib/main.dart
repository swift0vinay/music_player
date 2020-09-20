import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_player/constants.dart';
import 'package:music_player/homePage.dart';
import 'package:music_player/loader.dart';

typedef void TimeChangeHandler(Duration duration);
typedef void ErrorHandler(String message);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: black,
        statusBarColor: black,
        systemNavigationBarIconBrightness: Brightness.light
        // navigation bar color
        ));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(accentColor: orange),
      home: MyHome(),
    );
  }
}
