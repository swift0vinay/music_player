import 'package:flutter/material.dart';

import '../constants.dart';

class PreviewLogo extends StatelessWidget {
  bool home;
  PreviewLogo({this.home});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: grey,
          gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [Colors.red[100], Colors.red])),
      child: Center(
        child: Icon(
          Icons.music_note,
          color: black,
          size: home ? 30 : 80,
        ),
      ),
    );
  }
}
