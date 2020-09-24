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
  Function callBackToState;
  Function callBackToPosition;
  Function callBackToNext;
  Function callBackToStart;
  Function callBackToMode;
  Function randomSong;
  Function callBackToDuration;
  Function nextSong;
  Function prevSong;
  List<Song> songs;
  PlayMusic(
      {this.duration,
      this.callBackToNext,
      this.prevSong,
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
  _PlayMusicState createState() => _PlayMusicState();
}

class _PlayMusicState extends State<PlayMusic>
    with SingleTickerProviderStateMixin {
  bool play = true;
  bool faved = false;
  SharedPreferences sharedPreferences;
  AnimationController animationController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    print(this.widget.mediaPlayer);
    MyNotification.setListeners('play', () async {
      await resume();
    });
    MyNotification.setListeners('pause', () async {
      await pause();
    });
    MyNotification.setListeners('next', () async {
      int newi;
      if (this.widget.playMode != PlayMode.shuffle) {
        newi = this.widget.nextSong(this.widget.index);
      } else {
        newi = this.widget.randomSong();
      }
      setState(() {
        this.widget.song = this.widget.songs[newi];
        this.widget.index = newi;
        if (animationController.status == AnimationStatus.dismissed) {
          animationController.forward();
        }
      });
      await startPlayer(
        this.widget.songs[newi],
      );
    });
    MyNotification.setListeners('prev', () async {
      int newi;
      if (this.widget.playMode != PlayMode.shuffle) {
        newi = this.widget.prevSong(this.widget.index);
      } else {
        newi = this.widget.randomSong();
      }
      setState(() {
        this.widget.song = this.widget.songs[newi];
        this.widget.index = newi;
      });
      await startPlayer(this.widget.songs[newi]);
    });
    if (this.widget.mediaPlayer != null) {
      resumePlayer();
    }
    if (favs.contains(this.widget.song.id.toString())) {
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
    print(this.widget.duration);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    List<String> dur = this.widget.duration.toString().split(':');
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
              child: this.widget.duration == null
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
                                  this.widget.playerState,
                                  this.widget.duration,
                                  this.widget.position);
                            });
                          },
                          min: 0.0,
                          max: this.widget.duration.inMilliseconds.toDouble()),
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
                InkWell(
                  onTap: () async {
                    int newi;
                    if (this.widget.playMode != PlayMode.shuffle) {
                      newi = this.widget.prevSong(this.widget.index);
                    } else {
                      newi = this.widget.randomSong();
                    }
                    setState(() {
                      this.widget.song = this.widget.songs[newi];
                      this.widget.index = newi;
                    });
                    await startPlayer(this.widget.songs[newi]);
                    // int newi = this.widget.prevSong(this.widget.index);
                    // setState(() {
                    //   this.widget.song = this.widget.songs[newi];
                    //   this.widget.index = newi;
                    // });
                    // startPlayer(
                    //   this.widget.songs[newi],
                    // );
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: orange,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    if (this.widget.playerState == PlayerState.playing) {
                      await MyNotification.hideNotification();
                      pause();
                    } else {
                      await MyNotification.showNotification(
                          this.widget.song.artist,
                          this.widget.song.title,
                          true);
                      resume();
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
                    // Icon(
                    //   Icons.play_arrow,
                    //   color: white,
                    //   size: 40,
                    // ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    int newi;
                    if (this.widget.playMode != PlayMode.shuffle) {
                      newi = this.widget.nextSong(this.widget.index);
                    } else {
                      newi = this.widget.randomSong();
                    }
                    setState(() {
                      this.widget.song = this.widget.songs[newi];
                      this.widget.index = newi;
                      if (animationController.status ==
                          AnimationStatus.dismissed) {
                        animationController.forward();
                      }
                    });
                    await startPlayer(
                      this.widget.songs[newi],
                    );
                  },
                  child: Icon(
                    Icons.arrow_forward_ios,
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
                  this.widget.playMode == PlayMode.loop
                      ? IconButton(
                          icon: Icon(Icons.repeat),
                          onPressed: () {
                            setState(() {
                              this.widget.playMode = PlayMode.repeat;
                            });
                            this.widget.callBackToMode(this.widget.playMode);
                          },
                          color: white.withOpacity(0.5),
                        )
                      : this.widget.playMode == PlayMode.repeat
                          ? IconButton(
                              icon: Icon(Icons.repeat_one),
                              onPressed: () {
                                setState(() {
                                  this.widget.playMode = PlayMode.shuffle;
                                });
                                this
                                    .widget
                                    .callBackToMode(this.widget.playMode);
                              },
                              color: white.withOpacity(0.5),
                            )
                          : IconButton(
                              icon: Icon(Icons.shuffle),
                              onPressed: () {
                                setState(() {
                                  this.widget.playMode = PlayMode.loop;
                                });
                                this
                                    .widget
                                    .callBackToMode(this.widget.playMode);
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

  startPlayer(Song song) async {
    print(song.data);
    print(song.displayName);
    int rs = await this.widget.mediaPlayer.playMusic(song.data);
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
    if (this.widget.start) {
      setState(() {
        this.widget.start = false;
      });
      this.widget.callBackToStart();
    }
    setHandlers();
  }

  pause() async {
    int rs = await this.widget.mediaPlayer.pauseSong();
    if (rs == 1) {
      setState(() {
        animationController.reverse();
        this.widget.playerState = PlayerState.paused;
      });
      this.widget.callBackToState(
          this.widget.playerState, this.widget.duration, this.widget.position);
    }
  }

  resume() async {
    if (this.widget.start) {
      startPlayer(this.widget.song);
      setState(() {
        if (this.widget.start) {
          this.widget.start = false;
          this.widget.callBackToStart();
        }
        animationController.forward();
        this.widget.playerState = PlayerState.playing;
        this.widget.callBackToState(this.widget.playerState,
            this.widget.duration, this.widget.position);
      });
    } else {
      int rs = await this.widget.mediaPlayer.resumeSong();
      if (rs == 1) {
        setState(() {
          animationController.forward();
          this.widget.playerState = PlayerState.playing;
          if (this.widget.start) {
            this.widget.start = false;
            this.widget.callBackToStart();
          }
        });
        this.widget.callBackToState(this.widget.playerState,
            this.widget.duration, this.widget.position);
      }
    }
  }

  void resumePlayer() {
    if (this.widget.playerState == PlayerState.playing) {
      setState(() {
        animationController.forward();
      });
    }
    setHandlers();
  }

  setHandlers() {
    this.widget.mediaPlayer.setDurationHandler((d) {
      setState(() {
        this.widget.duration = d;
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
      int newi;
      if (this.widget.playMode == PlayMode.loop) {
        newi = this.widget.nextSong(this.widget.index);
      } else if (this.widget.playMode == PlayMode.repeat) {
        newi = this.widget.index;
      } else {
        Random random = new Random();
        newi = random.nextInt(this.widget.songs.length);
      }
      print('new index is $newi');
      this.widget.song = this.widget.songs[newi];
      this.widget.index = newi;
      print('-------------------------------');
      await startPlayer(this.widget.songs[newi]);
      print('+++++++++++++++++++++++++++++');
      this.widget.callBackToNext(newi);
    });
    this.widget.mediaPlayer
      ..setErrorHandler((msg) {
        setState(() {
          print('errorro omsg is $msg');
          this.widget.playerState = PlayerState.stopped;
          this.widget.duration = new Duration(seconds: 0);
          this.widget.position = new Duration(seconds: 0);
        });
      });
  }

  addFav() {
    favs.add(this.widget.song.id.toString());
    sharedPreferences.setStringList('fav', favs);
    setState(() {
      faved = true;
    });
  }

  removeFav() {
    favs.remove(this.widget.song.id.toString());
    sharedPreferences.setStringList('fav', favs);
    setState(() {
      faved = false;
    });
  }
}
