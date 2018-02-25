package com.hl.sunny.panorama_android;


import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.os.Build;
import android.support.constraint.ConstraintLayout;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.text.Layout;
import android.util.DisplayMetrics;
import android.util.Log;
import android.util.TimingLogger;
import android.view.GestureDetector;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ListView;

import com.vrlib.Obj3D.SYObjLoader;
import com.vrlib.SYRender;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;


public class MainActivity extends AppCompatActivity {

    private ListView listView;
    private static String[] reviewModes = new String[]{
            "VR",
            "obj",
            "VR",
            "VR",
            "VR"
    };

    private static final String TAG = "Timing";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // When the compile and target version is higher than 22, please request the following permissions at runtime to ensure the SDK work well.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            ActivityCompat.requestPermissions(this,
                    new String[]{Manifest.permission.CAMERA,
                            Manifest.permission.READ_EXTERNAL_STORAGE,
                    }
                    , 1);
        }
        setContentView(R.layout.activity_main);

        this.listView = (ListView) findViewById(R.id.list_item);
        this.listView.setAdapter(new ArrayAdapter(this,
                android.R.layout.simple_list_item_1,
                reviewModes));

        this.listView.setOnItemClickListener(
                new AdapterView.OnItemClickListener() {
                    @Override
                    public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
                        switch (i) {
                            case 0: {
                                Intent intent = new Intent(MainActivity.this, SYReviewActivity.class);
                                startActivity(intent);
                            }
                                break;
                            case 1: {
                                Intent intent = new Intent(MainActivity.this, SYReviewActivity.class);
                                startActivity(intent);
                            }
                                break;
                            case 2: {


                            }
                                break;
                            case 3:
                                break;
                            case 4:
                                break;
                            default:
                        }

                    }
                }
        );

    }

    @Override
    protected void onResume() {
        super.onResume();

        SYRender.loadObjAndMorph(this, "xiaoyu"); // , "nomal_face"
    }
}
