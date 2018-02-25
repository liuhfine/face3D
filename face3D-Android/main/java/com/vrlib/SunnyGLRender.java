package com.vrlib;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.opengl.GLES20;
import android.opengl.GLSurfaceView.Renderer;
import android.opengl.Matrix;
import android.util.Log;
import android.util.TimingLogger;

import com.hl.sunny.panorama_android.MainActivity;
import com.vrlib.Obj3D.Model3D;
import com.vrlib.Obj3D.SYObjLoader;

import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

/**
 * Created by sunny on 2017/9/12.
 */

public class SunnyGLRender implements Renderer {

    private SunnyGLUtils glUnit;
    private Context mContext;

    private int numFaces;
    private FloatBuffer positions = null;
    private FloatBuffer normals = null;
    private FloatBuffer textureCoordinates = null;
    private float[] drawIndex = null;
    private SYObjLoader objLoader;

    private boolean isLoaderObjEnd;

    private static final String TAG = "SunnyGLRender";

    public SunnyGLRender(Context context) {
        mContext = context;

        isLoaderObjEnd = false;
//        reloadOBJData(mContext,"jixiangwu.obj");
    }

    // 当GLSurfaceView 实例生成时回调；
    @Override
    public void onSurfaceCreated(GL10 gl10, EGLConfig eglConfig) {

//        glUnit = new SunnyGLUtils(mContext);
//
////         打开深度检测
//        GLES20.glEnable(GLES20.GL_DEPTH_TEST);
//
////         加载纹理
//        glUnit.loadTextureWithBitmap(mContext, "meimao.jpg");
//        glUnit.loadTextureWithBitmap(mContext, "tou.jpg");
//        glUnit.loadTextureWithBitmap(mContext, "YJ.jpg");
//
//        glUnit.loadVertexForVBO(objLoader);

        loadTextureWithBitmap(mContext, "meimao.jpg");
        loadTextureWithBitmap(mContext, "tou.jpg");
        loadTextureWithBitmap(mContext, "YJ.jpg");

        SYRender.initGL();

    }

    // 当手机横/竖屏切换时回调；
    @Override
    public void onSurfaceChanged(GL10 gl10, int i, int i1) {
//        GLES20.glViewport(0,0,i,i1);
        SYRender.viewPort(i, i1);
    }

    // 一定的帧频率来调用重绘View
    @Override
    public void onDrawFrame(GL10 gl10) {
//        synchronized (this) {

//            GLES20.glClearColor(0.6f, 0.6f, 0.6f, 1.0f);
//            GLES20.glClear( GLES20.GL_COLOR_BUFFER_BIT | GLES20.GL_DEPTH_BUFFER_BIT);
//
//            glUnit.render();

            SYRender.render();
//        }
    }

    private void loadTextureWithBitmap(Context context, String path) {

        InputStream in = null;
        try {

            in = context.getResources().getAssets().open(path);
            BitmapFactory.Options options = new BitmapFactory.Options();
//            options.inScaled=false;
//            options.inPreferredConfig = Bitmap.Config.RGB_565;
            Bitmap bitmap = BitmapFactory.decodeStream(in ,null,options);

            SYRender.bindBitmap(bitmap);

            bitmap.recycle();

        } catch (IOException e) {e.printStackTrace();}
        finally {
            if (in != null)
                try { in.close(); } catch (IOException e) { }
        }

    }

    private void reloadOBJData(Context context, String filePath)
    {
        Log.i(TAG, "onItemClick: loader obj start");

        /******************** load review model ***********************/

        long t0 = System.currentTimeMillis();
        objLoader = new SYObjLoader(context,filePath);

//        objLoader.reloadExpression(context,"xiaoyu.txt",36);
        long t1 = System.currentTimeMillis();

        /******************** load matching model ***********************/

        Log.e(TAG, "reloadOBJData: time" + (t1 - t0) );

        isLoaderObjEnd = true;
    }

    public void reloadTransformInfo(float[] delta, float[] pose)
    {

        glUnit.reloadTransformInfo(pose);

        if (isLoaderObjEnd == true)
            glUnit.updateExpression(objLoader, delta);
    }




}
