package com.vrlib;


import android.content.Context;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.opengl.GLES20;
import android.opengl.GLUtils;
import android.opengl.Matrix;
import android.util.DisplayMetrics;
import android.util.Log;

import android.view.WindowManager;
import android.view.inputmethod.InputBinding;

import com.hl.sunny.panorama_android.MainActivity;
import com.hl.sunny.panorama_android.SYReviewActivity;
import com.vrlib.Obj3D.Model3D;
import com.vrlib.Obj3D.SYObjLoader;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.Buffer;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.nio.IntBuffer;
import java.nio.ShortBuffer;
import java.sql.Date;
import java.util.ArrayList;

import javax.microedition.khronos.egl.EGLContext;


/**
 * Created by sunny on 2017/9/14.
 */


public class SunnyGLUtils {

    public static final int ASTEROID = 0;
    public static final int PANORAMA = 1;
    public static final int NORMAL = 2;

    private float[] VerticesPoint = { -1.0f, -1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 1.0f, 1.0f, };
    private float[] CoordPoint = { 0.0f, 1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, };
    public static final float[] syMatrix = new float[16];

    static {
        Matrix.setIdentityM(syMatrix, 0);
    }

    public static float[] syMatrix() {
        return syMatrix;
    }

    int[] uniformSampler;
    int[] texture;
    private int[] rgbTexture = new int[1];
    private int[] fb = new int[1];
    private int[] rb = new int[1];

    private IntBuffer framebuffer = IntBuffer.allocate(1);;
    private IntBuffer depthRenderbuffer = IntBuffer.allocate(1);;
    private IntBuffer texturebuffer = IntBuffer.allocate(1);;

    private int vPointNum;
    private float[] drawIndex = null;

    private int vertextShaderHandle;
    private int fragmenShaderHandle;
    private int programHandle;
    private int vMatrixsHandle;

    private int aPositionHandle;
    private int aNormalHandle;
    private int aTextureHandle;

    private int rgbTextureHandle;

//    private int vertexBufferHandle;
    private int vboIndexHandle;
    private int vboVertexHandle;
    private int vboNormalHandle;
    private int vboTextureHandle;


    private int uProjectionMatrix;
    private int uModelViewMatrix;
    private int uNormalMatrix;

    private int uAmbient;
    private int uDiffuse;
    private int uSpecular;
    private int uExponent;

    private int   uTexture;
    private int   uMode;

    private int ramdaHandle;
    private int fetaHandle;
    private int scaleHandle;
    private int aspectHandle;
    private int isLineHandle;

    private static final String TAG = "SunnyGLUtils";

    private Date startDate;

    private int face_num;
    private int width;
    private int height;

    private float mPreviousX;
    private float mPreviousY;
    private float mPreviousZ;
    private float scale;
    private float[] tmp = new float[16];
    private float[] mViewMatrix = new float[16];
    private float[] mProjectionMatrix = new float[16];
    private float[] mMVPMatrix = new float[16];

    private float[] changeVertices;
    private boolean isMorphEnd = false;
//    private float viewPortAspect;
//    private int viewPortW;
//    private int viewPortWQ;
//    private int viewPortH;
//    private int viewPortHQ;

    public  SunnyGLUtils(Context context) {

        initConfig();

        final String vertexShader = getVertexShader(context, "polarShow/3D.vert");
        final String fragmentShader = getFragmentShader(context, "polarShow/3D.farg");

        // 加载shader
        vertextShaderHandle = compileShader(GLES20.GL_VERTEX_SHADER, vertexShader);
        fragmenShaderHandle = compileShader(GLES20.GL_FRAGMENT_SHADER, fragmentShader);

        programHandle = createAndLinkProgram(vertextShaderHandle,fragmenShaderHandle,new String[] {"aPosition", "aNormal", "aTexture"});

        if (vertextShaderHandle != 0)
            GLES20.glDeleteShader(vertextShaderHandle);
        if (fragmenShaderHandle != 0)
            GLES20.glDeleteShader(fragmenShaderHandle);

        GLES20.glUseProgram(programHandle);

        aPositionHandle = GLES20.glGetAttribLocation(programHandle, "aPosition");
        aNormalHandle = GLES20.glGetAttribLocation(programHandle, "aNormal");
        aTextureHandle = GLES20.glGetAttribLocation(programHandle, "aTexture");

        /******************** add hl 3DOBJ ********************/
        uProjectionMatrix = GLES20.glGetUniformLocation(programHandle, "vMatrixs");

        uAmbient = GLES20.glGetUniformLocation(programHandle, "uAmbient");
        uDiffuse = GLES20.glGetUniformLocation(programHandle, "uDiffuse");
        uSpecular = GLES20.glGetUniformLocation(programHandle, "uSpecular");
        uExponent = GLES20.glGetUniformLocation(programHandle, "uExponent");
        uTexture = GLES20.glGetUniformLocation(programHandle, "uTexture");
        uMode = GLES20.glGetUniformLocation(programHandle, "uMode");


        float ratio = 1.0f;

        Matrix.setIdentityM(mProjectionMatrix,0);

        Matrix.frustumM(mProjectionMatrix, 0, -ratio, ratio, -1, 1, 1, 100);
        //设置相机位置
        Matrix.setLookAtM(mViewMatrix, 0, 0, 0, 3, 0f, 0f, 0f, 0f, 1.0f, 0.0f);

        // 平移
        Matrix.translateM(mProjectionMatrix,0,0,-0.8f,0f);


        // 缩放
//        float dd = 1.0f;
//        Matrix.scaleM(mProjectionMatrix,0,dd,dd,dd);

        /*********************** add hl VR *****************/

        /* VR
        rgbTextureHandle = GLES20.glGetUniformLocation(programHandle, "rgbTexture");
        ramdaHandle = GLES20.glGetUniformLocation(programHandle, "ramda");
        fetaHandle = GLES20.glGetUniformLocation(programHandle, "feta");
        scaleHandle = GLES20.glGetUniformLocation(programHandle, "scale");
        aspectHandle = GLES20.glGetUniformLocation(programHandle, "aspect");
        isLineHandle = GLES20.glGetUniformLocation(programHandle, "isLine");

        GLES20.glUniform1i(rgbTextureHandle, 0);

        GLES20.glGenTextures(1, rgbTexture, 0);
        if (rgbTexture[0] == 0)
        {
            Log.e(TAG, "<<<<<<<<<<<<纹理创建失败!>>>>>>>>>>>>");
            return;
        }
        GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, rgbTexture[0]);
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_NEAREST);
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
        GLES20.glUniform1i(rgbTextureHandle, 0);

        Buffer bPos = createBuffer(VerticesPoint);
        Buffer bCoord = createBuffer(CoordPoint);

        // 顶点，纹理缓冲区
        // 激活两个属性的数组
        GLES20.glVertexAttribPointer(vPositionHandle,2,GLES20.GL_FLOAT,false,0,bPos);
        GLES20.glEnableVertexAttribArray(vPositionHandle);

        GLES20.glVertexAttribPointer(texCoordInHandle,2,GLES20.GL_FLOAT,false,0,bCoord);
        GLES20.glEnableVertexAttribArray(texCoordInHandle);

        */

    }

    public void updateExpression(SYObjLoader modelData, float[] ceres)
    {
        if (modelData == null)
            return;

//        ceres[5] = 0.5f;ceres[6] = 1.0f;

//        updataObjDelta(modelData, ceres);

        isMorphEnd = false;
    }

    private void updataObjDelta(SYObjLoader modelData, float[] ceres)
    {
        float[][] qwer;
        float[] ver3 = {0,0,0};

        if (changeVertices == null)
            changeVertices = new float[modelData.getVertices().length];

        for (int i=0; i < modelData.getMorphMV().size(); i++) {

            qwer = modelData.getMorphMV().get(i);

            changeVertices[3*i] = modelData.getVertices()[3*i];
            changeVertices[3*i + 1] = modelData.getVertices()[3*i + 1];
            changeVertices[3*i + 2] = modelData.getVertices()[3*i + 2];

            for (int j=0; j<36; j++) {

                ver3[0] += ceres[j] * qwer[j][0];
                ver3[1] += ceres[j] * qwer[j][1];
                ver3[2] += ceres[j] * qwer[j][2];
            }

            changeVertices[3*i] += ver3[0];
            changeVertices[3*i + 1] += ver3[1];
            changeVertices[3*i + 2] += ver3[2];

            ver3[0] = 0;
            ver3[1] = 0;
            ver3[2] = 0;

        }

    }

    public void loadVertexForVBO(SYObjLoader modelData)
    {
        if (modelData == null)
            return;

        vboIndexHandle = sy_bindBuffer(modelData.getIndices());
        vboVertexHandle = sy_bindBuffer(modelData.getVertices());
        vboNormalHandle = sy_bindBuffer(modelData.getNormals());
        vboTextureHandle = sy_bindBuffer(modelData.getTextureCoordinates());

        face_num = modelData.getIndices().length;
    }

    private int sy_bindBuffer(short[] data)
    {
        int[] temp = new int[1];

        ShortBuffer positions = ByteBuffer.allocateDirect(data.length * 2)
                .order(ByteOrder.nativeOrder()).asShortBuffer();
        positions.put(data).position(0);
        GLES20.glGenBuffers(1, temp,0);
        GLES20.glBindBuffer(GLES20.GL_ELEMENT_ARRAY_BUFFER, temp[0]);
        GLES20.glBufferData(GLES20.GL_ELEMENT_ARRAY_BUFFER,
                positions.capacity()*2,
                positions,
                GLES20.GL_STATIC_DRAW);
        GLES20.glBindBuffer(GLES20.GL_ELEMENT_ARRAY_BUFFER, 0);

        return temp[0];
    }

    private int sy_bindBuffer(float[] data)
    {
        int[] temp = new int[1];

        FloatBuffer textures = floatBufferConvertflaot(data);

        GLES20.glGenBuffers(1, temp, 0);
        GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, temp[0]);
        GLES20.glBufferData(GLES20.GL_ARRAY_BUFFER,
                textures.capacity()*4,
                textures,
                GLES20.GL_STATIC_DRAW);
        GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, 0);

        return temp[0];
    }


    int outMTLNumMaterials = 5;

    final int sy_outMTLFirst [] = {
                0,
                576,
                1152,
                63330,
                63906,
    };

    final int sy_outMTLCount [] = {
                576,
                576,
                62178,
                576,
                3996,
    };

    int fdd =0 ;

    static float fff = 0.05f;
    public void reloadTransformInfo(float[] pose)
    {
        this.scale = 1.0f;
        this.mPreviousX = pose[1];//pose[1];
        this.mPreviousY = -pose[0];//-pose[0];
        this.mPreviousZ = 0.0f;


        Log.e(TAG, "reloadTransformInfo: " + pose[0] + " " + fff + " " + pose[2]  );
    }

    private void tramformMatrix() {

//        Matrix.setIdentityM(tmp,0);

//        Matrix.rotateM(tmp, 0, (float) (mPreviousX * 180.0 / Math.PI), 1, 0, 0);
//        Matrix.rotateM(tmp, 0, (float) (mPreviousY * 180.0 / Math.PI), 0, 1, 0);
//        Matrix.rotateM(tmp, 0, (float) (mPreviousZ * 180.0 / Math.PI), 0, 0, 1);

        // 旋转
        Matrix.rotateM(mViewMatrix,0,mPreviousX,1,0,0);
        Matrix.rotateM(mViewMatrix,0,mPreviousY,0,1,0);
//        Matrix.rotateM(mViewMatrix,0,0.0f,0,0,1);

        //计算变换矩阵
        Matrix.multiplyMM(mMVPMatrix,0,mProjectionMatrix,0,mViewMatrix,0);
    }

    // 渲染到屏幕
    public void render() {

        if (isMorphEnd)
        {
            FloatBuffer positions = floatBufferConvertflaot(changeVertices);

            GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, vboVertexHandle);
            GLES20.glBufferSubData(GLES20.GL_ARRAY_BUFFER, 0, positions.capacity()*4, positions);
            GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, 0);

            isMorphEnd = false;
        }

        tramformMatrix();

        GLES20.glUniformMatrix4fv(uProjectionMatrix, 1, false, mMVPMatrix, 0);

        /* VBO 预加载顶点数据，存储至图形卡缓存上 */
        GLES20.glBindBuffer(GLES20.GL_ELEMENT_ARRAY_BUFFER, vboIndexHandle);

        GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, vboNormalHandle);
        GLES20.glVertexAttribPointer(aNormalHandle,
                3,
                GLES20.GL_FLOAT,
                false,
                4 * 3,
                0);
        GLES20.glEnableVertexAttribArray(aNormalHandle);// 开启顶点数据


        GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, vboTextureHandle);
        GLES20.glVertexAttribPointer(aTextureHandle,
                2,
                GLES20.GL_FLOAT,
                false,
                4 * 2,
                0);
        GLES20.glEnableVertexAttribArray(aTextureHandle);

        GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, vboVertexHandle);
        GLES20.glVertexAttribPointer(aPositionHandle,
                3,
                GLES20.GL_FLOAT,
                false,
                4 * 3,
                0);
        GLES20.glEnableVertexAttribArray(aPositionHandle);

//        /*  3D Model
        GLES20.glUniform1i(uMode, 1);

        for (int i=0; i<outMTLNumMaterials; i++)
        {
            if (i < 2)
                GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 1);
            else if (i == 2)
                GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 2);
            else
                GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 3);

            GLES20.glDrawElements(GLES20.GL_TRIANGLES, sy_outMTLCount[i], GLES20.GL_UNSIGNED_SHORT, (2*sy_outMTLFirst[i]));
//            GLES20.glDrawArrays(GLES20.GL_TRIANGLES, (int) outMTLFirst[i], (int) outMTLCount[i]);
        }

        GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, 0);//解除VBO绑定
        GLES20.glBindBuffer(GLES20.GL_ELEMENT_ARRAY_BUFFER, 0);


//        */

        /* VR 双窗口模式

        GLES20.glUniform1f(ramdaHandle, this.mPreviousX);
        GLES20.glUniform1f(fetaHandle, this.mPreviousY);
        GLES20.glUniform1f(scaleHandle, this.scale);

        //屏幕宽高比，用于校正纵横比例
        GLES20.glUniform1f(aspectHandle, viewPortAspect);

        GLES20.glUniform1f(isLineHandle, 1);

        GLES20.glViewport(width/2-2, 100, 4, height - 200);

        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4);

        GLES20.glUniform1f(isLineHandle, 0);
        //采样器 纹理
        GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, bitmap, 0);


        GLES20.glViewport(viewPortWQ, viewPortHQ, viewPortW, viewPortH);
        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4);

        GLES20.glViewport(width/2+viewPortWQ, viewPortHQ, viewPortW, viewPortH);
        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4);
        */

    }

    public void modeIsVR()
    {

    }

    private static int init = 0;
    public void loadTextureWithBitmap(Context context, String path) {

        int[] textureIds = new int[1];
        GLES20.glGenTextures(1, textureIds, 0);
        if (textureIds[0] == 0)
        {
            Log.e(TAG, "<<<<<<<<<<<<纹理创建失败!>>>>>>>>>>>>");
            return;
        }

        Log.e(TAG, "纹理创建>>>>>>>>>>>"  + textureIds[0]);

        InputStream in = null;
        try {

            in = context.getResources().getAssets().open(path);
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inScaled=false;
            Bitmap bitmap= BitmapFactory.decodeStream(in ,null,options);

            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureIds[0]);
            GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, bitmap, 0);

            GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
            GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_NEAREST);
            GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
            GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);

            bitmap.recycle();

        } catch (IOException e) {e.printStackTrace();}
        finally {
            if (in != null)
                try { in.close(); } catch (IOException e) { }
        }

    }

    private void deleteFrameAndRenderBuffer()
    {
        if (framebuffer.get(0) != 0)
            GLES20.glDeleteFramebuffers(1, framebuffer);

        if (depthRenderbuffer.get(0) != 0)
            GLES20.glDeleteRenderbuffers(1, depthRenderbuffer);

        if (texturebuffer.get(0) != 0)
            GLES20.glDeleteTextures(1,texturebuffer);

        framebuffer.clear();
        depthRenderbuffer.clear();
        texturebuffer.clear();
    }

    private void createFrameAndRenderBuffer()
    {
        framebuffer = IntBuffer.allocate(1);
        depthRenderbuffer = IntBuffer.allocate(1);
        texturebuffer = IntBuffer.allocate(1);

        IntBuffer maxRenderbufferSize = IntBuffer.allocate(1);
        GLES20.glGetIntegerv(GLES20.GL_MAX_RENDERBUFFER_SIZE, maxRenderbufferSize);
        // check if GL_MAX_RENDERBUFFER_SIZE is >= texWidth and texHeight

        // generate the framebuffer, renderbuffer, and texture object names
        GLES20.glGenFramebuffers(1, framebuffer);
        GLES20.glGenRenderbuffers(1, depthRenderbuffer);
        GLES20.glGenTextures(1, texturebuffer);

        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, texturebuffer.get(0));
        GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_RGB, width, height,
            0, GLES20.GL_RGB, GLES20.GL_UNSIGNED_SHORT_5_6_5, null);
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR);


        GLES20.glBindRenderbuffer(GLES20.GL_RENDERBUFFER, depthRenderbuffer.get(0));
        GLES20.glRenderbufferStorage(GLES20.GL_RENDERBUFFER, GLES20.GL_DEPTH_COMPONENT16,
                width, height);
        // bind the framebuffer
        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, framebuffer.get(0));
        // specify texture as color attachment
        GLES20.glFramebufferTexture2D(GLES20.GL_FRAMEBUFFER, GLES20.GL_COLOR_ATTACHMENT0,
                    GLES20.GL_TEXTURE_2D, texturebuffer.get(0), 0);
        // specify depth_renderbufer as depth attachment
        GLES20.glFramebufferRenderbuffer(GLES20.GL_FRAMEBUFFER, GLES20.GL_DEPTH_ATTACHMENT,
                    GLES20.GL_RENDERBUFFER, depthRenderbuffer.get(0));
        // check for framebuffer complete
        int status = GLES20.glCheckFramebufferStatus(GLES20.GL_FRAMEBUFFER);
        if(status != GLES20.GL_FRAMEBUFFER_COMPLETE)
        {
            Log.e(TAG, "frame_buffer创建缓冲区错误 "+GLES20.glCheckFramebufferStatus(GLES20.GL_FRAMEBUFFER));
        }

    }

    private FloatBuffer floatBufferConvertflaot(float [] points) {

        // 将顶点数组封装进Buffer中
        // 值得注意的一点是通过Buffer.wrap()方法生成的Buffer无法在OpenGL ES中使用，必须通过如下方法创建Buffer
        ByteBuffer byteBuffer = ByteBuffer.allocateDirect(points.length * 4);
        // OpenGL ES中使用的数据为小端字节序（低位字节在前，高位字节在后），
        // 而Java的Buffer默认使用大端字节序（高位字节在前，低位字节在后）存储数据，所以在此需要通过下面的方法进行转换
        byteBuffer.order(ByteOrder.nativeOrder());
        // 将ByteBuffer转换为FloatBuffer
        FloatBuffer floatBuffer = byteBuffer.asFloatBuffer();
        // 将data中的数据放入FloatBuffer中
        floatBuffer.put(points);
        // 重新定义Buffer的起点和终点，等价于同时使用postion(0)方法和limit(data.length)方法
        floatBuffer.position(0);//flip();

        /* VBO 上传顶点数据
         * 1.temp  用于获取VBO handle的临时变量
         * 2.向OpenGL申请新的VBO，将handle存于temp中     glGenBuffers
         * 3.使用，vbo handle 绑定刚刚申请到的VBO        glBindBuffer
         * 4.将FLoatBuffer中的数据传递给OpenGL ES       glBufferData
         */

        /*
        int[] temp = new int[1];

        GLES20.glGenBuffers(1, temp, 0);

        vertexBufferHandle = temp[0];
        GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, vertexBufferHandle);

        Log.e(TAG, "SunnyGLUtils: " + floatBuffer.limit() );

        GLES20.glBufferData(GLES20.GL_ARRAY_BUFFER, floatBuffer.limit(), floatBuffer, GLES20.GL_STATIC_DRAW);
        */

        return floatBuffer;
    }

    public static int compileShader(final int shaderType, final String shaderSource) {

        if (shaderSource == "") {
            return 0;
        }

        int shaderHandle = GLES20.glCreateShader(shaderType);

        if (shaderHandle != 0) {
            // Pass in the shader source.
            GLES20.glShaderSource(shaderHandle, shaderSource);

            // Compile the shader.
            GLES20.glCompileShader(shaderHandle);

            // Get the compilation status.
            final int[] compileStatus = new int[1];
            GLES20.glGetShaderiv(shaderHandle, GLES20.GL_COMPILE_STATUS, compileStatus, 0);

            // If the compilation failed, delete the shader.
            if (compileStatus[0] == 0) {
                Log.e(TAG, "Error compiling shader: " + GLES20.glGetShaderInfoLog(shaderHandle));
                GLES20.glDeleteShader(shaderHandle);
                shaderHandle = 0;
            }
        }

        if (shaderHandle == 0) {
            throw new RuntimeException("Error creating shader.");
        }

        return shaderHandle;
    }

    public static int createAndLinkProgram(final int vertexShaderHandle, final int fragmentShaderHandle, final String[] attributes) {
        int programHandle = GLES20.glCreateProgram();

        if (programHandle != 0) {
            // Bind the vertex shader to the program.
            GLES20.glAttachShader(programHandle, vertexShaderHandle);

            // Bind the fragment shader to the program.
            GLES20.glAttachShader(programHandle, fragmentShaderHandle);

            // Bind attributes
            if (attributes != null) {
                final int size = attributes.length;
                for (int i = 0; i < size; i++) {
                    GLES20.glBindAttribLocation(programHandle, i, attributes[i]);
                }
            }

            // Link the two shaders together into a program.
            GLES20.glLinkProgram(programHandle);

            // Get the link status.
            final int[] linkStatus = new int[1];
            GLES20.glGetProgramiv(programHandle, GLES20.GL_LINK_STATUS, linkStatus, 0);

            // If the link failed, delete the program.
            if (linkStatus[0] == 0) {
                Log.e(TAG, "Error compiling program: " + GLES20.glGetProgramInfoLog(programHandle));
                GLES20.glDeleteProgram(programHandle);
                programHandle = 0;
            }
        }

        if (programHandle == 0) {
            throw new RuntimeException("Error creating program.");
        }

        return programHandle;
    }

    private String getVertexShader(Context context, String path) {

        return readTextFileFromRaw(context, path);
    }

    private String getFragmentShader(Context context, String path) {
        return readTextFileFromRaw(context, path);
    }

    /**
     * Android 资源文件大致分为两种 res 和 assets
     * res目录 存放可编译的资源文件，读写，可通过R.id 访问资源文件
     * assets目录 存放原生资源文件，只读，系统不会编译asstes目录下的文件，因此不会生成R.id. AssetManager访问
     */
    public static String readTextFileFromRaw(final Context context, final String path) {

        byte tmp[] = null;
        String str = "";

        try {
            InputStream in = context.getResources().getAssets().open(path);
            tmp = new byte[in.available()];
            in.read(tmp);
            str = new String(tmp, "UTF-8");
            in.close();

        } catch (Exception e) {
            e.printStackTrace();
            Log.e(TAG, "readTextFileFromRaw: getAssets shader error");
        }

        return str;
    }

    private ByteBuffer createBuffer(float []f1)
    {
        ByteBuffer tmp = null;
        tmp  = ByteBuffer.allocateDirect(f1.length * 4);
        tmp .order(ByteOrder.nativeOrder());
        tmp .asFloatBuffer().put(f1);
        tmp .position(0);
        return tmp;
    }

    private void initConfig() {

        rgbTexture[0] = -1;
        width = SYReviewActivity.mWindowWidth;
        height = SYReviewActivity.mWindowHeight;

        this.scale = 1;
        this.mPreviousX = 0;
        this.mPreviousY = 0;
        this.mPreviousZ = 0;

//        this.viewPortAspect = SYReviewActivity.mWindowWidth /  SYReviewActivity.mWindowHeight;
//        this.viewPortW = width/2-100;
//        this.viewPortWQ = 50;
//        this.viewPortH = (int) (viewPortW/viewPortAspect);
//        this.viewPortHQ = (height-viewPortH)/2;

    }
}
