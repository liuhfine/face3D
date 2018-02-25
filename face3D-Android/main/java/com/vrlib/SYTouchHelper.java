package com.vrlib;

import android.content.Context;
import android.util.Log;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;


/**
 * Created by sunny on 2017/9/18.
 */


class Gesture extends  GestureDetector.SimpleOnGestureListener {

    private static final String TAG = "Gesture";

    @Override
    public boolean onSingleTapUp(MotionEvent e) {

        Log.i(TAG, "onSingleTapUp: X: " + e.getX() + "Y:" + e.getY());
//        reloadTransformInfo();
        return true;
    }

    @Override
    public boolean onDoubleTap(MotionEvent e) {
        Log.i(TAG, "onDoubleTap: X: " + e.getX() + "Y:" + e.getY());
        return true;
    }

    @Override
    public void onLongPress(MotionEvent e) {
        Log.i(TAG, "onLongPress: X: " + e.getX() + "Y:" + e.getY());
    }

    @Override
    public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) {
        Log.i(TAG, "onScroll: X: " + distanceX + "Y:" + distanceY);
        return true;
    }

    @Override
    public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY) {
        Log.i(TAG, "onFling: X: " + velocityX + "Y:" + velocityY);
        return true;
    }
}

public class SYTouchHelper {

    private Context mContext;

    private GestureDetector gestureDetector;
    private ScaleGestureDetector scaleGestureDetector;

    private SYTouchHelperCallBack callBack;

    private float overture;
    private boolean isScale;
    private float  fingerRotationX;
    private float  fingerRotationY;

//    public static final float MAX_OVERTURE = 95;
//    public static final float MIN_OVERTURE = 15;
//    public static final float DEFAULT_OVERTURE = 65;

    public static final float MAX_VELOCITY = (float) 3.00;
    public static final float MIN_VELOCITY  = (float) 0.55;

    private static final String TAG = "hl-log";

    public SYTouchHelper(Context context) {
        this.mContext = context;

        this.overture = 1;
        fingerRotationX=0;
        fingerRotationY=0;

        init();
    }

    private void init(){

        gestureDetector=new GestureDetector(mContext, new GestureDetector.SimpleOnGestureListener(){

            @Override   //点击屏幕
            public boolean onSingleTapConfirmed(MotionEvent e) {

                return super.onSingleTapConfirmed(e);
            }

            @Override  //单指滚动   单位像素/秒
            public boolean onScroll(MotionEvent old, MotionEvent now, float distanceX, float distanceY) {
                //old是第一个按下的点， now是第一个按下的点的移动
                //向下滑动  Y是-  向上滑动y是正
                //向右滑动  X是-

                if (isScale)
                    return true;

                float minMove = 20;         //最大滑动速度
                float minVelocity = 0;      //最小滑动速度

                float distX = distanceX;
                float distY = distanceY;
                distX *= -0.005;
                distY *= -0.005;

                fingerRotationX += distX * overture /10;
                fingerRotationY += distY * overture /10;

                if (fingerRotationX > MAX_VELOCITY)
                    fingerRotationX = MAX_VELOCITY;
                if (fingerRotationX > MIN_VELOCITY)
                    fingerRotationX = MIN_VELOCITY;

//                mRender.reloadTransformInfo(overture,fingerRotationY,fingerRotationX);

                callBack.updataTouchInfo(overture,fingerRotationY,fingerRotationX);
//                Log.i(TAG, "onScroll: 滑动速度 X:"+distanceX + " Y:"+ distanceY);

                return super.onScroll(old, now, distanceX, distanceY);
            }
        });

        scaleGestureDetector=new ScaleGestureDetector(mContext, new ScaleGestureDetector.OnScaleGestureListener() {
            @Override  //双指缩放
            public boolean onScale(ScaleGestureDetector detector) {
                float scaleFactor=detector.getScaleFactor();
                //   scaleFactor   双指靠拢  值 < 1   双指分开   值 > 1

                //控制缩放速度
                float tmp = 1.0f - scaleFactor;
                overture += tmp;

                if (overture > 1.5)
                    overture = (float) 1.5;

                if (overture < 0.5)
                    overture = (float) 0.5;

//                mRender.reloadTransformInfo(overture,fingerRotationY,fingerRotationX);

                callBack.updataTouchInfo(overture,fingerRotationY,fingerRotationX);

//                System.out.println("lh-log - 缩放因子:"+overture);

                return true;
            }

            @Override
            public boolean onScaleBegin(ScaleGestureDetector detector) {
                isScale = true;
                return true;
            }

            @Override
            public void onScaleEnd(ScaleGestureDetector detector) {
                isScale = false;
            }
        });
    }

    public boolean handleTouchEvent(MotionEvent event) {
        //int action = event.getActionMasked();
        //也可以通过event.getPointerCount()来判断是双指缩放还是单指触控
        boolean ret=scaleGestureDetector.onTouchEvent(event);
        if (!scaleGestureDetector.isInProgress()){
            ret=gestureDetector.onTouchEvent(event);
        }
        return  ret;
    }

    public void setTouchHleperCallback(SYTouchHelperCallBack callBack) {
        this.callBack = callBack;
    }

    public interface SYTouchHelperCallBack {

        /* 滑动，缩放数据回调
        * 缩放 scale
        * 横坐标 x
        * 从坐标 y
        */
        void updataTouchInfo(float scale, float x, float y);
    }

}
