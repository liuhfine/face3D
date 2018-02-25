//
// Created by sunny on 2018/2/2.
//

#ifndef PANORAMA_ANDROID_SYLOADOBJ_H
#define PANORAMA_ANDROID_SYLOADOBJ_H

#include <stdio.h>
#include <jni.h>
#include "mLog.h"

typedef struct SYMorphVert
{
    float mv[36][3];
    float mn[36][3];

//    float mv[48][3];
//    float mn[48][3];

//    float mv[72][3];
//    float mn[72][3];

}morphVert;

typedef struct SYObjInfo
{
    int vertexNum;
    int normalsNum;
    int texCoordsNum;
    int facesNum;

    float *vertexs;
    float *normals;
    float *texCoords;
    short *faceIndexs;

}ObjInfo;

typedef struct SYMtlInfo
{
    int usemtlNum;

    char *usemtl;
    int *materialFirst;
    int *materialCount;

    float *Kd;
    float *Ka;
    float *Tf;

}MtlInfo;


class SYLoadObj {

public:

    SYLoadObj();
    ~SYLoadObj();

    /**
 obj 和表情库文件解析
 @param filePath 文件名（不包含后缀）
 */
    int reload_objfile(JNIEnv *env, jstring objfile, jobject context);

    struct SYObjInfo* getObjModelData();

    struct SYMorphVert* getExpressionModelData();

private:
    struct SYMorphVert  *_morphVert;
    struct SYObjInfo    _objInfo;
    struct SYMtlInfo    *_mtlInfo;

    /** 表情库文件解析 */
    int reload_objfile2(JNIEnv *env, const char* filePath, jobject context, int expression_num);

    const char* reload_obj_expression(JNIEnv *env, const char *objfile, jobject context);
    int read_poly_indices(const char *line, int *_vi, int *_ti, int *_ni);
    void read_usemtl(const char *line);
    void read_f(const char *line);
    void read_vt(const char *line);
    void read_vn(const char *line);
    void read_v(const char *line);

};


#endif //PANORAMA_ANDROID_SYLOADOBJ_H
