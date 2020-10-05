package com.example.music_player;

import java.util.HashMap;

class Song {
    long id;
    String title;
    String artist;
    long artistId;
    String data;
    long duration;
    String album;
    long albumId;
    String displayName;
    long size;
    String albumArt;
    int trackId;

    public Song(long id, String title, String artist, long artistId, String data, long duration, String album, long albumId, String displayName, long size, String albumArt, int trackId) {
        this.id = id;
        this.title = title;
        this.artist = artist;
        this.artistId = artistId;
        this.data = data;
        this.duration = duration;
        this.album = album;
        this.albumId = albumId;
        this.displayName = displayName;
        this.size = size;
        this.albumArt = albumArt;
        this.trackId = trackId;
    }

    public String getAlbumArt() {
        return albumArt;
    }

    public int getTrackId() {
        return trackId;
    }

    public void setTrackId(int trackId) {
        this.trackId = trackId;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getArtist() {
        return artist;
    }

    public void setArtist(String artist) {
        this.artist = artist;
    }

    public long getArtistId() {
        return artistId;
    }

    public void setArtistId(long artistId) {
        this.artistId = artistId;
    }

    public String getData() {
        return data;
    }

    public void setData(String data) {
        this.data = data;
    }

    public long getDuration() {
        return duration;
    }

    public void setDuration(long duration) {
        this.duration = duration;
    }

    public String getAlbum() {
        return album;
    }

    public void setAlbum(String album) {
        this.album = album;
    }

    public long getAlbumId() {
        return albumId;
    }

    public void setAlbumId(long albumId) {
        this.albumId = albumId;
    }

    public String getDisplayName() {
        return displayName;
    }

    public void setDisplayName(String displayName) {
        this.displayName = displayName;
    }

    public long getSize() {
        return size;
    }

    public void setSize(long size) {
        this.size = size;
    }

    public void setAlbumArt(String albumArt) {
        this.albumArt = albumArt;
    }

    HashMap<String, Object> toMap() {
        HashMap<String, Object> songsMap = new HashMap<>();
        songsMap.put("id", id);
        songsMap.put("title", title);
        songsMap.put("artist", artist);
        songsMap.put("artistId", artistId);
        songsMap.put("data", data);
        songsMap.put("duration", duration);
        songsMap.put("album", album);
        songsMap.put("albumId", albumId);
        songsMap.put("displayName", displayName);
        songsMap.put("size", size);
        songsMap.put("albumArt", albumArt);
        songsMap.put("trackId", trackId);
        return songsMap;
    }

}

