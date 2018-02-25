package com.camera;

import android.app.Activity;
import android.content.Context;
import android.graphics.ImageFormat;
import android.graphics.SurfaceTexture;
import android.hardware.Camera;
import android.opengl.GLES11Ext;
import android.opengl.GLES20;
import android.opengl.GLSurfaceView;
import android.opengl.GLSurfaceView.Renderer;
import android.os.AsyncTask;
import android.os.Looper;
import android.util.AttributeSet;
import android.util.Log;
import android.view.SurfaceHolder;
import android.widget.Toast;

import java.io.IOException;
import java.lang.reflect.Parameter;
import java.security.Policy;
import java.util.logging.Handler;
import java.util.logging.LogRecord;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

import com.hl.sunny.panorama_android.MainActivity;


public class CameraGLSurfaceView extends GLSurfaceView implements Renderer, SurfaceTexture.OnFrameAvailableListener {

	Context mContext;
	SurfaceTexture mSurface;
	int mTextureID = -1;
	private Camera camera;
	DirectDrawer mDirectDrawer;
	
	private static final int mMaxTrackers = 1;
	
	// Modified.
    private boolean isTracker = false;

	private SYCameraListener mListener;

	private static final String TAG = "CmaeraView";

	public CameraGLSurfaceView(Context context) {
		super(context);
		// TODO Auto-generated constructor stub
		mContext = context;
		setEGLContextClientVersion(2);
		setRenderer(this);
		setRenderMode(RENDERMODE_WHEN_DIRTY);

	}

	public void setCameraListener(SYCameraListener listener)
	{
		this.mListener = listener;
	}

	@Override
	public void onSurfaceCreated(GL10 gl, EGLConfig config) {
		// TODO Auto-generated method stub
		Log.i(TAG, "onSurfaceCreated...");
		mTextureID = createTextureID();
		mSurface = new SurfaceTexture(mTextureID);
		mSurface.setOnFrameAvailableListener(this);
		mDirectDrawer = new DirectDrawer(mTextureID);
//		CameraInterface.getInstance().doOpenCamera(null);
		camera = Camera.open(1);

	}
	@Override
	public void onSurfaceChanged(GL10 gl, int width, int height) {
		// TODO Auto-generated method stub
		GLES20.glViewport(0, 0, width, height);
//		if(!CameraInterface.getInstance().isPreviewing()){
//			CameraInterface.getInstance().doStartPreview(mSurface, 1.33f);
//		}
		try {

			Camera.Parameters parameters = camera.getParameters();
			parameters.setPreviewSize(width, height);
			parameters.setPreviewFormat(ImageFormat.NV21);
//
			camera.setPreviewTexture(mSurface);
//			camera.setDisplayOrientation(180);
			camera.setParameters(parameters);

			camera.setPreviewCallback(myCallback);
		} catch( IOException e ) {
			e.printStackTrace();
		}
		// ...and start previewing. From now on, the camera keeps pushing preview
		// images to the surface.

		camera.startPreview();

	}

	private long mTimingCounter = 0;
	Camera.PreviewCallback myCallback = new Camera.PreviewCallback() {
		@Override
		public void onPreviewFrame(final byte[] data, Camera camera) {
			//得到相应的图片数据
			//Do something
    
			if (isTracker == true)
			{
				if (shape != null)
					mListener.detectionFace(shape, pose);
			}

		}
	};


	@Override
	public void onDrawFrame(GL10 gl) {
		// TODO Auto-generated method stub
//		Log.i(TAG, "onDrawFrame...");
		GLES20.glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
		GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT | GLES20.GL_DEPTH_BUFFER_BIT);
		mSurface.updateTexImage();

		mDirectDrawer.draw(null);
	}
	
	@Override
	public void onPause() {
		// TODO Auto-generated method stub
		super.onPause();
//		CameraInterface.getInstance().doStopCamera();
	}
	private int createTextureID()
	{
		int[] texture = new int[1];

		GLES20.glGenTextures(1, texture, 0);
		GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, texture[0]);
		GLES20.glTexParameterf(GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
				GL10.GL_TEXTURE_MIN_FILTER, GL10.GL_LINEAR);
		GLES20.glTexParameterf(GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
				GL10.GL_TEXTURE_MAG_FILTER, GL10.GL_LINEAR);
		GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
				GL10.GL_TEXTURE_WRAP_S, GL10.GL_CLAMP_TO_EDGE);
		GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
				GL10.GL_TEXTURE_WRAP_T, GL10.GL_CLAMP_TO_EDGE);

		return texture[0];
	}
	public SurfaceTexture _getSurfaceTexture(){
		return mSurface;
	}
	@Override
	public void onFrameAvailable(SurfaceTexture surfaceTexture) {
		// TODO Auto-generated method stub
//		Log.i(TAG, "onFrameAvailable...");
		this.requestRender();
	}

	@Override
	public void surfaceDestroyed(SurfaceHolder holder) {
		super.surfaceDestroyed(holder);

		camera.setPreviewCallback(null);
		try {
			camera.setPreviewTexture(null);
		} catch (IOException e) {
			e.printStackTrace();
		}
		camera.stopPreview();
		camera.release();
		camera = null;
	}

	public interface SYCameraListener
	{
		/* 返回特征点 和 姿态值 */
		void detectionFace(float[] delta, float[] pose);
	}

}
