import 'dart:io';
import 'package:flutter/material.dart';
import 'package:music_player/screens/bottomSheet.dart';
import 'package:music_player/services/MediaPlayer.dart';
import 'package:music_player/screens/previewLogo.dart';
import 'package:music_player/services/songModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:music_player/services/notification.dart';
import '../constants.dart';

class PlayMusic extends StatefulWidget {
  MediaPlayer mediaPlayer;
  PlayMode playMode;
  Song song;
  bool start;
  PlayerState playerState;
  Duration duration;
  Duration position;
  int index;
  Function savePlayMode;
  Function nextSong;
  Function prevSong;
  List<Song> songs;
  PlayMusic({
    this.duration,
    this.prevSong,
    this.index,
    this.songs,
    this.start,
    this.nextSong,
    this.playMode,
    this.position,
    this.playerState,
    this.song,
    this.mediaPlayer,
    this.savePlayMode,
  });

  @override
  _PlayMusicState createState() => _PlayMusicState(
        playMode: playMode,
        playerState: playerState,
        start: start,
        playingIndex: index,
        playingSong: song,
        position: position,
        duration: duration,
      );
}

class _PlayMusicState extends State<PlayMusic>
    with SingleTickerProviderStateMixin {
  PlayMode playMode;
  PlayerState playerState;
  Song playingSong;
  Duration duration;
  Duration position;
  int playingIndex;
  bool start;
  _PlayMusicState({
    this.duration,
    this.position,
    this.start,
    this.playingSong,
    this.playerState,
    this.playMode,
    this.playingIndex,
  });
  bool play = true;
  bool onScreen;
  bool faved = false;
  SharedPreferences sharedPreferences;
  AnimationController animationController;
  @override
  void initState() {
    super.initState();
    initSp();
    playingSong = this.widget.song;
    playingIndex = this.widget.index;
    playerState = this.widget.playerState;
    start = this.widget.start;
    duration = this.widget.duration;
    position = this.widget.position;
    onScreen = true;
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    MyNotification.setListeners('play', () {
      resume(true);
    });
    MyNotification.setListeners('pause', () async {
      pause(true);
    });
    MyNotification.setListeners('next', () {
      int newi = this.widget.nextSong(playingIndex, false, playMode);
      startPlayer(this.widget.songs[newi], newi);
    });
    MyNotification.setListeners('prev', () {
      int newi = this.widget.prevSong(playingIndex);
      startPlayer(this.widget.songs[newi], newi);
    });
    if (this.widget.mediaPlayer != null) {
      resumePlayer();
    }
    if (favs.contains(playingSong.id.toString())) {
      faved = true;
    }
    setHandlers();
  }

  initSp() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    super.dispose();
    onScreen = false;
    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String name = playingSong.title;
    if (name.length > 21) {
      String s = '${name.substring(0, 22)}...';
      name = s;
    }
    String artist = playingSong.artist;
    if (artist.length > 31) {
      String s = '${artist.substring(0, 30)}...';
      artist = s;
    }
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    List<String> dur = duration.toString().split(':');
    List<String> pos = position.toString().split(':');
    double h = height * 0.95;
    return WillPopScope(
      onWillPop: () async {
        await Future.delayed(Duration(microseconds: 1));
        List<dynamic> list = [
          playingSong,
          playingIndex,
          duration,
          position,
          playerState,
          playMode,
          start,
        ];
        Navigator.pop(context, list);
        return true;
      },
      child: GestureDetector(
        onVerticalDragStart: (details) {
          print(details);
        },
        onVerticalDragEnd: (details) {
          print(details);
        },
        onVerticalDragUpdate: (details) async {
          // Note: Sensitivity is integer used when you don't want to mess up vertical drag
          if (details.delta.dy > 4.5) {
            List<dynamic> list = [
              playingSong,
              playingIndex,
              duration,
              position,
              playerState,
              playMode,
              start,
            ];
            Navigator.pop(context, list);
          }
        },
        // onVerticalDragUpdate: (details) {
        //   // Note: Sensitivity is integer used when you don't want to mess up vertical drag
        //   if (details.delta.dx > 4.5) {
        //     // Right Swipe
        //   } else if (details.delta.dx < -4.5) {
        //     //Left Swipe
        //   }
        // },
        // onVerticalDragStart: (details) => {

        // // },
        // onPanUpdate: (details) {
        //   if (details.delta.dy < 0) {
        //     print('swipeee down');
        //     List<dynamic> list = [
        //       playingSong,
        //       playingIndex,
        //       duration,
        //       position,
        //       playerState,
        //       playMode,
        //       start
        //     ];
        //     Navigator.pop(context, list);
        //   }
        // },
        child: Container(
          height: h,
          decoration: BoxDecoration(
              color: mgrey,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              divider(h),
              SizedBox(
                width: width * 0.1,
                height: h * 0.001,
                child: Center(
                  child: Divider(
                    color: white.withOpacity(0.5),
                    thickness: 2.0,
                  ),
                ),
              ),
              SizedBox(
                height: h * 0.005,
              ),
              SizedBox(
                width: width * 0.1,
                height: h * 0.005,
                child: Center(
                  child: Divider(
                    color: white.withOpacity(0.5),
                    thickness: 2.0,
                  ),
                ),
              ),
              SizedBox(
                height: h * 0.03,
              ),
              Center(
                child: Material(
                  elevation: 2.5,
                  borderRadius: BorderRadius.circular(20.0),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: SizedBox(
                          width: h * 0.4,
                          height: h * 0.4,
                          child: playingSong.albumArt == ''
                              ? PreviewLogo(home: false)
                              : Image.file(
                                  File('${playingSong.albumArt}'),
                                  width: width / 2,
                                  height: width / 2,
                                  fit: BoxFit.cover,
                                ))),
                ),
              ),
              divider(h),
              Container(
                  width: width,
                  height: h * 0.05,
                  child: duration == null
                      ? Container()
                      : SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                              activeTrackColor: orange,
                              thumbColor: orange,
                              overlayColor: orange.withOpacity(0.2),
                              inactiveTrackColor: orange.withOpacity(0.2),
                              thumbShape: RoundSliderThumbShape(
                                  enabledThumbRadius: 5.0)),
                          child: Slider(
                              value: position?.inMilliseconds?.toDouble() ?? 0,
                              onChanged: (val) {
                                // double pos = await

                                setState(() {
                                  // position =
                                  //     Duration(seconds: (val/1000).roundToDouble());
                                  this
                                      .widget
                                      .mediaPlayer
                                      .seekSong((val / 1000).roundToDouble());
                                  Duration dd = Duration(
                                      milliseconds:
                                          ((val / 1000).roundToDouble() * 1000)
                                              .toInt());
                                  position = dd;
                                  // this.widget.callBackToState(playerState,
                                  //     duration, position);
                                });
                              },
                              min: 0.0,
                              max: duration.inMilliseconds.toDouble()),
                        )),
              Container(
                width: width * 0.8,
                height: h * 0.03,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${pos[1]}:${pos[2].substring(0, pos[2].lastIndexOf('.'))}',
                      style: TextStyle(color: orange, letterSpacing: 1),
                    ),
                    Text(
                      '${dur[1]}:${dur[2].substring(0, dur[2].lastIndexOf('.'))}',
                      style: TextStyle(color: white, letterSpacing: 1),
                    ),
                  ],
                ),
              ),
              divider(h),
              Container(
                width: width * 0.8,
                height: h * 0.05,
                child: Center(
                  child: Text(name,
                      style: TextStyle(
                        color: white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ),
              divider(h),
              Container(
                height: h * 0.05,
                width: width * 0.8,
                child: Center(
                  child: Text(artist,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: white,
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      )),
                ),
              ),
              divider(h),
              Container(
                width: width * 0.8,
                height: h * 0.2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        int newi = this.widget.prevSong(playingIndex);
                        playingIndex = newi;
                        startPlayer(this.widget.songs[newi], newi);
                      },
                      child: Container(
                        height: h * 0.2,
                        child: Icon(
                          Icons.skip_previous,
                          color: orange,
                          size: 40,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (playerState == PlayerState.playing) {
                          await MyNotification.hideNotification();
                          pause(false);
                        } else {
                          await MyNotification.showNotification(
                            this.widget.song.artist,
                            this.widget.song.title,
                            this.widget.song.albumArt,
                            true,
                          );
                          resume(false);
                        }
                      },
                      child: Container(
                        height: h * 0.2,
                        child: CircleAvatar(
                          backgroundColor: orange,
                          radius: 30,
                          child: AnimatedIcon(
                            progress: animationController,
                            icon: AnimatedIcons.play_pause,
                            color: white,
                            size: 35,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        int newi =
                            this.widget.nextSong(playingIndex, false, playMode);
                        print(newi);
                        startPlayer(this.widget.songs[newi], newi);
                      },
                      child: Container(
                        height: h * 0.2,
                        child: Icon(
                          Icons.skip_next,
                          size: 40,
                          color: orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      !faved
                          ? IconButton(
                              icon: Icon(Icons.favorite_border),
                              onPressed: () {
                                addFav();
                              },
                              color: white.withOpacity(0.5),
                            )
                          : IconButton(
                              icon: Icon(
                                Icons.favorite,
                                color: orange,
                              ),
                              onPressed: () {
                                removeFav();
                              },
                              color: white.withOpacity(0.5),
                            ),
                      playMode == PlayMode.loop
                          ? IconButton(
                              icon: Icon(Icons.repeat),
                              onPressed: () async {
                                setState(() {
                                  playMode = PlayMode.repeat;
                                  shuffleList.clear();
                                });
                                await this.widget.savePlayMode(playMode);

                                // this.widget.callBackToMode(playMode);
                              },
                              color: white.withOpacity(0.5),
                            )
                          : playMode == PlayMode.repeat
                              ? IconButton(
                                  icon: Icon(Icons.repeat_one),
                                  onPressed: () async {
                                    setState(() {
                                      playMode = PlayMode.shuffle;
                                      shuffleList.add(playingIndex);
                                    });
                                    await this.widget.savePlayMode(playMode);

                                    // this.widget.callBackToMode(playMode);
                                  },
                                  color: white.withOpacity(0.5),
                                )
                              : IconButton(
                                  icon: Icon(Icons.shuffle),
                                  onPressed: () async {
                                    setState(() {
                                      playMode = PlayMode.loop;
                                      shuffleList.clear();
                                    });
                                    await this.widget.savePlayMode(playMode);
                                    // this.widget.callBackToMode(playMode);
                                  },
                                  color: white.withOpacity(0.5),
                                ),
                      IconButton(
                        icon: Icon(Icons.more_horiz),
                        onPressed: () {
                          myBottomSheet(context, playingSong);
                        },
                        color: white.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
              divider(h),
            ],
          ),
        ),
      ),
    );
  }

  Container divider(double h) {
    return Container(
      height: h * 0.02,
    );
  }

  startPlayer(Song song, int p) async {
    print(song.data);
    print(song.displayName);
    await this.widget.mediaPlayer.stopSong();
    int rs = await this.widget.mediaPlayer.playMusic(song.data);
    if (rs == 1) {
      setState(() {
        playingSong = song;
        playingIndex = p;
        playerState = PlayerState.playing;
        if (this.widget.start) {
          this.widget.start = false;
        }
      });
      bool isPlaying = playerState == PlayerState.paused ? false : true;
      await MyNotification.showNotification(
        song.artist,
        song.title,
        song.albumArt,
        isPlaying,
      ).then((value) {
        print('notification started');
      }).catchError((e) {
        print('notifiaciotn errroroo');
        print(e.toString());
      });
      await sharedPreferences.setInt("lastSong", song.id);
      try {
        animationController.forward();
      } on TickerCanceled {}
    }
  }

  pause(bool fromNotification) async {
    print('I am Caleeeeeddddddddddd');
    int rs = await this.widget.mediaPlayer.pauseSong();
    if (rs == 1) {
      playerState = PlayerState.paused;
      try {
        if (onScreen || !fromNotification) {
          animationController.reverse();
        }
      } on TickerCanceled {
        print('asfas');
      }
    }
  }

  resume(bool fromNotification) async {
    if (this.widget.start) {
      startPlayer(playingSong, playingIndex);
    } else {
      int rs = await this.widget.mediaPlayer.resumeSong();
      if (rs == 1) {
        setState(() {
          playerState = PlayerState.playing;
        });
        if (this.widget.start) {
          this.widget.start = false;
        }
        try {
          if (onScreen || !fromNotification) {
            animationController.forward();
          }
        } on TickerCanceled {}
      }
    }
  }

  void resumePlayer() {
    if (playerState == PlayerState.playing) {
      try {
        animationController.forward();
        setState(() {});
      } on TickerCanceled {}
    }
    // setHandlers();
  }

  setHandlers() {
    this.widget.mediaPlayer.setDurationHandler((d) {
      setState(() {
        duration = d;
      });
      // this.widget.callBackToDuration(d);
    });
    this.widget.mediaPlayer.setPositionHandler((p) {
      setState(() {
        position = p;
      });
      // this.widget.callBackToPosition(p);
    });
    this.widget.mediaPlayer.setCompletionHandler(() async {
      int newi = this.widget.nextSong(playingIndex, true, playMode);
      print('(((((((((((((((((((((((((((((((((((((((((((((( $newi');
      startPlayer(this.widget.songs[newi], newi);
      print('+++++++++++++++++++++++++++++');
    });
    this.widget.mediaPlayer
      ..setErrorHandler((msg) {
        setState(() {
          print('errorro omsg is $msg');
          playerState = PlayerState.stopped;
          duration = new Duration(seconds: 0);
          position = new Duration(seconds: 0);
        });
      });
  }

  addFav() {
    favs.add(playingSong.id.toString());
    sharedPreferences.setStringList('fav', favs);
    setState(() {
      faved = true;
    });
  }

  removeFav() {
    favs.remove(playingSong.id.toString());
    sharedPreferences.setStringList('fav', favs);
    setState(() {
      faved = false;
    });
  }
}
