import 'package:flutter/material.dart';
import 'package:music_player/MediaPlayer.dart';
import 'package:music_player/constants.dart';
import 'package:music_player/loader.dart';

class ScanMusic extends StatefulWidget {
  @override
  _ScanMusicState createState() => _ScanMusicState();
}

class _ScanMusicState extends State<ScanMusic> {
  bool running = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      appBar: AppBar(
        backgroundColor: black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Scan Music",
          style: TextStyle(color: white),
        ),
        centerTitle: true,
      ),
      body: Container(
          child: Center(
        child: showProgress(context),
      )),
    );
  }

  showProgress(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return ValueListenableBuilder(
        valueListenable: scanStart,
        builder: (context, value, child) {
          print('here value is ${scanStart.value}');
          return !scanStart.value
              ? RaisedButton(
                  onPressed: () async {
                    setState(() {
                      MediaPlayer().getMusic();
                    });
                  },
                  color: orange,
                  child: Text(
                    'Run Scan',
                    style: TextStyle(color: white, fontSize: 20),
                  ),
                )
              : Container(
                  width: width * 0.8,
                  height: width * 0.3,
                  decoration: BoxDecoration(
                      color: white, borderRadius: BorderRadius.circular(20.0)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Loader1(),
                      Text(
                        'Scanning for songs',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                );
        });
  }
}
