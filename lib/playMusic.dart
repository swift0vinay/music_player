import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:music_player/MediaPlayer.dart';
import 'package:music_player/previewLogo.dart';
import 'package:music_player/songModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:music_player/notification.dart';
import 'constants.dart';

class PlayMusic extends StatefulWidget {
  MediaPlayer mediaPlayer;
  PlayMode playMode;
  Song song;
  bool start;
  PlayerState playerState;
  Duration duration;
  Duration position;
  int index;
  Function callBackToUpdateSong;
  Function callBackToState;
  Function callBackToPosition;
  Function callBackToStart;
  Function callBackToMode;
  Function randomSong;
  Function callBackToDuration;
  Function nextSong;
  Function prevSong;
  List<Song> songs;
  PlayMusic(
      {this.duration,
      this.prevSong,
      this.callBackToUpdateSong,
      this.index,
      this.songs,
      this.start,
      this.callBackToMode,
      this.nextSong,
      this.playMode,
      this.callBackToDuration,
      this.callBackToPosition,
      this.callBackToStart,
      this.randomSong,
      this.callBackToState,
      this.position,
      this.playerState,
      this.song,
      this.mediaPlayer});
  @override
  _PlayMusicState createState() => _PlayMusicState(
        playMode: playMode,
        playerState: playerState,
        playingIndex: index,
        playingSong: song,
        duration: duration,
        position: position,
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
  _PlayMusicState(
      {this.duration,
      this.position,
      this.playingSong,
      this.playerState,
      this.playMode,
      this.playingIndex});
  bool play = true;
  bool onScreen;
  bool faved = false;
  SharedPreferences sharedPreferences;
  AnimationController animationController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    onScreen = true;
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    // print(this.widget.mediaPlayer);
    MyNotification.setListeners('play', () {
      resume(true);
    });
    MyNotification.setListeners('pause', () async {
      // await MyNotification.hideNotification();
      pause(true);
    });
    MyNotification.setListeners('next', () {
      int newi = this.widget.nextSong(this.widget.index);
      startPlayer(this.widget.songs[newi], newi);
    });
    MyNotification.setListeners('prev', () {
      int newi = this.widget.prevSong(this.widget.index);
      startPlayer(this.widget.songs[newi], newi);
    });
    if (this.widget.mediaPlayer != null) {
      resumePlayer();
    }
    if (favs.contains(playingSong.id.toString())) {
      faved = true;
    }
    initSp();
  }

  initSp() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    super.dispose();
    print(
        'dosopose calllled//////////////////////////////////////////////////');
    onScreen = false;
    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String name = this.widget.song.title;
    if (name.length > 21) {
      String s = '${name.substring(0, 22)}...';
      name = s;
    }
    String artist = this.widget.song.artist;
    if (artist.length > 31) {
      String s = '${artist.substring(0, 30)}...';
      artist = s;
    }
    // print(duration);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    List<String> dur = duration.toString().split(':');
    List<String> pos = this.widget.position.toString().split(':');
    double h = height * 0.90;
    return Container(
      height: h,
      decoration: BoxDecoration(
          color: mgrey,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          divider(h),
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
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 5.0)),
                      child: Slider(
                          value: this
                                  .widget
                                  .position
                                  ?.inMilliseconds
                                  ?.toDouble() ??
                              0,
                          onChanged: (val) {
                            // double pos = await

                            setState(() {
                              // this.widget.position =
                              //     Duration(seconds: (val/1000).roundToDouble());
                              this
                                  .widget
                                  .mediaPlayer
                                  .seekSong((val / 1000).roundToDouble());
                              Duration dd = Duration(
                                  milliseconds:
                                      ((val / 1000).roundToDouble() * 1000)
                                          .toInt());
                              this.widget.position = dd;
                              this.widget.callBackToState(
                                  playerState, duration, this.widget.position);
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
                  '${pos[1]} : ${pos[2].substring(0, pos[2].lastIndexOf('.'))}',
                  style: TextStyle(color: orange),
                ),
                Text(
                  '${dur[1]} : ${dur[2].substring(0, dur[2].lastIndexOf('.'))}',
                  style: TextStyle(color: white),
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
                IconButton(
                  onPressed: () {
                    int newi = this.widget.prevSong(playingIndex);
                    startPlayer(this.widget.songs[newi], newi);
                  },
                  icon: Icon(
                    Icons.skip_previous,
                    color: orange,
                    size: 30,
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
                          true);
                      resume(false);
                    }
                  },
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
                IconButton(
                  onPressed: () async {
                    int newi = this.widget.nextSong(playingIndex);
                    startPlayer(this.widget.songs[newi], newi);
                  },
                  icon: Icon(
                    Icons.skip_next,
                    size: 30,
                    color: orange,
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
                          onPressed: () {
                            setState(() {
                              playMode = PlayMode.repeat;
                            });
                            this.widget.callBackToMode(playMode);
                          },
                          color: white.withOpacity(0.5),
                        )
                      : playMode == PlayMode.repeat
                          ? IconButton(
                              icon: Icon(Icons.repeat_one),
                              onPressed: () {
                                setState(() {
                                  playMode = PlayMode.shuffle;
                                });
                                this.widget.callBackToMode(playMode);
                              },
                              color: white.withOpacity(0.5),
                            )
                          : IconButton(
                              icon: Icon(Icons.shuffle),
                              onPressed: () {
                                setState(() {
                                  playMode = PlayMode.loop;
                                });
                                this.widget.callBackToMode(playMode);
                              },
                              color: white.withOpacity(0.5),
                            ),
                  IconButton(
                    icon: Icon(Icons.more_horiz),
                    onPressed: () {},
                    color: white.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
          divider(h),
        ],
      ),
    );
  }

  Container divider(double h) {
    return Container(
      height: h * 0.02,
    );
  }

  startPlayer(Song song, int playingIndex) async {
    print(song.data);
    print(song.displayName);
    int rs = await this.widget.mediaPlayer.playMusic(song.data);
    if (rs == 1) {
      // setState(() {
      this.widget.song = song;
      playingIndex = playingIndex;
      if (this.widget.start) {
        this.widget.start = false;
      }
      playerState = PlayerState.playing;
      // print('here $playerState');
      // });
      bool isPlaying = playerState == PlayerState.paused ? false : true;
      await MyNotification.showNotification(song.artist, song.title, isPlaying)
          .then((value) {
        print('notification started');
      }).catchError((e) {
        print('notifiaciotn errroroo');
        print(e.toString());
      });
      await sharedPreferences.setInt("lastSong", song.id);

      try {
        animationController.forward();
        // setState(() {});
      } on TickerCanceled {}
      this.widget.callBackToUpdateSong(
          playingSong, playingIndex, this.widget.start, playerState);
      setHandlers();
    }
  }

  pause(bool fromNotification) async {
    print('I am Caleeeeeddddddddddd');
    int rs = await this.widget.mediaPlayer.pauseSong();
    if (rs == 1) {
      playerState = PlayerState.paused;
      this.widget.callBackToState(playerState, duration, this.widget.position);
      try {
        if (onScreen || !fromNotification) {
          animationController.reverse();
        }
        // setState(() {});
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
        playerState = PlayerState.playing;
        if (this.widget.start) {
          this.widget.start = false;
          this.widget.callBackToStart();
        }
        try {
          if (onScreen || !fromNotification) {
            animationController.forward();
          }
          // setState(() {});
        } on TickerCanceled {}
        this
            .widget
            .callBackToState(playerState, duration, this.widget.position);
        setHandlers();
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
    setHandlers();
  }

  setHandlers() {
    this.widget.mediaPlayer.setDurationHandler((d) {
      setState(() {
        duration = d;
      });
      this.widget.callBackToDuration(d);
    });
    this.widget.mediaPlayer.setPositionHandler((p) {
      setState(() {
        this.widget.position = p;
      });
      this.widget.callBackToPosition(p);
    });
    this.widget.mediaPlayer.setCompletionHandler(() async {
      int newi = this.widget.nextSong(playingIndex);
      print('-------------------------------');
      startPlayer(this.widget.songs[newi], newi);
      print('+++++++++++++++++++++++++++++');
    });
    this.widget.mediaPlayer
      ..setErrorHandler((msg) {
        setState(() {
          print('errorro omsg is $msg');
          playerState = PlayerState.stopped;
          duration = new Duration(seconds: 0);
          this.widget.position = new Duration(seconds: 0);
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
