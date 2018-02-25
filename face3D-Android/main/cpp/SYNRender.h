//
// Created by sunny on 2018/2/1.
//

#ifndef PANORAMA_ANDROID_SYNRENDER_H
#define PANORAMA_ANDROID_SYNRENDER_H


#include <GLES2/gl2.h>
#include "SYLoadObj.h"
#include "mLog.h"


struct AttributeHandles
{
    GLint   aVertex;
    GLint   aNormal;
    GLint   aTexture;
    GLint   aDelta;
};

struct UniformHandles
{
    GLuint  uProjectionMatrix;
    GLuint  uModelViewMatrix;
    GLuint  uNormalMatrix;

    GLint   uAmbient;
    GLint   uDiffuse;
    GLint   uSpecular;
    GLint   uExponent;

    GLint   uTexture;
    GLint   uMode;
};

struct BOHandles
{
    GLuint vertexIndics;
    GLuint vertexs;
    GLuint normals;
    GLuint textures;
};

class SYNRender {
public:
    SYNRender();
//    virtual  ~SYNRender();

    void initGL();
    void render();
    void viewPort(int w, int h);

    void loadTexture(const void * bitmapData, int w, int h);

    void loadVertexForVBO(SYObjInfo *modelData);

    void updataVertexForVBO(SYObjInfo *modelData);

    void tramformMatrix(float *pose);

private:

    struct AttributeHandles _attributes;
    struct UniformHandles   _uniforms;
    struct BOHandles   _vbos;
    GLuint  _program;

    GLuint sy_bindBuffer(short* data, int size);

    GLuint sy_bindBuffer(float* data, int size);

    GLuint buildShader(const char*source, GLenum shaderType);

    GLuint buildProgram(const char* vertexShaderSource, const char* fragmentShaderSource);

};



#endif //PANORAMA_ANDROID_SYNRENDER_H
