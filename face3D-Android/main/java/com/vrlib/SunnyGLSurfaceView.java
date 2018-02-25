package com.vrlib;

import com.vrlib.SYTouchHelper;
import android.content.Context;
import android.opengl.GLSurfaceView;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;


/**
 * Created by sunny on 2017/9/18.
 */

public class SunnyGLSurfaceView extends GLSurfaceView {

    private SunnyGLRender mRender;


    public SunnyGLSurfaceView(Context context) {
        super(context);

        setEGLContextClientVersion(2);

        // Set the Renderer for drawing on the GLSurfaceView
        mRender = new SunnyGLRender(context);

        setEGLConfigChooser(8,8,8,8,16,0);

        setRenderer(mRender);

//        setRenderMode(GLSurfaceView.RENDERMODE_CONTINUOUSLY);//持续渲染
        setRenderMode(GLSurfaceView.RENDERMODE_WHEN_DIRTY);//请求一次渲染一次

    }

    @Override
    protected void onScrollChanged(int l, int t, int oldl, int oldt) {
        super.onScrollChanged(l, t, oldl, oldt);
    }

    public void reloadTransformInfo(float[] delta, float[] pose) //
    {
        SYRender.updataModelVerWithFacePoints(delta, pose);

        requestRender();
    }

//    private class MyHandler extends Handler{
//        public MyHandler(Looper looper){
//            super(looper);
//        }
//        @Override
//        public void handleMessage(Message msg) {//处理消息
//
//            if (msg.what == 1){
//
//                requestRender();
//            }
//
//
//        }
//    }
}
