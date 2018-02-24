//
//  SYLoadOb.c
//  SYCaiSheng
//
//  Created by sunny on 2018/1/6.
//  Copyright © 2018年 hl. All rights reserved.
//

#include "SYLoadObj.h"
#include <stdlib.h>
#include <string.h>

#define MAXSTR 1024

struct SYMorphVert *_morphVert;
struct SYObjInfo *_objInfo;
struct SYMtlInfo *_mtlInfo;

int read_poly_indices(const char *line, int *_vi, int *_ti, int *_ni)
{
    int n;

    if (sscanf(line, "%d/%d/%d%n", _vi, _ti, _ni, &n) >= 3) return n;
    if (sscanf(line, "%d/%d%n", _vi, _ti, &n) >= 2) return n;
    if (sscanf(line, "%d//%d%n", _vi, _ni, &n) >= 2) return n;
    if (sscanf(line, "%d%n", _vi, &n) >= 1) return n;

    return 0;
}

static void read_usemtl(const char *line)
{
    
    sscanf(line, " %s",
           _mtlInfo->usemtl + _mtlInfo->usemtlNum);

    _mtlInfo->usemtlNum ++;
}

static void read_f(const char *line)
{
    int i[3];

    _objInfo->faceIndexs = (short *)realloc(_objInfo->faceIndexs,(_objInfo->facesNum+1)*3*sizeof(short));

    int dc;
    int j = 0;
    const char *c = line;

    while ((dc = read_poly_indices(c, i, i + 1, i + 2))) {
        //        cout << j <<" :---------: " << *i << " " << *(i + 1) << " " << *(i + 2) << endl;

        c += dc;

        _objInfo->faceIndexs[_objInfo->facesNum*3 + j] = *i - 1; // obj file indes is 1

        j ++;
    }

    //    cout << "vertexNum:" << _objInfo.facesNum  << " " << _objInfo.faceIndexs[_objInfo.facesNum*3] << " " << _objInfo.faceIndexs[_objInfo.facesNum*3 + 1] << " " << _objInfo.faceIndexs[_objInfo.facesNum*3 + 2] << endl;
    
    _objInfo->facesNum ++;
    
}

static void read_vt(const char *line)
{

    _objInfo->texCoords = (float *)realloc(_objInfo->texCoords,(_objInfo->texCoordsNum+1)*2*sizeof(float));

    sscanf(line, "%f %f",
           _objInfo->texCoords + _objInfo->texCoordsNum*2,
           _objInfo->texCoords + _objInfo->texCoordsNum*2 + 1);

    // vt.y = -vt.y  对y轴翻转
    _objInfo->texCoords[_objInfo->texCoordsNum*2 + 1] = 1 - _objInfo->texCoords[_objInfo->texCoordsNum*2 + 1];

    _objInfo->texCoordsNum ++;
}

static void read_vn(const char *line)
{

    _objInfo->normals = (float *)realloc(_objInfo->normals,(_objInfo->normalsNum+1)*3*sizeof(float));

    sscanf(line, "%f %f %f",
           _objInfo->normals + _objInfo->normalsNum*3,
           _objInfo->normals + _objInfo->normalsNum*3 + 1,
           _objInfo->normals + _objInfo->normalsNum*3 + 2);

    _objInfo->normalsNum ++;
}

static void read_v(const char *line)
{

    /* Parse a vertex position. */
    _objInfo->vertexs = (float *)realloc(_objInfo->vertexs, (_objInfo->vertexNum+1)*3*sizeof(float));

    sscanf(line, "%f %f %f",
           _objInfo->vertexs + _objInfo->vertexNum*3,
           _objInfo->vertexs + _objInfo->vertexNum*3 + 1,
           _objInfo->vertexs + _objInfo->vertexNum*3 + 2);
    
    _objInfo->vertexNum ++ ;
    
}

int reload_obj_expression(const char* objfile,const char* expressionfile, int expression_num)
{
    char buf[MAXSTR];
    char key[MAXSTR];

    FILE *fin;
    if ((fin = fopen(objfile, "r")))
    {
        // save obj data
        _objInfo->vertexs = (float *) malloc(3*sizeof(float));
        _objInfo->normals = (float *) malloc(3*sizeof(float));
        _objInfo->texCoords = (float *) malloc(2*sizeof(float));
        _objInfo->faceIndexs = (short *) malloc(3*sizeof(short));

//        _mtlInfo->usemtl = (char *) malloc(512*sizeof(char));

        int n;
        while (fgets(buf, MAXSTR, fin)) {
            if (sscanf(buf, "%s%n", key, &n) >= 1)
            {
                const char *c = buf + n;  // line str

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
        }

    }
    else
        return 1;
    
    fclose(fin);
    fin = NULL;
    
    return 0;
}

int reload_objfile(const char* filePath,struct SYObjInfo* objinfo)
{
    if (!filePath)
        return 1;
    
    _objInfo = objinfo;
    
    _objInfo->facesNum = 0;
    _objInfo->vertexNum = 0;
    _objInfo->normalsNum = 0;
    _objInfo->texCoordsNum = 0;
    
    reload_obj_expression(filePath, NULL, 36);
    
    return 0;
}

#pragma mark - porpher
int reload_objfile2(const char* filePath, struct SYMorphVert* morphVert, int expression_num)
{
//    if (!filePath || !_objInfo)
//        return 1;
    
    FILE *fin;
    if ((fin = fopen(filePath, "r")))
    {
        char buf[MAXSTR];
        float v[3];
        
        struct SYMorphVert * _vv;
        for (int i=0; i < _objInfo->vertexNum; i++) {

            _vv = morphVert + i;

            for (int j=0; j < expression_num; j++) {

                fgets(buf, MAXSTR, fin);
                sscanf(buf, "%f %f %f", v + 0, v + 1, v + 2);
                _vv->mv[j][0] = v[0];
                _vv->mv[j][1] = v[1];
                _vv->mv[j][2] = v[2];

//                printf(" vertNum:%d 72Num:%d --- %f %f %f \n", i, j, v[0], v[1], v[2]);
                
                // morph normal0
//                fgets(buf, MAXSTR, fin);
//                sscanf(buf, "%f %f %f", v + 0, v + 1, v + 2);
//                _vv->mn[j][0] = v[0];
//                _vv->mn[j][1] = v[1];
//                _vv->mn[j][2] = v[2];
            }
            
        }
    
    }
    
    fclose(fin);
    fin = NULL;
    
    return 0;
}

