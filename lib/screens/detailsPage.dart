import 'dart:io';

import 'package:flutter/material.dart';
import 'package:music_player/constants.dart';
import 'package:music_player/screens/previewLogo.dart';
import 'package:music_player/services/songModel.dart';

class DetailsPage extends StatefulWidget {
  Song song;
  DetailsPage({this.song});
  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  TextStyle style = TextStyle(fontSize: 15.0, color: white);
  TextStyle style2 = TextStyle(fontSize: 14.0, color: white);
  String size;
  @override
  Widget build(BuildContext context) {
    size = ((this.widget.song.size) / 1000000).toStringAsFixed(2);
    print((this.widget.song.duration / 60000).toDouble());
    String min = (this.widget.song.duration / 60000).toStringAsFixed(2);
    List<String> ss = min.split('.');
    int minutes = int.parse(ss[0]);
    int seconds = int.parse(ss[1]) - 20;
    double width = MediaQuery.of(context).size.width - 20;
    return SafeArea(
      child: Scaffold(
        backgroundColor: black,
        appBar: AppBar(
          backgroundColor: black,
          centerTitle: true,
          title: Text(
            "Details",
            style: TextStyle(color: white, fontWeight: FontWeight.normal),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              Center(
                child: Material(
                  elevation: 2.5,
                  borderRadius: BorderRadius.circular(20.0),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: SizedBox(
                          width: width / 2,
                          height: width / 2,
                          child: this.widget.song.albumArt == ''
                              ? PreviewLogo(home: false)
                              : Image.file(
                                  File('${this.widget.song.albumArt}'),
                                  width: width / 2,
                                  height: width / 2,
                                  fit: BoxFit.cover,
                                ))),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    spacing: 10.0,
                    direction: Axis.vertical,
                    children: [
                      SizedBox(
                          width: width * 0.2,
                          height: width * 0.1,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Name : ',
                              style: style,
                            ),
                          )),
                      SizedBox(
                          width: width * 0.2,
                          height: width * 0.1,
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Path : ',
                                style: style,
                              ))),
                      SizedBox(
                          width: width * 0.2,
                          height: width * 0.1,
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Duration : ',
                                style: style,
                              ))),
                      SizedBox(
                          width: width * 0.2,
                          height: width * 0.1,
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Artist : ',
                                style: style,
                              ))),
                      SizedBox(
                          width: width * 0.2,
                          height: width * 0.1,
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Size : ',
                                style: style,
                              ))),
                      SizedBox(
                          width: width * 0.2,
                          height: width * 0.1,
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Album : ',
                                style: style,
                              ))),
                    ],
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 10.0,
                    direction: Axis.vertical,
                    children: [
                      SizedBox(
                          width: width * 0.7,
                          height: width * 0.1,
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                this.widget.song.displayName,
                                style: style2,
                              ))),
                      SizedBox(
                          width: width * 0.7,
                          height: width * 0.1,
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                this.widget.song.data,
                                style: style2,
                              ))),
                      SizedBox(
                          width: width * 0.7,
                          height: width * 0.1,
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '$minutes:$seconds',
                                style: style2,
                              ))),
                      SizedBox(
                          width: width * 0.7,
                          height: width * 0.1,
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                this.widget.song.artist,
                                style: style2,
                              ))),
                      SizedBox(
                          width: width * 0.7,
                          height: width * 0.1,
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '$size MB',
                                style: style2,
                              ))),
                      SizedBox(
                          width: width * 0.7,
                          height: width * 0.1,
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${this.widget.song.album}',
                                style: style2,
                              ))),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
