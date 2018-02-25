package com.vrlib;

import android.content.Context;
import android.content.res.AssetManager;
import android.graphics.Bitmap;

/**
 * Created by sunny on 2018/2/1.
 */

public class SYRender {

    static {
        System.loadLibrary("SYRender");
    }

    public static native int loadObjAndMorph(Context context, String objFile); // , String objFile1

    public static native int initGL();

    public static native void bindBitmap(Bitmap bitmap);

    public static native void render();

    public static native void viewPort(int w, int h);

    public static native void updataModelVerWithFacePoints(float[] points,float[] pose);
}
