package com.example.music_player;

import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.MediaMetadataRetriever;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.provider.MediaStore;
import android.util.Log;

import androidx.annotation.NonNull;

import java.io.FileOutputStream;
import java.io.File;
import java.util.HashMap;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private static String channelName = "com.example.mc/tester";
    private static String channelName2 = "notification";
    private HashMap<Long, String> albumMap = new HashMap<>();
    private HashMap<String, HashMap<String, Object>> songs = new HashMap<>();
    static MediaPlayer mediaPlayer;
    Handler handler = new Handler();
    static private MethodChannel channel;
    static private MethodChannel notificationChannel;

    static void showNotification(String title, String author,String imagePath,boolean play, Context context ) {

        Intent serviceIntent = new Intent(context, NotificationMaker.class);
        serviceIntent.putExtra("title", title);
        serviceIntent.putExtra("author", author);
        serviceIntent.putExtra("isPlaying", play);
        serviceIntent.putExtra("imagePath",imagePath);
        Log.w("log2",")))))))))))"+imagePath);
        context.startService(serviceIntent);
    }

    static private void hideNotification(Context context) {
        Intent serviceIntent = new Intent(context, NotificationMaker.class);
        context.stopService(serviceIntent);
    }

    static void callEvent(String event) {

        MainActivity.notificationChannel.invokeMethod(event, null, new MethodChannel.Result() {
            @Override
            public void success(Object o) {
                // this will be called with o = "some string"
            }

            @Override
            public void error(String s, String s1, Object o) {
            }

            @Override
            public void notImplemented() {
            }
        });
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        channel = new MethodChannel(flutterEngine.getDartExecutor(), channelName);
        notificationChannel = new MethodChannel(flutterEngine.getDartExecutor(), channelName2);
        Context context=getApplicationContext();
        notificationChannel.setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
                        if (call.method.equals("showNotification")) {
                            String title = call.argument("title");
                            String artist = call.argument("artist");
                            String imagePath=call.argument("imagePath");
                            Log.w("log1","((((((((((((((((((((((((((((((("+imagePath);
                            boolean isPlaying = call.argument("isPlaying");
                            showNotification(title, artist,imagePath, isPlaying,context);
                            result.success(null);
                        } else if (call.method.equals("hideNotification")) {
                            hideNotification(context);
                            result.success(null);
                        } else {
                            result.notImplemented();
                        }
                    }
                }
        );
        channel.setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
                        if (call.method.equals("getMusic")) {
//                            loadAlbums();
                            MethodChannel.Result rs = new MethodResultWrapper(result);
                            new AsyncTask<Void, Void, Void>() {
                                @Override
                                protected Void doInBackground(Void... params) {
                                    getAllSongs();
                                    rs.success(songs);
                                    return null;
                                }

                                @Override
                                protected void onPostExecute(Void result) {
                                    super.onPostExecute(result);
                                }
                            }.execute();
//                            getAllSongs();
//                            channel.invokeMethod("onScanComplete", false);
//                            result.success(songs);
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

    private static class MethodResultWrapper implements MethodChannel.Result {
        private MethodChannel.Result methodResult;
        private Handler handler;

        MethodResultWrapper(MethodChannel.Result result) {
            methodResult = result;
            handler = new Handler(Looper.getMainLooper());
        }

        @Override
        public void success(final Object result) {
            handler.post(new Runnable() {
                @Override
                public void run() {
                    methodResult.success(result);
                }
            });
        }

        @Override
        public void error(final String errorCode, final String errorMessage, final Object errorDetails) {
            handler.post(new Runnable() {
                @Override
                public void run() {
                    methodResult.error(errorCode, errorMessage, errorDetails);
                }
            });
        }

        @Override
        public void notImplemented() {
            handler.post(new Runnable() {
                @Override
                public void run() {
                    methodResult.notImplemented();
                }
            });
        }
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
                Log.w("completed", "song completed");
                channel.invokeMethod("audio.onComplete", true);
            }
        });
        mediaPlayer.setOnErrorListener(
                new MediaPlayer.OnErrorListener() {
                    @Override
                    public boolean onError(MediaPlayer mediaPlayer, int what, int extra) {
                        Log.w("asfsfkbakjfbkjjjkfkj", "error encountered");
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
        String path =  Environment.getExternalStorageDirectory().getAbsolutePath();
        Log.w("asfasf","path is "+path);
        path+="/android/data/com.example.music_player/files";
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
                    File file = new File(path + "/" + id + ".jpg");
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
                        albumArt = path + "/" + id + ".jpg";
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
        File file = new File(paths + "/", id + ".jpg");
        Log.w("apsfkpas","______________________________>"+file.getAbsolutePath());// the File to save , append increasing numeric counter to prevent files from getting overwritten.
        try {
            FileOutputStream out = new FileOutputStream(file);
            bitmap.compress(Bitmap.CompressFormat.JPEG, 50, out);
            out.flush();
            out.close();
//            MediaStore.Images.Media.insertImage(context.getContentResolver(), file.getAbsolutePath(), file.getName(), file.getName());
        } catch (Exception e) {
            e.printStackTrace();
        }
        //   ByteArrayOutputStream bytes = new ByteArrayOutputStream();
        // inImage.compress(Bitmap.CompressFormat.JPEG, 100, bytes);
        // Log.w("some err","path is "+path);
        String newPath = paths + "/" + id + ".jpg";
        Log.w("asf", newPath);
        return newPath;
    }

}
