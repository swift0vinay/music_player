import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_player/constants.dart';
import 'package:music_player/navigation/homePage.dart';
import 'package:music_player/screens/loader.dart';
import 'package:music_player/navigation/tabs.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef void TimeChangeHandler(Duration duration);
typedef void ErrorHandler(String message);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: black,
      statusBarColor: black,
      systemNavigationBarIconBrightness: Brightness.light,
      // navigation bar color
    ));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(accentColor: orange, primaryColor: black),
      home: MainNav(),
    );
  }
}
