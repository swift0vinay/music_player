import 'package:flutter/material.dart';
import 'package:music_player/constants.dart';
import 'package:music_player/services/songModel.dart';

class ShowFav extends StatefulWidget {
  List<Song> songs;
  Song playingSong;
  ShowFav({this.songs, this.playingSong});
  @override
  _ShowFavState createState() => _ShowFavState();
}

class _ShowFavState extends State<ShowFav> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      appBar: AppBar(
        backgroundColor: black,
        title: Text(
          "Favourites",
          style: TextStyle(color: white),
        ),
        centerTitle: true,
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
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
        itemCount: favs.length,
        itemBuilder: (context, i) {
          int index = this
              .widget
              .songs
              .indexWhere((element) => element.id.toString() == favs[i]);
          String name = this.widget.songs[index].title;
          String artist = this.widget.songs[index].artist;
          bool played = false;
          if (this.widget.playingSong != null) {
            played = this.widget.songs[index].id == this.widget.playingSong.id
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
    );
  }

  InkWell musicTile(
      bool played, int i, String name, String artist, BuildContext context) {
    return InkWell(
      // onTap: played
      //     ? () async {
      //         showPlayer();
      //       }
      //     : () async {
      //         startPlayer(this.widget.songs[i], i);
      //       },
      onTap: () {},
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
                // played
                //     ? (playerState == PlayerState.playing
                //         ? Loader1()
                //         : Container())
                //     : Container(),
                IconButton(
                  icon: Icon(
                    Icons.more_horiz,
                    color: white.withOpacity(0.5),
                  ),
                  onPressed: () {
                    // myBottomSheet(context, this.widget.songs[i]);
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
