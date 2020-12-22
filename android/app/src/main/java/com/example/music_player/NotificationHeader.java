package com.example.music_player;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;

public class NotificationHeader extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        switch (intent.getAction()) {
            case "prev":
                MainActivity.callEvent("prev");
                break;
            case "next":
                MainActivity.callEvent("next");
                break;
            case "toggle":
                String title = intent.getStringExtra("title");
                String author = intent.getStringExtra("author");
                String imagePath=intent.getStringExtra("imagePath");
                boolean play = intent.getBooleanExtra("play",true);

                if(play)
                    MainActivity.callEvent("play");
                else
                    MainActivity.callEvent("pause");

                MainActivity.showNotification(title, author,imagePath,play,context);
                break;
            case "select":
                Intent closeDialog = new Intent(Intent.ACTION_CLOSE_SYSTEM_DIALOGS);
                context.sendBroadcast(closeDialog);
                String packageName = context.getPackageName();
                PackageManager pm = context.getPackageManager();
                Intent launchIntent = pm.getLaunchIntentForPackage(packageName);
                context.startActivity(launchIntent);

                MainActivity.callEvent("select");
        }
    }
}