import 'dart:io';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:music_player/constants.dart';
import 'package:music_player/detailsPage.dart';
import 'package:flutter/services.dart';
import 'package:music_player/MediaPlayer.dart';
import 'package:music_player/loader.dart';
import 'package:music_player/playMusic.dart';
import 'package:music_player/previewLogo.dart';
import 'package:music_player/services/scanMusic.dart';
import 'package:music_player/songModel.dart';
import 'package:permission_handler/permission_handler.dart';

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> with SingleTickerProviderStateMixin {
  final key = GlobalKey<ScaffoldState>();
  final Permission _permission = Permission.storage;
  List<String> files = new List();
  List<Song> songs = new List<Song>();
  PermissionStatus _permissionStatus = PermissionStatus.undetermined;
  bool start = true;
  bool play = true;
  Duration duration;
  Duration position;
  Song playingSong;
  int playingIndex;
  PlayerState playerState;
  PlayMode playMode;
  ScrollController scrollController;
  MediaPlayer mediaPlayer;
  bool listfetched = false;
  AnimationController _animationController;

  void _listenForPermissionStatus() async {
    final status = await _permission.status;
    setState(() => _permissionStatus = status);
  }

  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();

    setState(() {
      print('request $status');
      _permissionStatus = status;
      print('request $_permissionStatus');
    });
  }

  getPermission() async {
    await requestPermission(_permission);
    if (_permissionStatus.isDenied) {
      key.currentState.showSnackBar(SnackBar(
        content: Text("Permission Required Restart the App"),
      ));
    } else {
      playerState = PlayerState.stopped;
      playMode = PlayMode.loop;
      mediaPlayer = new MediaPlayer();
      _animationController = AnimationController(
          vsync: this, duration: Duration(milliseconds: 300));
      getAllMusic();
    }
  }

  @override
  void initState() {
    super.initState();
    _listenForPermissionStatus();
    getPermission();
    scrollController = new ScrollController();
  }

  getAllMusic() async {
    songs = await mediaPlayer.getMusic();
    songs.sort((a, b) {
      if ((a.title[0].codeUnitAt(0) >= ('a'.codeUnitAt(0)) &&
              a.title[0].codeUnitAt(0) <= ('z'.codeUnitAt(0))) ||
          (a.title[0].codeUnitAt(0) >= ('A'.codeUnitAt(0)) &&
              a.title[0].codeUnitAt(0) <= ('Z'.codeUnitAt(0)))) {
        if ((b.title[0].codeUnitAt(0) >= ('a'.codeUnitAt(0)) &&
                b.title[0].codeUnitAt(0) <= 'z'.codeUnitAt(0)) ||
            (b.title[0].codeUnitAt(0) >= ('A'.codeUnitAt(0))) &&
                b.title[0].codeUnitAt(0) <= ('Z'.codeUnitAt(0))) {
          return a.title.compareTo(b.title);
        } else {
          return -1;
        }
      } else {
        if ((b.title[0].codeUnitAt(0) >= ('a'.codeUnitAt(0)) &&
                b.title[0].codeUnitAt(0) <= ('z'.codeUnitAt(0))) ||
            (b.title[0].codeUnitAt(0) >= ('A'.codeUnitAt(0)) &&
                b.title[0].codeUnitAt(0) <= ('Z'.codeUnitAt(0)))) {
          return 1;
        } else {
          return a.title.compareTo(b.title);
        }
      }
    });
    setState(() {
      listfetched = true;
      if (playingSong == null) {
        playingSong = songs[0];
        playingIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: black,
        statusBarColor: black,
        systemNavigationBarIconBrightness: Brightness.light
        // navigation bar color
        ));
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: black,
        key: key,
        body: listfetched
            ? Column(
                children: [
                  topContainer(height),
                  Expanded(
                      child: Scrollbar(
                    controller: scrollController,
                    child: ListView.builder(
                      controller: scrollController,
                      shrinkWrap: true,
                      itemCount: songs.length,
                      itemBuilder: (context, i) {
                        String name = songs[i].title;
                        String artist = songs[i].artist;
                        bool played = false;
                        if (playingSong != null) {
                          played = songs[i].id == playingSong.id ? true : false;
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
                  bottomContainer(height, width)
                ],
              )
            : Center(
                child: Loader2(),
              ),
      ),
    );
  }

  InkWell musicTile(
      bool played, int i, String name, String artist, BuildContext context) {
    return InkWell(
      onTap: played
          ? () async {
              showPlayer();
            }
          : () async {
              startPlayer(songs[i], i);
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
                    myBottomSheet(context, songs[i]);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  callBackToStop() {
    setState(() {
      playerState = PlayerState.stopped;
    });
  }

  callBackToDuration(Duration d) {
    setState(() {
      duration = d;
    });
  }

  callBackToPosition(Duration p) {
    setState(() {
      position = p;
    });
  }

  Container topContainer(double height) {
    return Container(
      height: height * 0.08,
      decoration: BoxDecoration(
        color: black,
        // borderRadius: BorderRadius.only(
        //   bottomRight: Radius.circular(20.0),
        //   bottomLeft: Radius.circular(20.0),
        // ),f
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: orange,
            ),
            color: white,
            onPressed: () {},
          ),
          PopupMenuButton(
              icon: Icon(
                Icons.more_vert,
                color: orange,
              ),
              onSelected: (val) {
                if (val == 1) {
                  print('hello seleceted');
                } else if (val == 0) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ScanMusic(
                                mediaPlayer: mediaPlayer,
                                callBackToScan: callBackToScan,
                              )));
                }
              },
              color: black,
              itemBuilder: (context) => <PopupMenuEntry<int>>[
                    PopupMenuItem<int>(
                      child: Text(
                        'Scan For Songs',
                        style: TextStyle(color: white),
                      ),
                      value: 0,
                    ),
                    PopupMenuItem<int>(
                      child: Text('About', style: TextStyle(color: white)),
                      value: 1,
                    )
                  ]),
        ],
      ),
    );
  }

  callBackToMode(PlayMode pm) {
    setState(() {
      playMode = pm;
    });
    print(playMode);
  }

  InkWell bottomContainer(double height, double width) {
    String name = playingSong.title;
    String artist = playingSong.artist;
    if (name.length > 24) {
      String s = '${name.substring(0, 25)}...';
      name = s;
    }
    if (artist.length > 31) {
      String s = '${artist.substring(0, 30)}...';
      artist = s;
    }
    return InkWell(
        onTap: () {
          showPlayer();
        },
        child: Container(
          height: height * 0.08,
          width: width,
          decoration: BoxDecoration(
              color: mgrey,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: width * 0.05,
              ),
              SizedBox(
                width: width * 0.1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: SizedBox(
                    height: height * 0.05,
                    width: height * 0.05,
                    child: playingSong.albumArt == ''
                        ? PreviewLogo(home: true)
                        : Image.file(
                            File('${playingSong.albumArt}'),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              SizedBox(
                width: width * 0.05,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(name, style: TextStyle(fontSize: 15, color: white)),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(artist, style: TextStyle(fontSize: 13, color: white)),
                  ],
                ),
              ),
              SizedBox(
                width: width * 0.05,
              ),
              SizedBox(
                width: width * 0.1,
                child: GestureDetector(
                  onTap: () {
                    playerState == PlayerState.playing ? pause() : resume();
                  },
                  child: AnimatedIcon(
                    icon: AnimatedIcons.play_pause,
                    progress: _animationController,
                    color: white,
                    size: 25,
                  ),
                ),
              ),
              SizedBox(
                width: width * 0.05,
              ),
            ],
          ),
        ));
  }

  Future showPlayer() {
    return showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
        ),
        isScrollControlled: true,
        builder: (context) {
          return PlayMusic(
            randomSong: randomSong,
            callBackToNext: callBackToNext,
            callBackToMode: callBackToMode,
            playMode: playMode,
            callBackToStart: callBackToStart,
            callBackToDuration: callBackToDuration,
            callBackToPosition: callBackToPosition,
            start: start,
            songs: songs,
            index: playingIndex,
            mediaPlayer: mediaPlayer,
            song: playingSong,
            playerState: playerState,
            duration: duration == null
                ? Duration(milliseconds: playingSong.duration)
                : duration,
            position: position == null ? Duration(milliseconds: 0) : position,
            callBackToState: callBackToState,
            nextSong: nextSong,
            prevSong: prevSong,
          );
        });
  }

  int randomSong() {
    Random random = new Random();
    int newi = random.nextInt(songs.length);
    setState(() {
      if (start) {
        start = false;
      }
      playingIndex = newi;
      playingSong = songs[newi];
    });
    return newi;
  }

  int nextSong(int i) {
    int newi = (i + 1) % songs.length;
    setState(() {
      if (start) {
        start = false;
      }
      playingIndex = newi;
      playingSong = songs[newi];
    });
    // await startPlayer(songs[newi], newi);
    return newi;
  }

  int prevSong(int i) {
    int newi = (i - 1) % songs.length;
    setState(() {
      if (start) {
        start = false;
      }
      playingIndex = newi;
      playingSong = songs[newi];
    });
    // await startPlayer(songs[newi], newi);
    return newi;
  }

  callBackToScan() {
    if (playerState == PlayerState.playing) {
      setState(() {
        start = true;
        _animationController.reverse();
        playerState = PlayerState.paused;
        print('pause $position');
      });
    }
  }

  callBackToState(PlayerState pp, Duration d, Duration p) {
    setState(() {
      playerState = pp;
      if (start) {
        start = false;
      }
      if (playerState == PlayerState.playing) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
      duration = d;
      position = p;
    });
  }

  pause() async {
    int rs = await mediaPlayer.pauseSong();
    if (rs == 1) {
      setState(() {
        if (start) {
          start = false;
        }
        _animationController.reverse();
        playerState = PlayerState.paused;
        print('pause $position');
      });
    }
  }

  resume() async {
    if (start) {
      startPlayer(songs[0], 0);
      setState(() {
        start = false;
      });
    } else {
      int rs = await mediaPlayer.resumeSong();
      if (rs == 1) {
        setState(() {
          _animationController.forward();
          playerState = PlayerState.playing;
          if (start) {
            start = false;
          }
          print('resume $position');
        });
        setHandlers();
      }
    }
  }

  setHandlers() {
    mediaPlayer.setDurationHandler((d) {
      setState(() {
        duration = d;
      });
    });
    mediaPlayer.setPositionHandler((p) {
      setState(() {
        position = p;
        print('position1 is $p');
      });
    });
    mediaPlayer.setCompletionHandler(() async {
      setState(() {
        int newi;
        if (playMode == PlayMode.loop) {
          newi = nextSong(playingIndex);
        } else if (playMode == PlayMode.repeat) {
          newi = playingIndex;
        } else {
          Random random = new Random();
          newi = random.nextInt(songs.length);
        }
        print('new jsfkafk is $newi');
        playingSong = songs[newi];
        playingIndex = newi;
      });
      print(
          'playingIndex is $playingIndex playing song is ${playingSong.displayName}');
      await startPlayer(songs[playingIndex], playingIndex);
    });
    mediaPlayer
      ..setErrorHandler((msg) {
        setState(() {
          print('msg is $msg');
          playerState = PlayerState.stopped;
          duration = new Duration(seconds: 0);
          position = new Duration(seconds: 0);
        });
      });
  }

  startPlayer(Song song, int i) async {
    print(song.data);
    print(song.displayName);
    int rs = await mediaPlayer.playMusic(song.data);
    if (rs == 1) {
      setState(() {
        _animationController.forward();
        playingSong = song;
        playingIndex = i;
        if (start) {
          start = false;
        }
        playerState = PlayerState.playing;
        print('here $playerState');
      });
    }
    setHandlers();
  }

  callBackToStart() {
    setState(() {
      start = false;
    });
  }

  callBackToNext(int i) {
    setState(() {
      playingIndex = i;
      playingSong = songs[i];
    });
    print('callBackCallerd');
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
