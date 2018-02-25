package com.vrlib;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.util.Log;


/**
 * Created by sunny on 2017/10/23.
 */

public class SYSensorHelper implements SensorEventListener {

    // 陀螺仪
    private Context mContext;
    private SensorManager mSensorManager;
    private Sensor mAccelerometer;

    private boolean sensorRegistered;

    private SensorHandlerCallBack callBack;

    private static final String TAG = "SYSensorHelper";

    public SYSensorHelper(Context context ){
        mContext = context;
    }

    public void init(){
        sensorRegistered = false;

        mSensorManager = (SensorManager)mContext.getSystemService(mContext.SENSOR_SERVICE);

        /** 具体传感器
         * TYPE_GAME_ROTATION_VECTOR 旋转矢量传感器
         * TYPE_GYROSCOPE 陀螺仪
         * */
        mAccelerometer = mSensorManager.getDefaultSensor(Sensor.TYPE_GAME_ROTATION_VECTOR);

        // 传感器注册监听
        mSensorManager.registerListener(this, mAccelerometer, SensorManager.SENSOR_DELAY_GAME);

        sensorRegistered = true;
    }

    public void releaseResources(){
        if (!sensorRegistered || mSensorManager==null) return;
        // 解除监听
        mSensorManager.unregisterListener(this);
        sensorRegistered = false;
    }

    // 传感器值改变
    @Override
    public void onSensorChanged(SensorEvent sensorEvent) {

        if (sensorEvent.accuracy != 0) {
            int type = sensorEvent.sensor.getType();
            switch (type){
                case Sensor.TYPE_GAME_ROTATION_VECTOR:
//                    Log.i(TAG, "\nX: " + sensorEvent.values[0] + "\nY: " + sensorEvent.values[1] );
                    this.callBack.updataSensorMatrix(sensorEvent.values[1],sensorEvent.values[0]);
//                    SensorUtils.sensorRotationVectorToMatrix(event,rotationMatrix);
//                    sensorHandlerCallback.updateSensorMatrix(rotationMatrix);
                    break;
            }
        }
    }

    // 精度改变
    @Override
    public void onAccuracyChanged(Sensor sensor, int i) {

    }

    public void setSensorHandlerCallback(SensorHandlerCallBack sensorHandlerCallback){
        this.callBack=sensorHandlerCallback;
    }

    // 类似delegate
    public interface SensorHandlerCallBack {
        void updataSensorMatrix(float x,float y);
    }

}
