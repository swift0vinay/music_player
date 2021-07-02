import 'package:flutter/material.dart';
import 'package:music_player/constants.dart';

class LyricDownload extends StatefulWidget {
  @override
  _LyricDownloadState createState() => _LyricDownloadState();
}

class _LyricDownloadState extends State<LyricDownload> {
  TextStyle style = TextStyle(
    color: white,
    fontSize: 15.0,
    letterSpacing: 1.5,
  );
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Center(
      child: Material(
        borderRadius: BorderRadius.circular(20.0),
        color: mgrey,
        child: Container(
          width: w * 0.9,
          height: h * 0.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: mgrey,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "How To Add Lyrics",
                style: style,
              ),
              Text(
                "1) Download an .lrc extension file for your song.",
                style: style,
              ),
              Text(
                "2) Rename it to same name as you track.",
                style: style,
              ),
              Text(
                "3) Place it in the same folder where your track is.",
                style: style,
              ),
              Text(
                "4) Press the refresh button, if the lyrics are not loaded.",
                style: style,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Close"),
                style: ElevatedButton.styleFrom(
                  primary: orange,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
