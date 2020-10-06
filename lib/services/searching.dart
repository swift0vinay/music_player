import 'dart:collection';

import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:music_player/services/MediaPlayer.dart';
import 'package:music_player/constants.dart';
import 'package:music_player/screens/detailsPage.dart';
import 'package:music_player/screens/loader.dart';
import 'package:music_player/services/songModel.dart';

class SearchSong extends SearchDelegate<Song> {
  List<Song> songs;
  int playingIndex;
  Song playingSong;
  PlayerState playerState;
  PlayMode playMode;
  MediaPlayer mediaPlayer;
  Function showPlayer;
  Function startMusic;
  SearchSong(
      {this.songs,
      this.showPlayer,
      this.playMode,
      this.playerState,
      this.startMusic,
      this.playingIndex,
      this.playingSong});

  @override
  ThemeData appBarTheme(BuildContext context) {
    // TODO: implement appBarTheme
    final ThemeData theme = ThemeData(
        brightness: Brightness.dark,
        accentColor: white,
        secondaryHeaderColor: white);
    return theme;
  }

  @override
  // TODO: implement searchFieldLabel
  String get searchFieldLabel => "Search Song";
  @override
  // TODO: implement searchFieldStyle
  TextStyle get searchFieldStyle => TextStyle(color: white, fontSize: 15);

  @override
  // TODO: implement textInputAction
  TextInputAction get textInputAction => TextInputAction.search;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        color: orange,
        onPressed: () {
          Navigator.pop(context);
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    ScrollController sc = new ScrollController();
    double width = MediaQuery.of(context).size.width - 50;
    double height = MediaQuery.of(context).size.height;
    List<Song> suggestions = songs;
    if (query.isEmpty) {
      SplayTreeSet suggestset = new SplayTreeSet();
      suggestions.forEach((element) {
        suggestset.add(element.title.substring(0, 1).toUpperCase());
      });
      return Container(
        height: height,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [orange, Colors.red[100]],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
        child: DraggableScrollbar.semicircle(
          labelConstraints: BoxConstraints.tightFor(width: 80.0, height: 30.0),
          controller: sc,
          child: GridView.builder(
              controller: sc,
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              itemCount: suggestset.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 10.0,
                  crossAxisCount: 3,
                  crossAxisSpacing: 10.0),
              itemBuilder: (context, i) {
                return InkWell(
                  onTap: () {
                    query = suggestset.elementAt(i);
                  },
                  child: Container(
                    width: width / 3,
                    height: width / 3,
                    decoration: BoxDecoration(
                        color: black,
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Center(
                      child: Text(
                        suggestset.elementAt(i),
                        style: TextStyle(color: orange, fontSize: 30),
                      ),
                    ),
                  ),
                );
              }),
        ),
      );
    } else {
      List<Song> suggests = List.from(songs.where((element) =>
          element.title.toLowerCase().startsWith(query.toLowerCase())));
      return Container(
          color: black,
          height: height,
          child: suggests.isEmpty
              ? Center(
                  child: Text('No Such Song', style: TextStyle(color: white)))
              : DraggableScrollbar.semicircle(
                  controller: sc,
                  labelConstraints:
                      BoxConstraints.tightFor(width: 80.0, height: 30.0),
                  child: ListView.builder(
                      controller: sc,
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      shrinkWrap: true,
                      itemCount: suggests.length,
                      itemBuilder: (context, i) {
                        String name = suggests[i].title;
                        String artist = suggests[i].artist;
                        int indexofSonginList = songs.indexWhere(
                            (element) => element.id == suggests[i].id);
                        bool played =
                            playingIndex == indexofSonginList ? true : false;
                        if (name.length > 27) {
                          String s = '${name.substring(0, 28)}...';
                          name = s;
                        }
                        if (artist.length > 30) {
                          String s = '${artist.substring(0, 31)}...';
                          artist = s;
                        }
                        return musicTile(
                            played, i, name, artist, context, suggests);
                      }),
                ));
    }
  }

  InkWell musicTile(bool played, int i, String name, String artist,
      BuildContext context, List<Song> suggests) {
    return InkWell(
      onTap: played
          ? () {
              showPlayer();
            }
          : () async {
              playingSong = suggests[i];
              playingIndex =
                  songs.indexWhere((element) => element.id == playingSong.id);
              playerState = PlayerState.playing;
              await startMusic(playingSong, playingIndex);
              Navigator.pop(context);
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
                    myBottomSheet(context, suggests[i]);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
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
