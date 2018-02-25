#include <jni.h>
#include <stdio.h>
#include <stdlib.h>
#include <android/asset_manager.h>
#include <android/asset_manager_jni.h>
#include <android/bitmap.h>

#include "SYLoadObj.h"
#include "SYCeres.h"
#include "SYNRender.h"
#include <string.h>



static JavaVM* sVM= NULL;
static jclass sClazz = NULL;

SYNRender   *mRender;
SYLoadObj   *mLoadObj;
SYLoadObj   *mLoadObj1;
SYCeres     *mCeres;

JNIEXPORT jint JNICALL loadObjAndMorph(JNIEnv *env, jclass,jobject context, jstring objFile)
{

    if (mLoadObj != NULL && mLoadObj1 != NULL)
        return -1;
    if (mLoadObj == NULL)
        mLoadObj = new SYLoadObj();

    mLoadObj->reload_objfile(env, objFile, context);

    if (mLoadObj1 == NULL)
        mLoadObj1 = new SYLoadObj;

    jstring modelFile2 = env->NewStringUTF("nomal_face");

    mLoadObj1->reload_objfile(env, modelFile2, context);

    return 0;
}

JNIEXPORT jint JNICALL initGL(JNIEnv *env, jclass)
{
    if (mRender == NULL)
        mRender = new SYNRender();

    mRender->initGL();
    LOGE("------------> initGL");

    mRender->loadVertexForVBO(mLoadObj->getObjModelData());

    return 0;
}

JNIEXPORT void JNICALL bindBitmap(JNIEnv *env, jclass, jobject bitmap)
{
    AndroidBitmapInfo info = {0};
    void *data=NULL;//初始化Bitmap图像数据指针

    if (AndroidBitmap_getInfo(env, bitmap, &info) < 0)  // 从位图句柄获得图像信息
    {
        return;
    }

    LOGE("---------> ANDROIBITMAP_FORMAT:%u",info.format);

    AndroidBitmap_lockPixels(env, bitmap, &data);   // 锁定获得图像数据在内存地址的指针

    mRender->loadTexture(data, info.width, info.height);

    AndroidBitmap_unlockPixels(env, bitmap);
}

float * _newModelVerts;

static float * updata1(const double * delta)
{

    float ver[3] = {0,0,0};
//    float ner[3] = {0,0,0};

    SYObjInfo *_objInfo = mLoadObj->getObjModelData();
    SYMorphVert*  _vv = mLoadObj->getExpressionModelData();

    if (_newModelVerts == NULL)
        _newModelVerts = (float *)malloc(_objInfo->vertexNum * 3 * sizeof(float));

    for (int i=0; i < _objInfo->vertexNum; i++) {

        _newModelVerts[3*i]     = _objInfo->vertexs[3*i];
        _newModelVerts[3*i + 1] = _objInfo->vertexs[3*i + 1];
        _newModelVerts[3*i + 2] = _objInfo->vertexs[3*i + 2];

        for (int j=0; j<36; j++) {

            ver[0] += _vv->mv[j][0] * (delta[j] ); // ceres->fp
            ver[1] += _vv->mv[j][1] * (delta[j] );
            ver[2] += _vv->mv[j][2] * (delta[j] );

//            ner[0] += _newModelVerts->mn[j][0] * ceres->fp[j];
//            ner[1] += _newModelVerts->mn[j][1] * ceres->fp[j];
//            ner[2] += _newModelVerts->mn[j][2] * ceres->fp[j];
        }

        _newModelVerts[3*i]     += ver[0];
        _newModelVerts[3*i + 1] += ver[1];
        _newModelVerts[3*i + 2] += ver[2];

//        objinfo2->normals[3*i] = ner[0] + _objInfo.normals[3*i];
//        objinfo2->normals[3*i + 1] = ner[1] + _objInfo.normals[3*i + 1];
//        objinfo2->normals[3*i + 2] = ner[2] + _objInfo.normals[3*i + 2];

        memset(ver, 0, sizeof(ver));
//        memset(ner, 0, sizeof(ner));

        _vv ++;
    }

    return _newModelVerts;
}

SYObjInfo efe;
float * _facePose;
int qwe = 0;
JNIEXPORT void JNICALL render(JNIEnv *env, jclass)
{
    LOGE("------------> render");

//    double delta[36] = {-0.099261, -0.023325, -0.030190,
//                        0.047750, -0.041427, 1.0,
//                        0.094494, 0.019361, 0.027118,
//                        0.026461, 0.035417, -0.023444,
//                        -0.023965, -0.014375, -0.022750,
//                        -0.014271, 0.777619, -0.008162,
//                        0.125505, 0.113436, -0.111913,
//                        0.056678, 0.109149, -0.028117,
//                        -0.006957, -0.000055, 0.022620,
//                        0.108197, -0.063366, -0.032097,
//                        0.039463,-0.073214, -0.022388,
//                        -0.034169, -0.103642, -0.321172 };
//
//    memset(delta,0, sizeof(delta));
//    if (qwe == 0){delta[5] = 0.0;delta[6] = 0.0;}
//
//    if (qwe == 1){delta[5] = 1.0;delta[6] = 0.0;}
//
//    if (qwe == 2){delta[5] = 0.0;delta[6] = 1.0;}
//
//    if (qwe == 3){delta[5] = 1.0;delta[6] = 1.0;}
//
//    efe.vertexs = updata1(delta);
//    efe.vertexNum = mLoadObj->getObjModelData()->vertexNum;
//
//    qwe += 1;
//    if (qwe == 4)
//        qwe = 0;

//    mRender->tramformMatrix(_facePose);


    mRender->updataVertexForVBO(&efe);

    mRender->render();

}

JNIEXPORT void JNICALL viewPort(JNIEnv *env, jclass, int w, int h)
{
    LOGE("------------> viewPort");
    mRender->viewPort(w, h);
}

JNIEXPORT void JNICALL updataModelVerWithFacePoints(JNIEnv *env, jclass, jfloatArray j_array, jfloatArray j_pose)
{

    //1. 获取数组指针和长度
    jfloat *c_array = env->GetFloatArrayElements(j_array, 0);
    int len_arr = env->GetArrayLength(j_array);

    //2. 具体处理
    SYDelta syDelta;
    mCeres->ceresFun(&syDelta, c_array, mLoadObj1);

    // 优化 放大眼部变换
    syDelta.fp[16] += 0.1;syDelta.fp[5] *= 4;syDelta.fp[6] *= 4;

    // 更新模型数据
    efe.vertexs = updata1(syDelta.fp);
    efe.vertexNum = mLoadObj->getObjModelData()->vertexNum;

    jfloat *c_pose = env->GetFloatArrayElements(j_pose, 0);
    _facePose = (float *)c_pose;
    
    //3. 释放内存
    env->ReleaseFloatArrayElements(j_array, c_array, 0);

    memset(syDelta.fp, 0, 36 * sizeof(double));
}

static JNINativeMethod methods[] = {
    {"loadObjAndMorph",     "(Landroid/content/Context;Ljava/lang/String;)I",      (void*)loadObjAndMorph },
    {"initGL",              "()I",      (void*)initGL },
    {"bindBitmap",          "(Landroid/graphics/Bitmap;)V",      (void*)bindBitmap },
    {"render",              "()V",      (void*)render },
    {"viewPort",            "(II)V",    (void*)viewPort },
    {"updataModelVerWithFacePoints",     "([F[F)V",    (void*)updataModelVerWithFacePoints },
};

static const char *classPathName = "com/vrlib/SYRender";

/*
 * Register several native methods for one class.
 */
static int registerNativeMethods(JNIEnv* env, const char* className,
  JNINativeMethod* gMethods, int numMethods)
{
    jclass clazz;

    clazz = env->FindClass(className);
    if (clazz == NULL) {
        LOGE("Native registration unable to find class '%s'", className);
        return JNI_FALSE;
    }
    if (env->RegisterNatives(clazz, gMethods, numMethods) < 0) {
        LOGE("RegisterNatives failed for '%s'", className);
        return JNI_FALSE;
    }

    sClazz = (jclass)env->NewGlobalRef(clazz);
    return JNI_TRUE;
}

/*
 * Register native methods for all classes we know about.
 *
 * returns JNI_TRUE on success.
 */
static int registerNatives(JNIEnv* env)
{
    if (!registerNativeMethods(env, classPathName,
        methods, sizeof(methods) / sizeof(methods[0]))) {
        return JNI_FALSE;
    }

    return JNI_TRUE;
}

// ----------------------------------------------------------------------------

/*
 * This is called by the VM when the shared library is first loaded.
 */

typedef union {
  JNIEnv* env;
  void* venv;
} UnionJNIEnvToVoid;

jint JNI_OnLoad(JavaVM* vm, void* reserved)
{
    UnionJNIEnvToVoid uenv;
    uenv.venv = NULL;
    jint result = -1;
    JNIEnv* env = NULL;
  
    LOGE("JNI_OnLoad");

    if (vm->GetEnv(&uenv.venv, JNI_VERSION_1_4) != JNI_OK) {
        LOGE("ERROR: GetEnv failed");
        goto bail;
    }
    env = uenv.env;
    sVM = vm;
    if (registerNatives(env) != JNI_TRUE) {
        LOGE("ERROR: registerNatives failed");
        goto bail;
    }    

    result = JNI_VERSION_1_4;    
    bail:
    return result;
}