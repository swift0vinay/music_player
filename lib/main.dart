import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_player/constants.dart';
import 'package:music_player/homePage.dart';
import 'package:music_player/loader.dart';
import 'package:music_player/navigation/tabs.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef void TimeChangeHandler(Duration duration);
typedef void ErrorHandler(String message);

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SharedPreferences sharedPreferences;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSp();
  }

  initSp() async {
    sharedPreferences = await SharedPreferences.getInstance();
    getFavList();
  }

  getFavList() async {
    List<String> temp = sharedPreferences.getStringList('fav');
    if (temp == null) {
      temp = [];
    }
    setState(() {
      favs = temp;
    });
  }

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
      home: MainNav(),
    );
  }
}
