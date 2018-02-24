//
//  SYLoadOb.h
//  SYCaiSheng
//
//  Created by sunny on 2018/1/6.
//  Copyright © 2018年 hl. All rights reserved.
//

#ifndef SYLoadObj_h
#define SYLoadObj_h

#include <stdio.h>

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


/**
 obj 文件解析

 @param filePath file_path
 @param objinfo obj数据模型
 @return 0
 */
int reload_objfile(const char* filePath, struct SYObjInfo* objinfo);


/**
 表情库文件解析

 @param filePath file_path
 @param morphVert 表情数据模型
 @param expression_num 36
 @return 0
 */
int reload_objfile2(const char* filePath, struct SYMorphVert* morphVert, int expression_num);

#endif /* SYLoadObj_h */
