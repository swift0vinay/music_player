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

  Map<String, String> lyricsMap = {};
  List<String> lyricsKey = [];
  int lyricIndex = 0;
  bool lyricFound = false;
  String prev = "";
  void execution() {
    lyricFound = false;
    lyricIndex = 0;
    lyricText = "";
    lyricsMap = {};
    lyricsKey = [];
    String fileDirectory =
        playingSong.data.substring(0, playingSong.data.lastIndexOf('.'));
    String lrcName = '$fileDirectory.lrc';
    File file = new File(lrcName);
    if (file.existsSync()) {
      lyricFound = true;
      String z = file.readAsStringSync();
      int open = -1, end = -1;
      for (int i = 0; i < z.length; i++) {
        if (z[i] == "[") {
          open = i;
        } else if (z[i] == "]") {
          end = i;
          String time = z.substring(open + 1, end);
          String content = "";
          for (int j = i + 1; j < z.length; j++) {
            if (z[j] == "[") {
              i = j - 1;
              break;
            }
            content += z[j];
          }
          if (content.trim().length > 0)
            lyricsMap.putIfAbsent(time, () => content);
        }
      }
      lyricsKey = lyricsMap.keys.toList();
    } else {
      lyricText = "No Lyrics Found";
    }
  }

  String lyricText = "";
  process(Duration position) {
    if (lyricFound) {
      String z = position.toString();
      int first = z.indexOf(":");
      String zz = z.substring(first + 1);
      int zzz = -1;
      for (int i = 0; i < lyricsKey.length - 1; i++) {
        if (zz.compareTo(lyricsKey[i]) >= 0 &&
            zz.compareTo(lyricsKey[i + 1]) <= 0) {
          zzz = i;
          break;
        }
      }
      if (zzz == -1) {
        lyricText = lyricsMap[lyricsKey.length - 1];
      } else {
        lyricIndex = zzz;
        lyricText = lyricsMap[lyricsKey[lyricIndex]];
      }
    }
  }

  lyricContainer(double width, double h) {
    return Container(
      width: width * 0.95,
      height: h * 0.12,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 5.0,
            child: Container(
              width: width * 0.95,
              child: Center(
                child: Container(
                  width: width * 0.9,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Lyrics...",
                        style: TextStyle(
                          fontSize: 10.0,
                          color: white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (!lyricFound) {
                            execution();
                          }
                        },
                        child: Icon(
                          Icons.refresh,
                          color: white,
                          size: 20.0,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10.0,
            left: 5.0,
            child: SizedBox(
              width: width * 0.90,
              height: h * 0.08,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Center(
                  child: Text(
                    "${lyricText.trim()}",
                    style: TextStyle(
                      fontSize: 12.0,
                      color: white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  parter(double width, double h) {
    return SizedBox(
      width: width * 0.1,
      height: h * 0.005,
      child: Center(
        child: Divider(
          color: white.withOpacity(0.3),
          thickness: 2.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (prev != playingSong.id.toString()) {
      prev = playingSong.id.toString();
      execution();
    }
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
    process(position);
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              divider(h),
              parter(width, h),
              SizedBox(
                height: h * 0.005,
              ),
              parter(width, h),
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
                      width: h * 0.35,
                      height: h * 0.35,
                      child: playingSong.albumArt == ''
                          ? PreviewLogo(home: false)
                          : Image.file(
                              File('${playingSong.albumArt}'),
                              width: h * 0.35,
                              height: h * 0.35,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              ),
              divider(h),
              playerSlider(width, h, context),
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
              lyricContainer(width, h),
              divider(h),
              Container(
                width: width * 0.8,
                height: h * 0.04,
                child: Center(
                  child: Text(name,
                      style: TextStyle(
                        color: white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ),
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
              playerTools(width, h),
              divider(h),
              bottomTools(h, width, context),
            ],
          ),
        ),
      ),
    );
  }

  Container playerSlider(double width, double h, BuildContext context) {
    return Container(
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
                    enabledThumbRadius: 5.0,
                  ),
                ),
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
                                ((val / 1000).roundToDouble() * 1000).toInt());
                        position = dd;
                        // this.widget.callBackToState(playerState,
                        //     duration, position);
                      });
                    },
                    min: 0.0,
                    max: duration.inMilliseconds.toDouble()),
              ));
  }

  Container playerTools(double width, double h) {
    return Container(
      width: width * 0.8,
      height: h * 0.1,
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
              int newi = this.widget.nextSong(playingIndex, false, playMode);
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
    );
  }

  Container bottomTools(double h, double width, BuildContext context) {
    return Container(
      height: h * 0.08,
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
