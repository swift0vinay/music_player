import 'package:flutter/material.dart';

Color orange = Colors.red;
Color white = Colors.white;
Color black = Colors.black;
Color grey = Colors.grey;
Color mgrey = Colors.grey[850];
enum PlayerState { stopped, playing, paused }
enum PlayMode { repeat, loop, shuffle }
ValueNotifier<bool> scanStart = new ValueNotifier(false);
