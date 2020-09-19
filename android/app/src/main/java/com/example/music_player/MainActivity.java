package com.example.music_player;

import android.app.Activity;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.Context;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.AudioAttributes;
import android.media.MediaMetadataRetriever;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Environment;
import android.os.Handler;
import android.provider.BaseColumns;
import android.provider.MediaStore;
import android.util.Log;

import androidx.annotation.NonNull;

import java.io.FileOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.UnsupportedEncodingException;
import java.util.HashMap;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private static String channelName = "com.example.mc/tester";
    private HashMap<Long, String> albumMap = new HashMap<>();
    private HashMap<String, HashMap<String, Object>> songs = new HashMap<>();
    MediaPlayer mediaPlayer;
    Handler handler = new Handler();
    private MethodChannel channel;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        channel = new MethodChannel(flutterEngine.getDartExecutor(), channelName);
        channel.setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
                        if (call.method.equals("getMusic")) {
//                            loadAlbums();
                            getAllSongs();
                            result.success(songs);
                        } else if (call.method.equals("playMusic")) {
                            String url = call.argument("path");
//                            long id = Long.parseLong(url);
                            Boolean playSuccess = playMusic(url);
                            result.success(1);
                        } else if (call.method.equals("pauseMusic")) {
                            pause();
                            result.success(1);
                        } else if (call.method.equals("resumeMusic")) {
                            resume();
                            result.success(1);
                        } else if (call.method.equals("stopMusic")) {
                            stop();
                            result.success(1);
                        } else if (call.method.equals("seekMusic")) {
                            double position = call.argument("position");
                            seek(position);
                            result.success(1);
                        } else {
                            result.notImplemented();
                        }
                    }
                }

        );
    }

    private void seek(double position) {
        mediaPlayer.seekTo((int) (position * 1000));
    }

    private void pause() {
        mediaPlayer.pause();
        handler.removeCallbacks(sendData);
    }

    private void resume() {
        mediaPlayer.start();
        mediaPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mediaPlayer) {
                channel.invokeMethod("audio.onDuration", mediaPlayer.getDuration());
                mediaPlayer.start();
                channel.invokeMethod("audio.onStart", true);
            }
        });
        mediaPlayer.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
            @Override
            public void onCompletion(MediaPlayer mediaPlayer) {
                stop();
                channel.invokeMethod("audio.onComplete", true);
            }
        });
        mediaPlayer.setOnErrorListener(
                new MediaPlayer.OnErrorListener() {
                    @Override
                    public boolean onError(MediaPlayer mediaPlayer, int what, int extra) {
                        channel.invokeMethod("audio.onError", String.format("{\"what\":%d,\"extra\":%d}", what, extra));
                        return false;
                    }
                }
        );
        handler.post(sendData);
    }

    private void stop() {
        handler.removeCallbacks(sendData);
        if (mediaPlayer != null) {
            mediaPlayer.stop();
            mediaPlayer.release();
            mediaPlayer = null;
        }
    }

    private Boolean playMusic(String url) {

        if (mediaPlayer != null) {
            handler.removeCallbacks(sendData);
            mediaPlayer.stop();
            mediaPlayer.release();
        }
        try {
            mediaPlayer = new MediaPlayer();
            mediaPlayer.setDataSource(url);
            mediaPlayer.prepareAsync();
        } catch (Exception e) {
            e.printStackTrace();
            Log.w("errorror", "some eror" + e.toString());
        }
        mediaPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mediaPlayer) {
                channel.invokeMethod("audio.onDuration", mediaPlayer.getDuration());
                mediaPlayer.start();
                channel.invokeMethod("audio.onStart", true);
            }
        });
        mediaPlayer.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
            @Override
            public void onCompletion(MediaPlayer mediaPlayer) {
//                stop();
                Log.w("completed","song completed");  
                channel.invokeMethod("audio.onComplete", true);
            }
        });
        mediaPlayer.setOnErrorListener(
                new MediaPlayer.OnErrorListener() {
                    @Override
                    public boolean onError(MediaPlayer mediaPlayer, int what, int extra) {
                        Log.w("asfsfkbakjfbkjjjkfkj","error encountered");
                        channel.invokeMethod("audio.onError", String.format("{\"what\":%d,\"extra\":%d}", what, extra));
                        return false;
                    }
                }
        );
        handler.post(sendData);
        return true;
    }

    private final Runnable sendData = new Runnable() {
        @Override
        public void run() {
            try {
                if (!mediaPlayer.isPlaying()) {
                    handler.removeCallbacks(sendData);
                }
                int time = mediaPlayer.getCurrentPosition();
                channel.invokeMethod("audio.onCurrentPosition", time);
                handler.postDelayed(this, 200);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    };

    private void getAllSongs() {
        ContentResolver contentResolver = getContentResolver();
        Uri uri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
        File dir = Environment.getExternalStorageDirectory();
        String path = dir.getAbsolutePath();
        Cursor cursor = contentResolver.query(uri, null, MediaStore.Audio.Media.IS_MUSIC + " = 1", null, null);
        if (cursor == null) {
            Log.w("error1", "quert failed");
        } else if (!cursor.moveToFirst()) {
            return;
        } else {
            int titleIndex = cursor.getColumnIndex(MediaStore.Audio.Media.TITLE);
            int trackIndex = cursor.getColumnIndex(MediaStore.Audio.Media.TRACK);
            int idIndex = cursor.getColumnIndex(MediaStore.Audio.Media._ID);
            int dataIndex = cursor.getColumnIndex(MediaStore.Audio.Media.DATA);
            int artistIndex = cursor.getColumnIndex(MediaStore.Audio.Media.ARTIST);
            int artistIdIndex = cursor.getColumnIndex(MediaStore.Audio.Media.ARTIST_ID);
            int durationIndex = cursor.getColumnIndex(MediaStore.Audio.Media.DURATION);
            int albumIndex = cursor.getColumnIndex(MediaStore.Audio.Media.ALBUM);
            int albumIdIndex = cursor.getColumnIndex(MediaStore.Audio.Media.ALBUM_ID);
            int displayNameIndex = cursor.getColumnIndex(MediaStore.Audio.Media.DISPLAY_NAME);
            int sizeIndex = cursor.getColumnIndex(MediaStore.Audio.Media.SIZE);
            int length = cursor.getCount();
            do {
                int trackId = 0;
                long id = cursor.getLong(idIndex);
                String title = cursor.getString(titleIndex);
                String artist = cursor.getString(artistIndex);
                long artistId = cursor.getLong(artistIdIndex);
                String data = cursor.getString(dataIndex);
                long duration = cursor.getLong(durationIndex);
                String album = cursor.getString(albumIndex);
                String displayName = cursor.getString(displayNameIndex);
                long size = cursor.getLong(sizeIndex);
                long albumId = cursor.getLong(albumIdIndex);

//                    Log.w("patyh","path is "+path);
                if (data.endsWith(".mp3")) {
                    File file = new File(path + "/Pictures/" + id + ".jpg");
                    String albumArt = "";
                    if (!file.exists()) {
                        Log.w("soneoas", "data is " + data + " ");
                        MediaMetadataRetriever mmr = new MediaMetadataRetriever();
                        try {
                            mmr.setDataSource(data);
                            byte[] imageData = mmr.getEmbeddedPicture();
                            if (imageData != null) {
                                Bitmap songImage = BitmapFactory
                                        .decodeByteArray(imageData, 0, imageData.length);
                                String albumUri = getImageUri(getApplicationContext(), songImage, displayName, id, path);
                                albumArt = albumUri;
                            }
                        } catch (Exception e) {
                            Log.w("errror ", e.toString() + " iis erro " + data);
                        }
                    } else {
                        albumArt = path + "/Pictures/" + id + ".jpg";
                    }
                    Log.w("finalk", "new op " + albumArt);
//                    String albumArt = albumMap.get(albumId) == null ? "" : albumMap.get(albumId);
                    Song song = new Song(
                            id, title, artist, artistId, data, duration, album, albumId, displayName, size, albumArt, trackId
                    );
                    songs.put(String.valueOf(song.id), song.toMap());

                }
            } while (cursor.moveToNext());


        }
        cursor.close();
    }

    private String getImageUri(Context context, Bitmap bitmap, String displayName, long id, String paths) {
        File file = new File(paths + "/Pictures/", id + ".jpg"); // the File to save , append increasing numeric counter to prevent files from getting overwritten.
        try {
            FileOutputStream out = new FileOutputStream(file);
            bitmap.compress(Bitmap.CompressFormat.JPEG, 85, out);
            out.flush();
            out.close();
            MediaStore.Images.Media.insertImage(context.getContentResolver(), file.getAbsolutePath(), file.getName(), file.getName());
        } catch (Exception e) {
            e.printStackTrace();
        }
        //   ByteArrayOutputStream bytes = new ByteArrayOutputStream();
        // inImage.compress(Bitmap.CompressFormat.JPEG, 100, bytes);
        // Log.w("some err","path is "+path);
        String newPath = paths + "/Pictures/" + id + ".jpg";
        Log.w("asf", newPath);
        return newPath;
    }

    private void loadAlbums() {
        ContentResolver contentResolver = getContentResolver();

        Uri uri2 = MediaStore.Audio.Albums.EXTERNAL_CONTENT_URI;
        Uri uri1 = MediaStore.Audio.Albums.INTERNAL_CONTENT_URI;
        String[] projections1 = {MediaStore.Audio.Albums._ID, MediaStore.Audio.Albums.ALBUM_ART};
        String[] projections2 = {MediaStore.Audio.Albums._ID, MediaStore.Audio.Albums.ALBUM_ART};
        Cursor cursor1 = contentResolver.query(uri1, projections1, null, null, null);
        Cursor cursor2 = contentResolver.query(uri2, projections2, null, null, null);
        int length = cursor1.getCount();
        int idIndex = cursor1.getColumnIndex(BaseColumns._ID);
        int albumIndex = cursor1.getColumnIndex(MediaStore.Audio.Albums.ALBUM_ART);
        Log.w("tagger", "sabfkjafsaksnfkkfkfafmfA" + idIndex + " " + albumIndex);
        for (int i = 0; i < length; i++) {
            if (cursor1.moveToNext()) {
                long id = cursor1.getLong(idIndex);
                String albumPath = cursor1.getString(albumIndex) == null ? "" : cursor1.getString(albumIndex);
                Log.w("asgag", albumPath);
                albumMap.put(id, albumPath);
            } else {
                break;
            }
        }
        cursor1.close();

        length = cursor2.getCount();
        idIndex = cursor2.getColumnIndex(BaseColumns._ID);
        albumIndex = cursor2.getColumnIndex(MediaStore.Audio.Albums.ALBUM_ART);
        Log.w("tagger", "sabfkjafsaksnfkkfkfafmfA" + idIndex + " " + albumIndex);
        for (int i = 0; i < length; i++) {
            if (cursor2.moveToNext()) {
                long id = cursor2.getLong(idIndex);
                String albumPath = cursor2.getString(albumIndex) == null ? "" : cursor2.getString(albumIndex);
                Log.w("asgag", albumPath);
                albumMap.put(id, albumPath);
            } else {
                break;
            }
        }
    }

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


}
//
//
//    private void loadAudioPaths() {
//        ContentResolver contentResolver = getContentResolver();
//        Uri uri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
//        String[] projections = {MediaStore.Audio.Media._ID, MediaStore.Audio.Media.DATA};
//        Cursor cursor = contentResolver.query(uri, projections, null, null, null);
//        int length = cursor.getCount();
//        int idIndex = cursor.getColumnIndex(MediaStore.Audio.Media._ID);
//        int pathIndex = cursor.getColumnIndex(MediaStore.Audio.Media.DATA);
//        for (int i = 0; i < length; i++) {
//            if (cursor.moveToNext()) {
//                long id = cursor.getLong(idIndex);
//                String songPath = cursor.getString(pathIndex);
//                audioPaths.put(id, songPath);
//            } else {
//                break;
//            }
//        }
//        cursor.close();
//    }
