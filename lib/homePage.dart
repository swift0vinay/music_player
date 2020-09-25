import 'dart:io';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:music_player/constants.dart';
import 'package:music_player/detailsPage.dart';
import 'package:flutter/services.dart';
import 'package:music_player/MediaPlayer.dart';
import 'package:music_player/loader.dart';
import 'package:music_player/notification.dart';
import 'package:music_player/playMusic.dart';
import 'package:music_player/previewLogo.dart';
import 'package:music_player/services/scanMusic.dart';
import 'package:music_player/songModel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHome extends StatefulWidget {
  List<Song> songs;
  Duration duration;
  Duration position;
  Song playingSong;
  Function showPlayer;
  bool start;
  int playingIndex;
  MediaPlayer mediaPlayer;
  PlayerState playerState;
  bool listfetched;
  PlayMode playMode;
  Function nextSong;
  Function prevSong;
  Function callBackToUpdateSong;
  Function callBackToState;
  Function callBackToStart;
  Function callBackToStop;
  Function callBackToDuration;
  Function callBackToPosition;
  Function callBackToMode;
  MyHome({
    this.start,
    this.listfetched,
    this.nextSong,
    this.prevSong,
    this.showPlayer,
    this.callBackToDuration,
    this.callBackToMode,
    this.callBackToUpdateSong,
    this.callBackToPosition,
    this.callBackToStart,
    this.callBackToState,
    this.callBackToStop,
    this.songs,
    this.duration,
    this.mediaPlayer,
    this.playMode,
    this.playerState,
    this.playingIndex,
    this.playingSong,
    this.position,
  });
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> with SingleTickerProviderStateMixin {
  final key = GlobalKey<ScaffoldState>();
  SharedPreferences sharedPreferences;
  @override
  void initState() {
    super.initState();
    initSp();
    // scrollController = new ScrollController();
  }

  initSp() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: black,
        key: key,
        body: this.widget.listfetched
            ? Column(
                children: [
                  Expanded(
                      child: Scrollbar(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: this.widget.songs.length,
                      itemBuilder: (context, i) {
                        String name = this.widget.songs[i].title;
                        String artist = this.widget.songs[i].artist;
                        bool played = false;
                        if (this.widget.playingSong != null) {
                          played = this.widget.songs[i].id ==
                                  this.widget.playingSong.id
                              ? true
                              : false;
                        }
                        if (name.length > 27) {
                          String s = '${name.substring(0, 28)}...';
                          name = s;
                        }
                        if (artist.length > 30) {
                          String s = '${artist.substring(0, 31)}...';
                          artist = s;
                        }
                        return musicTile(played, i, name, artist, context);
                      },
                    ),
                  )),
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
              startPlayer(this.widget.songs[i], i);
            },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
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
                    ? (this.widget.playerState == PlayerState.playing
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

  pause() async {
    int rs = await this.widget.mediaPlayer.pauseSong();
    if (rs == 1) {
      setState(() {
        if (this.widget.start) {
          this.widget.start = false;
        }
        this.widget.playerState = PlayerState.paused;
        print('pause ${this.widget.position}');
      });
      this.widget.callBackToState(
            this.widget.playerState,
            this.widget.duration,
            this.widget.position,
          );
    }
  }

  resume() async {
    if (this.widget.start) {
      startPlayer(this.widget.playingSong, this.widget.playingIndex);
    } else {
      int rs = await this.widget.mediaPlayer.resumeSong();
      if (rs == 1) {
        setState(() {
          this.widget.playerState = PlayerState.playing;
          if (this.widget.start) {
            this.widget.start = false;
          }
          print('resume $this.widget.position');
        });
        setHandlers();
      }
    }
  }

  setHandlers() {
    this.widget.mediaPlayer.setDurationHandler((d) {
      setState(() {
        this.widget.duration = d;
      });
    });
    this.widget.mediaPlayer.setPositionHandler((p) {
      setState(() {
        this.widget.position = p;
        print('this.widget.position1 is $p');
      });
    });
    this.widget.mediaPlayer.setCompletionHandler(() async {
      setState(() {
        int newi;
        if (this.widget.playMode == PlayMode.loop) {
          newi = this.widget.nextSong(this.widget.playingIndex);
        } else if (this.widget.playMode == PlayMode.repeat) {
          newi = this.widget.playingIndex;
        } else {
          Random random = new Random();
          newi = random.nextInt(this.widget.songs.length);
        }
        this.widget.playingSong = this.widget.songs[newi];
        this.widget.playingIndex = newi;
      });
      startPlayer(
        this.widget.songs[this.widget.playingIndex],
        this.widget.playingIndex,
      );
    });
    this.widget.mediaPlayer
      ..setErrorHandler((msg) {
        setState(() {
          print('msg is $msg');
          this.widget.playerState = PlayerState.stopped;
          this.widget.duration = new Duration(seconds: 0);
          this.widget.position = new Duration(seconds: 0);
        });
      });
  }

  startPlayer(Song song, int i) async {
    print(song.data);
    print(song.displayName);
    int rs = await this.widget.mediaPlayer.playMusic(song.data);
    if (rs == 1) {
      setState(() {
        this.widget.playingSong = song;
        this.widget.playingIndex = i;
        if (this.widget.start) {
          this.widget.start = false;
        }
        this.widget.playerState = PlayerState.playing;
        print('here $this.widget.playerState');
      });
      bool isPlaying =
          this.widget.playerState == PlayerState.paused ? false : true;
      await MyNotification.showNotification(song.artist, song.title, isPlaying)
          .then((value) {
        print('notification started');
      }).catchError((e) {
        print('notifiaciotn errroroo');
        print(e.toString());
      });
      await sharedPreferences.setInt("lastSong", song.id);

      this.widget.callBackToUpdateSong(this.widget.playingSong,
          this.widget.playingIndex, this.widget.start, this.widget.playerState);
      setHandlers();
    }
  }

  myBottomSheet(BuildContext context, Song song) {
    print(song.artist);
    print(song.duration);
    print(song.artistId);
    int dur = song.duration;
    String min = (dur / 60).toStringAsFixed(0);
    double width = MediaQuery.of(context).size.width;
    int minutes = int.parse(min);
    int seconds = dur % 60;
    return showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (context) {
          return Container(
              height: 200,
              decoration: BoxDecoration(
                  color: black.withOpacity(0.8),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0))),
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                      onTap: () {
                        print('send song');
                      },
                      child: Container(
                          padding: EdgeInsets.symmetric(vertical: 5.0),
                          child: Text(
                            "Send Song",
                            style: TextStyle(fontSize: 18.0, color: white),
                          ))),
                  InkWell(
                      onTap: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsPage(
                                song: song,
                              ),
                            ));
                        Navigator.pop(context);
                      },
                      child: Container(
                          padding: EdgeInsets.symmetric(vertical: 5.0),
                          child: Text(
                            "Details",
                            style: TextStyle(fontSize: 18.0, color: white),
                          ))),
                  SizedBox(
                    width: width * 0.8,
                    child: Divider(
                      height: 5.0,
                      color: white.withOpacity(0.3),
                      thickness: 0.5,
                    ),
                  ),
                  InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                          padding: EdgeInsets.symmetric(vertical: 5.0),
                          child: Text(
                            "Cancel",
                            style: TextStyle(fontSize: 18.0, color: white),
                          ))),
                ],
              ));
        });
  }
}
