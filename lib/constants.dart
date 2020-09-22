import 'package:flutter/material.dart';

Color orange = Colors.red;
Color white = Colors.white;
Color black = Colors.black;
Color grey = Colors.grey;
Color mgrey = Colors.grey[850];
enum PlayerState { stopped, playing, paused }
enum PlayMode { repeat, loop, shuffle }
List<String> favs = new List();
// pr.style(
//   message: 'Downloading file...',
//   borderRadius: 10.0,
//   backgroundColor: Colors.white,
//   progressWidget: CircularProgressIndicator(),
//   elevation: 10.0,
//   insetAnimCurve: Curves.easeInOut,
//   progress: 0.0,
//   textDirection: TextDirection.rtl,
//   maxProgress: 100.0,
//   progressTextStyle: TextStyle(
//      color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
//   messageTextStyle: TextStyle(
//      color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600)
//   );
