package com.hl.sunny.panorama_android;

import android.content.Context;
import android.content.pm.ActivityInfo;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.opengl.EGL14;
import android.opengl.GLES20;
import android.opengl.GLUtils;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.FrameLayout;

import com.vrlib.SYRender;
import com.vrlib.SYSensorHelper;
import com.vrlib.SYTouchHelper;
import com.vrlib.SunnyGLSurfaceView;
import com.camera.CameraGLSurfaceView;


import java.io.IOException;
import java.io.InputStream;

import javax.microedition.khronos.egl.EGL10;
import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.egl.EGLContext;
import javax.microedition.khronos.egl.EGLDisplay;
import javax.microedition.khronos.egl.EGLSurface;


public class SYReviewActivity extends AppCompatActivity implements
        SYSensorHelper.SensorHandlerCallBack,
        SYTouchHelper.SYTouchHelperCallBack
//        Camera.PreviewCallback,
//        CameraThread.OnCameraOpenListener,
//        CameraThread.CameraErrorCallback,
//        RenderThread.OnSurfaceTextureUpdatedListener
{

    /*true:手势触摸 false:传感器模式 */
    public static final boolean movementMode = true;

    private FrameLayout mFrameLayout;
    private SunnyGLSurfaceView glView;
    private CameraGLSurfaceView cameraView;

    private SYSensorHelper sensorHelper;
    private SYTouchHelper touchHelper;

    public static int mWindowWidth;
    public static int mWindowHeight;

    private int modeNum = -1;

    private static final String TAG = "SYReviewActivity";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_syreview);

        initConfig();

        createCamersView();

        createObjView();

    }

    @Override
    protected void onResume() {
        super.onResume();

        glView.onResume();

        if (sensorHelper != null)
            sensorHelper.init();
    }

    @Override
    protected void onPause() {
        super.onPause();
        glView.onPause();
        if (sensorHelper != null)
            sensorHelper.releaseResources();
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        if (touchHelper != null)
            touchHelper.handleTouchEvent(event);
        return true;
    }

    @Override
    public void updataTouchInfo(float scale, float x, float y) {
        if (touchHelper == null)
            return;
//        Log.i(TAG, "onScroll: 滑动速度 X:"+x + " Y:"+ y);
//        glView.reloadTransformInfo(null, null);
    }

    @Override
    public void updataSensorMatrix(float x, float y) {

        if (glView == null)
            return;
//        glView.reloadTransformInfo((float) 0.5,x,y);
    }

    private void initConfig() {

        // 隐藏状态栏
        Window window = getWindow();
        int flag= WindowManager.LayoutParams.FLAG_FULLSCREEN;
        window.setFlags(flag, flag);

        // 隐藏标题栏
        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.hide();
        }

        mWindowHeight = getHeight();
        mWindowWidth = getWidth();

//        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE); // 横屏
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);  // 竖屏


        if (movementMode)
        {
            touchHelper = new SYTouchHelper(this);
            touchHelper.setTouchHleperCallback(this);
        }
        else
        {
            sensorHelper = new SYSensorHelper(this);
            sensorHelper.setSensorHandlerCallback(this);
        }

        // FrameLayout
        ViewGroup.LayoutParams framelayout_params =
                new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                        ViewGroup.LayoutParams.MATCH_PARENT);
        mFrameLayout = new FrameLayout(this);
        mFrameLayout.setLayoutParams(framelayout_params);
        this.addContentView(mFrameLayout, framelayout_params);
    }

    private void createCamersView() {

        cameraView = new CameraGLSurfaceView(this);
        cameraView.setCameraListener(new CameraGLSurfaceView.SYCameraListener() {
            @Override
            public void detectionFace(float[] delta, float[] pose) {

                glView.reloadTransformInfo(delta,pose);

            }
        });

        int sizeX = mWindowWidth - 120*2;
        FrameLayout.LayoutParams cameraFL1 = new FrameLayout.LayoutParams(sizeX, sizeX); // set size
        cameraFL1.setMargins(120, mWindowHeight/4*3 - sizeX/2, 0, 0);  // set position

        cameraView.setLayoutParams(cameraFL1);

        mFrameLayout.addView(cameraView);

    }

    private void createObjView() {

        glView = new SunnyGLSurfaceView(this);
        Button btn = new Button(this);


//        btn.setZOrderOnTop(true);
        FrameLayout.LayoutParams cameraFL = new FrameLayout.LayoutParams(240, 150); // set size
        cameraFL.setMargins(0, 0, 0, 0);  // set position

        int sizeX = mWindowWidth - 120*2; // mWindowHeight/4*3 - sizeX/2

        FrameLayout.LayoutParams cameraFL1 = new FrameLayout.LayoutParams(sizeX, sizeX); // set size
        cameraFL1.setMargins(120, 120, 0, 0);  // set position

        btn.setLayoutParams(cameraFL);
        glView.setLayoutParams(cameraFL1);

        mFrameLayout.addView(glView);
        mFrameLayout.addView(btn);


        btn.setText("普通");
        btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                Button button = (Button) view;

                modeNum = (modeNum == 2 ? -1 : (modeNum+1));
                Log.d(TAG, "onClick: " + modeNum);

                if (modeNum == -1) {
                    button.setText("普通");
                }else if (modeNum == 0) {
                    button.setText("小行星");
                }else if (modeNum == 1) {
                    button.setText("水晶球");
                }else {
                    button.setText("VR");
                }
            }
        });
    }

    public int getHeight() {
        WindowManager manager = this.getWindowManager();
        DisplayMetrics metrics = new DisplayMetrics();
        manager.getDefaultDisplay().getMetrics(metrics);
        int height = metrics.heightPixels;
        return height;
    }

    public int getWidth() {
        WindowManager manager = this.getWindowManager();
        DisplayMetrics metrics = new DisplayMetrics();
        manager.getDefaultDisplay().getMetrics(metrics);
        int width = metrics.widthPixels;
        return width;
    }

}
