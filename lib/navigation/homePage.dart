import 'dart:io';
import 'dart:math';

import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:music_player/constants.dart';
import 'package:music_player/screens/bottomSheet.dart';
import 'package:music_player/screens/detailsPage.dart';
import 'package:flutter/services.dart';
import 'package:music_player/services/MediaPlayer.dart';
import 'package:music_player/screens/loader.dart';
import 'package:music_player/services/notification.dart';
import 'package:music_player/navigation/playMusic.dart';
import 'package:music_player/screens/previewLogo.dart';
import 'package:music_player/services/scanMusic.dart';
import 'package:music_player/services/songModel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHome extends StatefulWidget {
  List<Song> songs;
  Song playingSong;
  Function showPlayer;
  int playingIndex;
  Function startMusic;
  bool listFetched;
  PlayerState playerState;
  MyHome({
    this.playerState,
    this.startMusic,
    this.listFetched,
    this.songs,
    this.showPlayer,
    this.playingIndex,
    this.playingSong,
  });
  @override
  _MyHomeState createState() => _MyHomeState(
        playingIndex: playingIndex,
        playingSong: playingSong,
        playerState: playerState,
      );
}

class _MyHomeState extends State<MyHome> with SingleTickerProviderStateMixin {
  Song playingSong;
  int playingIndex;
  PlayerState playerState;
  ScrollController scrollController;
  _MyHomeState({
    this.playerState,
    this.playingIndex,
    this.playingSong,
  });
  final key = GlobalKey<ScaffoldState>();
  SharedPreferences sharedPreferences;
  @override
  void initState() {
    super.initState();
    scrollController = new ScrollController();
    initSp();
  }

  initSp() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    playingIndex = this.widget.playingIndex;
    playingSong = this.widget.playingSong;
    playerState = this.widget.playerState;
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: black,
        key: key,
        body: this.widget.listFetched
            ? Column(
                children: [
                  this.widget.songs.isEmpty
                      ? Center(
                          child: Text(
                          "No Songs Found",
                          style: TextStyle(color: white),
                        ))
                      : Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 15.0),
                            shrinkWrap: true,
                            controller: scrollController,
                            itemCount: this.widget.songs.length,
                            itemBuilder: (context, i) {
                              String name = this.widget.songs[i].title;
                              String artist = this.widget.songs[i].artist;
                              bool played = playingIndex == i ? true : false;
                              if (name.length > 27) {
                                String s = '${name.substring(0, 28)}...';
                                name = s;
                              }
                              if (artist.length > 30) {
                                String s = '${artist.substring(0, 31)}...';
                                artist = s;
                              }
                              return musicTile(
                                played,
                                i,
                                name,
                                artist,
                                context,
                              );
                            },
                          ),
                        ),
                ],
              )
            : Loader2(),
      ),
    );
  }

  InkWell musicTile(
    bool played,
    int i,
    String name,
    String artist,
    BuildContext context,
  ) {
    return InkWell(
      onTap: played
          ? () {
              this.widget.showPlayer();
            }
          : () {
              setState(() {
                playingSong = this.widget.songs[i];
                playingIndex = i;
                playerState = PlayerState.playing;
              });
              this.widget.startMusic(playingSong, playingIndex);
            },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                played
                    ? Text(
                        name,
                        style: TextStyle(
                            fontSize: 15,
                            color: orange,
                            fontWeight: FontWeight.bold),
                      )
                    : Text(
                        name,
                        style: TextStyle(
                          fontSize: 15,
                          color: white,
                        ),
                      ),
                SizedBox(
                  height: 5.0,
                ),
                played
                    ? Text(
                        artist,
                        style: TextStyle(
                            fontSize: 13,
                            color: orange,
                            fontWeight: FontWeight.bold),
                      )
                    : Text(
                        artist,
                        style: TextStyle(
                          fontSize: 13,
                          color: white.withOpacity(0.5),
                        ),
                      ),
              ],
            ),
            Expanded(
              child: Container(),
            ),
            Row(
              children: [
                played
                    ? (playerState == PlayerState.playing
                        ? Loader1()
                        : Container())
                    : Container(),
                IconButton(
                  icon: Icon(
                    Icons.more_horiz,
                    color: white.withOpacity(0.5),
                  ),
                  onPressed: () {
                    myBottomSheet(context, this.widget.songs[i]);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
