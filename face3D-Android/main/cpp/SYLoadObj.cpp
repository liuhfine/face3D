//
// Created by sunny on 2018/2/2.
//

#include "SYLoadObj.h"
#include <stdlib.h>
#include <string.h>
#include <android/asset_manager_jni.h>
#include <android/asset_manager.h>

#define MAXSTR 1024

int SYLoadObj::read_poly_indices(const char *line, int *_vi, int *_ti, int *_ni)
{
    int n;

    if (sscanf(line, "%d/%d/%d%n", _vi, _ti, _ni, &n) >= 3) return n;
    if (sscanf(line, "%d/%d%n", _vi, _ti, &n) >= 2) return n;
    if (sscanf(line, "%d//%d%n", _vi, _ni, &n) >= 2) return n;
    if (sscanf(line, "%d%n", _vi, &n) >= 1) return n;

    return 0;
}

void SYLoadObj::read_usemtl(const char *line)
{

    sscanf(line, " %s",
           _mtlInfo->usemtl + _mtlInfo->usemtlNum);

    _mtlInfo->usemtlNum ++;
}

void SYLoadObj::read_f(const char *line)
{
    int i[3];

    _objInfo.faceIndexs = (short *)realloc(_objInfo.faceIndexs,(_objInfo.facesNum+1)*3*sizeof(short));

    int dc;
    int j = 0;
    const char *c = line;
    while ((dc = read_poly_indices(c, i, i + 1, i + 2))) {

        c += dc;

        _objInfo.faceIndexs[_objInfo.facesNum*3 + j] = *i - 1; // obj file indes is 1

        j ++;
    }

    //    cout << "vertexNum:" << _objInfo.facesNum  << " " << _objInfo.faceIndexs[_objInfo.facesNum*3] << " " << _objInfo.faceIndexs[_objInfo.facesNum*3 + 1] << " " << _objInfo.faceIndexs[_objInfo.facesNum*3 + 2] << endl;

    _objInfo.facesNum ++;

}

void SYLoadObj::read_vt(const char *line)
{

    _objInfo.texCoords = (float *)realloc(_objInfo.texCoords,(_objInfo.texCoordsNum+1)*2*sizeof(float));

    sscanf(line, "%f %f",
           _objInfo.texCoords + _objInfo.texCoordsNum*2,
           _objInfo.texCoords + _objInfo.texCoordsNum*2 + 1);

    // vt.y = -vt.y  对y轴翻转
    _objInfo.texCoords[_objInfo.texCoordsNum*2 + 1] = 1 - _objInfo.texCoords[_objInfo.texCoordsNum*2 + 1];

    _objInfo.texCoordsNum ++;
}

void SYLoadObj::read_vn(const char *line)
{

    _objInfo.normals = (float *)realloc(_objInfo.normals,(_objInfo.normalsNum+1)*3*sizeof(float));

    sscanf(line, "%f %f %f",
           _objInfo.normals + _objInfo.normalsNum*3,
           _objInfo.normals + _objInfo.normalsNum*3 + 1,
           _objInfo.normals + _objInfo.normalsNum*3 + 2);

    _objInfo.normalsNum ++;
}

void SYLoadObj::read_v(const char *line)
{

    /* Parse a vertex position. */
    _objInfo.vertexs = (float *)realloc(_objInfo.vertexs, (_objInfo.vertexNum+1)*3*sizeof(float));

    sscanf(line, "%f %f %f",
           _objInfo.vertexs + _objInfo.vertexNum*3,
           _objInfo.vertexs + _objInfo.vertexNum*3 + 1,
           _objInfo.vertexs + _objInfo.vertexNum*3 + 2);

    _objInfo.vertexNum ++ ;

}

const char* SYLoadObj::reload_obj_expression(JNIEnv *env, const char *objfile, jobject context)
{
    jclass jclass1 = env->GetObjectClass(context);
    jmethodID getAssets = env->GetMethodID(jclass1, "getAssets", "()Landroid/content/res/AssetManager;");

    AAssetManager *aAssetManager = AAssetManager_fromJava(env, env->CallObjectMethod(context, getAssets));
    if (aAssetManager == NULL)
        return NULL;

    AAsset *asset = AAssetManager_open(aAssetManager, objfile, AASSET_MODE_UNKNOWN);
    if (asset == NULL)
        return NULL;

    long size = AAsset_getLength(asset);
    char *buffer = (char *)malloc(sizeof(char)*size+1);
    buffer[size] = '\n';
    AAsset_read(asset, buffer, size);

    AAsset_close(asset);

    return buffer;
}

int SYLoadObj::reload_objfile(JNIEnv *env, jstring objfile, jobject context)
{
    char objfile1[100]= {0};
    strcat(objfile1,env->GetStringUTFChars(objfile, JNI_FALSE));
    strcat(objfile1,".obj");

    char expressionfile1[100]= {0};
    strcat(expressionfile1,env->GetStringUTFChars(objfile, JNI_FALSE));
    strcat(expressionfile1,".txt");

//    LOGE("reload_objfile:%s   %s",objfile1,expressionfile1);

    char *buffer = (char *)reload_obj_expression(env, objfile1, context);

    _objInfo.vertexs = (float *) malloc(3*sizeof(float));
    _objInfo.normals = (float *) malloc(3*sizeof(float));
    _objInfo.texCoords = (float *) malloc(2*sizeof(float));
    _objInfo.faceIndexs = (short *) malloc(3*sizeof(short));

    char key[MAXSTR];

    int n;
    char *line;
    line = strtok(buffer,"\n");
    while (line != NULL)
    {
        if (sscanf(line, "%s%n", key, &n) >= 1)
        {
            const char *c = line + n;  // line str

            if (!strcmp(key, "v")) read_v(c);
            else if (!strcmp(key, "vt")) read_vt(c);
            else if (!strcmp(key, "vn")) read_vn(c);
            else if (!strcmp(key, "f")) read_f(c);

            //else if (!strcmp(key, "usemtl")) si = read_usemtl(c);
            //else if (!strcmp(key, "l")) read_l(c, fi, si);
            //else if (!strcmp(key, "mtllib"))      read_mtllib(L, c);
            //else if (!strcmp(key, "usemtl")) si = read_usemtl(D, L, c, fi);
            //else if (!strcmp(key, "s")) gi = atoi(c);
        }

        line = strtok(NULL,"\n");
    }

    free(buffer);

    reload_objfile2(env, expressionfile1, context, 36);

    return 0;
}

int SYLoadObj::reload_objfile2(JNIEnv *env, const char* filePath, jobject context, int expression_num)
{
    if (!filePath || _objInfo.vertexs == NULL)
        return 1;

    char *buffer = (char *)reload_obj_expression(env, filePath, context);

    if (_morphVert == NULL)
        _morphVert = (struct SYMorphVert *) malloc(_objInfo.vertexNum * sizeof(struct SYMorphVert));

    int n;
    char *line;
    line = strtok(buffer,"\n");

    float v[3];

    struct SYMorphVert * _vv;
    for (int i=0; i < _objInfo.vertexNum; i++) {

        _vv = _morphVert + i;

        for (int j=0; j < expression_num; j++) {

            sscanf(line, "%f %f %f", v + 0, v + 1, v + 2);
            _vv->mv[j][0] = v[0];
            _vv->mv[j][1] = v[1];
            _vv->mv[j][2] = v[2];

            // morph normal0
//            fgets(buf, MAXSTR, fin);
//            sscanf(buf, "%f %f %f", v + 0, v + 1, v + 2);
//            _vv->mn[j][0] = v[0];
//            _vv->mn[j][1] = v[1];
//            _vv->mn[j][2] = v[2];
            line = strtok(NULL,"\n");
        }
    }

    free(buffer);

    return 0;
}

struct SYObjInfo* SYLoadObj::getObjModelData()
{
    return &_objInfo;
}

struct SYMorphVert*  SYLoadObj::getExpressionModelData()
{
    return _morphVert;
}

SYLoadObj::SYLoadObj() {

    _morphVert = NULL;

    _objInfo.vertexs = NULL;
    _objInfo.normals = NULL;
    _objInfo.texCoords = NULL;
    _objInfo.faceIndexs = NULL;

    _objInfo.facesNum = 0;
    _objInfo.vertexNum = 0;
    _objInfo.normalsNum = 0;
    _objInfo.texCoordsNum = 0;
}

SYLoadObj::~SYLoadObj()
{
    if (_morphVert != NULL)
        free(_morphVert);

    if (_objInfo.vertexs != NULL)
        free(_objInfo.vertexs);

    if (_objInfo.normals != NULL)
        free(_objInfo.normals);

    if (_objInfo.texCoords != NULL)
        free(_objInfo.texCoords);

    if (_objInfo.faceIndexs != NULL)
        free(_objInfo.faceIndexs);

}