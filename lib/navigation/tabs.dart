import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:music_player/MediaPlayer.dart';
import 'package:music_player/homePage.dart';
import 'package:music_player/loader.dart';
import 'package:music_player/notification.dart';
import 'package:music_player/playMusic.dart';
import 'package:music_player/playlist/playlistpage.dart';
import 'package:music_player/previewLogo.dart';
import 'package:music_player/services/scanMusic.dart';
import 'package:music_player/songModel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class MainNav extends StatefulWidget {
  @override
  MainNavState createState() => MainNavState();
}

class MainNavState extends State<MainNav> with TickerProviderStateMixin {
  TabController tabController;
  final Permission _permission = Permission.storage;
  PermissionStatus _permissionStatus = PermissionStatus.undetermined;
  final tabKey = GlobalKey<ScaffoldState>();
  AnimationController _animationController;
  List<Song> songs = new List<Song>();
  bool start = true;
  bool play = true;
  Duration duration;
  Duration position;
  Song playingSong;
  int playingIndex;
  MediaPlayer mediaPlayer;
  PlayerState playerState;
  PlayMode playMode;
  bool listfetched = false;
  SharedPreferences sharedPreferences;
  List<Widget> _tabs = [
    Tab(
      text: "Songs",
    ),
    Tab(
      text: "Playlist",
    ),
  ];

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
      tabKey.currentState.showSnackBar(SnackBar(
        content: Text("Permission Required Restart the App"),
      ));
    } else {
      playerState = PlayerState.stopped;
      playMode = PlayMode.loop;
      mediaPlayer = new MediaPlayer();
      _animationController = AnimationController(
          vsync: this, duration: Duration(milliseconds: 300));
      await getAllMusic();
    }
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
      var id = sharedPreferences.getInt('lastSong');
      if (id == null) {
        playingSong = songs[0];
        playingIndex = 0;
      } else {
        int index = songs.lastIndexWhere((element) => element.id == id);
        playingIndex = index;
        playingSong = songs[playingIndex];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    tabController = new TabController(length: 2, vsync: this, initialIndex: 0);
    initSp();
    _listenForPermissionStatus();
    getPermission();
    MyNotification.setListeners('play', () {
      resume();
    });
    MyNotification.setListeners('pause', () async {
      // await MyNotification.hideNotification();
      pause();
    });
    MyNotification.setListeners('next', () {
      int newi = nextSong(playingIndex);
      setState(() {
        playingSong = songs[newi];
        playingIndex = newi;
        if (_animationController.status == AnimationStatus.dismissed) {
          _animationController.forward();
        }
      });
      startPlayer(songs[newi], newi);
    });
    MyNotification.setListeners('prev', () {
      int newi = prevSong(playingIndex);
      setState(() {
        playingSong = songs[newi];
        playingIndex = newi;
        if (_animationController.status == AnimationStatus.dismissed) {
          _animationController.forward();
        }
      });
      startPlayer(songs[newi], newi);
    });
  }

  initSp() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        key: tabKey,
        backgroundColor: black,
        appBar: AppBar(
          backgroundColor: black,
          actions: [
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
          bottom: TabBar(
            controller: tabController,
            tabs: _tabs,
            indicatorColor: orange,
            labelColor: orange,
            unselectedLabelColor: white,
          ),
        ),
        bottomNavigationBar: listfetched
            ? bottomContainer(height, width)
            : Container(
                color: white,
              ),
        body: TabBarView(
          controller: tabController,
          children: [
            MyHome(
              nextSong: nextSong,
              prevSong: prevSong,
              showPlayer: showPlayer,
              duration: duration,
              position: position,
              mediaPlayer: mediaPlayer,
              start: start,
              songs: songs,
              playMode: playMode,
              playingIndex: playingIndex,
              playingSong: playingSong,
              playerState: playerState,
              callBackToMode: callBackToMode,
              callBackToState: callBackToState,
              callBackToStart: callBackToStart,
              callBackToPosition: callBackToPosition,
              callBackToUpdateSong: callBackToUpdateSong,
              callBackToDuration: callBackToDuration,
              callBackToStop: callBackToStop,
              listfetched: listfetched,
            ),
            Playlist(
              songs: songs,
              playingSong: playingSong,
            ),
          ],
        ));
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
                  onTap: () async {
                    if (playerState == PlayerState.playing) {
                      await MyNotification.hideNotification();
                      pause();
                    } else {
                      await MyNotification.showNotification(
                          playingSong.artist, playingSong.title, true);
                      resume();
                    }
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

  pause() async {
    int rs = await mediaPlayer.pauseSong();
    if (rs == 1) {
      setState(() {
        if (start) {
          start = false;
        }
        _animationController.reverse();
        playerState = PlayerState.paused;
        // print('pause $position');
      });
    }
  }

  resume() async {
    if (start) {
      startPlayer(songs[playingIndex], playingIndex);
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
            nextSong: nextSong,
            prevSong: prevSong,
            duration: duration == null
                ? Duration(milliseconds: playingSong.duration)
                : duration,
            position: position == null ? Duration(milliseconds: 0) : position,
            mediaPlayer: mediaPlayer,
            start: start,
            songs: songs,
            playMode: playMode,
            index: playingIndex,
            song: playingSong,
            playerState: playerState,
            callBackToMode: callBackToMode,
            callBackToState: callBackToState,
            callBackToStart: callBackToStart,
            callBackToDuration: callBackToDuration,
            callBackToPosition: callBackToPosition,
            callBackToUpdateSong: callBackToUpdateSong,
          );
        });
  }

  startPlayer(Song song, int i) async {
    print(song.data);
    print(song.displayName);
    int rs = await mediaPlayer.playMusic(song.data);
    if (rs == 1) {
      bool isPlaying = playerState == PlayerState.paused ? false : true;
      await MyNotification.showNotification(song.artist, song.title, isPlaying)
          .then((value) {
        print('notification started');
      }).catchError((e) {
        print('notifiaciotn errroroo');
        print(e.toString());
      });
      await sharedPreferences.setInt("lastSong", song.id);
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

  setHandlers() {
    mediaPlayer.setDurationHandler((d) {
      setState(() {
        duration = d;
      });
    });
    mediaPlayer.setPositionHandler((p) {
      setState(() {
        position = p;
        // print('position1 is $p');
      });
    });
    mediaPlayer.setCompletionHandler(() async {
      int newi = nextSong(playingIndex);
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
    int newi;
    if (playMode == PlayMode.loop) {
      newi = (i + 1) % songs.length;
    } else if (playMode == PlayMode.repeat) {
      newi = playingIndex;
    } else {
      Random random = new Random();
      newi = random.nextInt(songs.length);
    }
    setState(() {
      if (start) {
        start = false;
      }
      playingIndex = newi;
      playingSong = songs[newi];
    });
    return newi;
  }

  int prevSong(int i) {
    int newi;
    if (playMode == PlayMode.loop) {
      newi = (i - 1) % songs.length;
    } else if (playMode == PlayMode.repeat) {
      newi = playingIndex;
    } else {
      Random random = new Random();
      newi = random.nextInt(songs.length);
    }
    setState(() {
      if (start) {
        start = false;
      }
      playingIndex = newi;
      playingSong = songs[newi];
    });
    return newi;
  }

  // ---------------------------- CALLBACKS --------------------------

  callBackToUpdateSong(Song ps, int piu, bool s, PlayerState pss) {
    setState(() {
      print(
          'updating song !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      playingSong = ps;
      playingIndex = piu;
      start = s;
      playerState = pss;
      try {
        if (playerState == PlayerState.playing) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      } on TickerCanceled {
        print('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ erererrere');
      }
    });
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

  callBackToStart() {
    setState(() {
      start = false;
    });
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

  callBackToMode(PlayMode pm) {
    setState(() {
      playMode = pm;
    });
    print(playMode);
  }
}
