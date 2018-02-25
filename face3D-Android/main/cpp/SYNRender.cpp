//
// Created by sunny on 2018/2/1.
//
#include "SYNRender.h"
#include <stdio.h>
#include "glm/mat4x4.hpp"
#include "glm/ext.hpp"
//#include "glm/vec3.hpp"

const char * vert = "attribute vec4 aPosition;\n"
        "attribute vec3 aNormal;\n"
        "attribute vec2 aTexture;\n"
        "\n"
        "uniform mat4 vMatrixs;\n"
        "uniform mat3 vNormalMatrix;\n"
        "\n"
        "varying vec3 vNormal;\n"
        "varying vec2 vTexture;\n"
        "\n"
        "void main()\n"
        "{\n"
        "    //vNormal  = vNormalMatrix * aNormal;\n"
        "    vNormal  = aNormal;\n"
        "    vTexture =  aTexture;\n"
        "\n"
        "    gl_Position =   vMatrixs * aPosition;\n"
        "\n"
        "}";

const char * farg = "#ifdef GL_ES\n"
        "precision highp float;\n"
        "#endif\n"
        "\n"
        "// Input from Vertex Shader\n"
        "varying mediump vec3 vNormal;\n"
        "varying mediump vec2 vTexture;\n"
        "\n"
        "// MTL Data\n"
        "uniform lowp vec3 uAmbient;\n"
        "uniform lowp vec3 uDiffuse;\n"
        "uniform lowp vec3 uSpecular;\n"
        "uniform highp float uExponent;\n"
        "\n"
        "uniform lowp int uMode;\n"
        "uniform lowp vec3 uColor;\n"
        "uniform sampler2D uTexture;\n"
        "\n"
        "lowp vec3 materialDefault(highp float df, highp float sf)\n"
        "{\n"
        "    lowp vec3 ambient = vec3(0.5);\n"
        "    lowp vec3 diffuse = vec3(0.5);\n"
        "    lowp vec3 specular = vec3(0.0);\n"
        "    highp float exponent = 1.0;\n"
        "\n"
        "    sf = pow(sf, exponent);\n"
        "\n"
        "    return (ambient + (df * diffuse) + (sf * specular));\n"
        "}\n"
        "\n"
        "lowp vec3 materialMTL(highp float df, highp float sf)\n"
        "{\n"
        "    sf = pow(sf, uExponent);\n"
        "\n"
        "    return (uAmbient + (df * uDiffuse) + (sf * uSpecular));\n"
        "}\n"
        "\n"
        "lowp vec3 modelColor(void)\n"
        "{\n"
        "    highp vec3 N = normalize(vNormal);\n"
        "    highp vec3 L = vec3(0.8, 0.8, 0.5);\n"
        "    highp vec3 E = vec3(0.0, 0.0, 1.0);\n"
        "    highp vec3 H = normalize(L + E);\n"
        "\n"
        "    highp float df = max(0.0, dot(N, L));\n"
        "    highp float sf = max(0.0, dot(N, H));\n"
        "\n"
        "    // Default\n"
        "    if(uMode == 0)\n"
        "        return materialDefault(df, sf);\n"
        "\n"
        "    // Texture\n"
        "    else if(uMode == 1)\n"
        "        return (materialDefault(df, sf) * vec3(texture2D(uTexture, vTexture)));\n"
        "\n"
        "    // Material\n"
        "    else if(uMode == 2)\n"
        "        return materialMTL(df, sf);\n"
        "}\n"
        "\n"
        "void main()\n"
        "{\n"
        "    lowp vec3 color = modelColor();\n"
        "    gl_FragColor = vec4(color, 1.0);\n"
        "}";



glm::mat4 projection;
glm::mat4 projection2;
glm::mat4 view;
glm::mat4 model;

SYNRender::SYNRender() {

}

// float VerticesPoint[8] = { -1.0f, -1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 1.0f, 1.0f, };
// float CoordPoint[8] = { 0.0f, 1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, };
// static float* syMatrix = new float[16];

int outMTLNumMaterials = 5;

static int sy_outMTLFirst [] = {
        0,
        576,
        1152,
        63330,
        63906,
};

static int sy_outMTLCount [] = {
        576,
        576,
        62178,
        576,
        3996,
};

void SYNRender::initGL() {

    _program = buildProgram(vert, farg);
    glUseProgram(_program);

    _attributes.aVertex = glGetAttribLocation(_program, "aPosition");
    _attributes.aNormal = glGetAttribLocation(_program, "aNormal");
    _attributes.aTexture = glGetAttribLocation(_program, "aTexture");

    _uniforms.uModelViewMatrix = glGetUniformLocation(_program, "vMatrixs");

    _uniforms.uAmbient = glGetUniformLocation(_program, "uAmbient");
    _uniforms.uDiffuse = glGetUniformLocation(_program, "uDiffuse");
    _uniforms.uSpecular = glGetUniformLocation(_program, "uSpecular");
    _uniforms.uExponent = glGetUniformLocation(_program, "uExponent");
    _uniforms.uTexture = glGetUniformLocation(_program, "uTexture");
    _uniforms.uMode = glGetUniformLocation(_program, "uMode");

    glEnable(GL_DEPTH_TEST);

    float ratio = 1.0f; // width/height

//    projection = glm::ortho(-1.0f, 1.0f, -ratio, ratio, 1.0f, 100.0f);

    projection = glm::perspective(glm::radians(45.0f),1.0f,0.1f,400.0f);


    view = glm::lookAt(glm::vec3(0.0f,0.0f,5.0f),
                       glm::vec3(0.0f,0.0f,0.0f),
                       glm::vec3(0.0f,1.0f,0.0f));

    model = glm::mat4(1.0f);//

    float scale = 1.0f;
    model = glm::scale(model, glm::vec3(scale, scale, scale));

    projection = glm::translate(projection, glm::vec3(0.0f,-0.5f,0.0f));
    projection2 = view;

//    view = glm::rotate(view, 0.5f, glm::vec3(0.0f,1.0f,0.0f));
}

void SYNRender::tramformMatrix(float *pose)
{
    if (pose == NULL)
        return;

    float qq = pose[0]/ 3.1415 * 180;
    float qq1 = pose[1]/ 3.1415 * 180 - 180;
    float qq2 = pose[2]/ 3.1415 * 180 - 180;
    view = glm::rotate(view, pose[1], glm::vec3(1.0f,0.0f,0.0f));
    view = glm::rotate(view, -pose[0], glm::vec3(0.0f,1.0f,0.0f));
//    view = glm::rotate(view, pose[2], glm::vec3(0.0f,0.0f,1.0f));
}

void SYNRender::render() {

    glClearColor(1.0f, 0.0f, 0.0f, 1.0f);

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

//    if (isLoadMorphEnd)
//    {
//        glBindBuffer(GL_ARRAY_BUFFER, _vbos.vertexs);
//        glBufferSubData(GL_ARRAY_BUFFER, 0, positions.capacity()*4, positions);
//        glBindBuffer(GL_ARRAY_BUFFER, 0);
//
//        isMorphEnd = false;
//    }
//
//    tramformMatrix(NULL);

    glm::mat4 mvpMatrix = projection * view * model;

    view = projection2;
    float *mvp = (float *) glm::value_ptr(mvpMatrix);

    glUniformMatrix4fv(_uniforms.uModelViewMatrix, 1, GL_FALSE, mvp);

    /* VBO 预加载顶点数据，存储至图形卡缓存上 */
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _vbos.vertexIndics);

    glBindBuffer(GL_ARRAY_BUFFER, _vbos.normals);
    glVertexAttribPointer(_attributes.aNormal,
                          3,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(float) * 3,
                          0);
    glEnableVertexAttribArray(_attributes.aNormal);// 开启顶点数据


    glBindBuffer(GL_ARRAY_BUFFER, _vbos.textures);
    glVertexAttribPointer(_attributes.aTexture,
                          2,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(float) * 2,
                          0);
    glEnableVertexAttribArray(_attributes.aTexture);

    glBindBuffer(GL_ARRAY_BUFFER, _vbos.vertexs);
    glVertexAttribPointer(_attributes.aVertex,
                          3,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(float) * 3,
                          0);
    glEnableVertexAttribArray(_attributes.aVertex);


    glUniform1i(_uniforms.uMode, 1);

    for (int i=0; i<outMTLNumMaterials; i++)
    {
        if (i < 2) {
            glActiveTexture(GL_TEXTURE0 + 1);
            glBindTexture(GL_TEXTURE_2D, 1);
            glUniform1i(_uniforms.uTexture, 1);
        }

        if (i == 2) {
            glActiveTexture(GL_TEXTURE0 + 2);
            glBindTexture(GL_TEXTURE_2D, 2);
            glUniform1i(_uniforms.uTexture, 2);
        }

        if (i > 2) {
            glActiveTexture(GL_TEXTURE0 + 3);
            glBindTexture(GL_TEXTURE_2D, 3);
            glUniform1i(_uniforms.uTexture, 3);
        }

        glDrawElements(GL_TRIANGLES, sy_outMTLCount[i], GL_UNSIGNED_SHORT, (GLvoid *) (sizeof(short) * sy_outMTLFirst[i]));

    }

    glBindBuffer(GL_ARRAY_BUFFER, 0);//解除VBO绑定
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

}

void SYNRender::viewPort(int w, int h) {
    glViewport(0, 0, w, h);
}

void SYNRender::updataVertexForVBO(SYObjInfo *modelData)
{
    if (modelData == NULL || _vbos.vertexs == 0)
        return;

    glBindBuffer(GL_ARRAY_BUFFER, _vbos.vertexs);
    glBufferSubData(GL_ARRAY_BUFFER, 0, modelData->vertexNum * 3 * sizeof(float), modelData->vertexs);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

void SYNRender::loadVertexForVBO(SYObjInfo *modelData)
{
    if (modelData == NULL)
        return;

    _vbos.vertexIndics = sy_bindBuffer(modelData->faceIndexs, modelData->facesNum * 3);
    _vbos.vertexs = sy_bindBuffer(modelData->vertexs, modelData->vertexNum * 3);
    _vbos.normals = sy_bindBuffer(modelData->normals, modelData->normalsNum * 3);
    _vbos.textures = sy_bindBuffer(modelData->texCoords, modelData->texCoordsNum * 2);

//    face_num = modelData->facesNum;
}

GLuint SYNRender::sy_bindBuffer(short* data, int size)
{
    GLuint temp;

    glGenBuffers(1, &temp);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, temp);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER,
                 size * sizeof(short),
                 data,
            GL_STATIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

    return temp;
}

GLuint SYNRender::sy_bindBuffer(float* data, int size)
{
    GLuint temp;
    glGenBuffers(1, &temp);
    glBindBuffer(GL_ARRAY_BUFFER, temp);
    glBufferData(GL_ARRAY_BUFFER,
                 size * sizeof(float),
                 data,
            GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);

    return temp;
}

void SYNRender::loadTexture(const void * bitmapData, int w, int h)
{

    GLuint textureIds;
    glGenTextures(1, &textureIds);
    if (textureIds == 0)
    {
        LOGE("<<<<<<<<<<<<纹理创建失败!>>>>>>>>>>>>");
        return;
    }

    glActiveTexture(GL_TEXTURE0 + textureIds);
    glBindTexture(GL_TEXTURE_2D, textureIds);

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, bitmapData);

    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    glBindTexture(GL_TEXTURE_2D, 0);

    LOGE("glBindTexture id : %d", textureIds);
}

GLuint SYNRender::buildShader(const char*source, GLenum shaderType)
{
    GLuint shaderHandle = glCreateShader(shaderType);

    glShaderSource(shaderHandle, 1, &source, 0);

    glCompileShader(shaderHandle);

// Check for errors
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE)
    {
        LOGE("GLSL Shader Error");
        GLchar messages[1024];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        LOGE("%s", messages);

        return -1;
    }

    return shaderHandle;
}

GLuint SYNRender::buildProgram(const char* vertexShaderSource, const char* fragmentShaderSource)
{

    GLuint vertexShader = buildShader(vertexShaderSource, GL_VERTEX_SHADER);
    GLuint fragmentShader = buildShader(fragmentShaderSource, GL_FRAGMENT_SHADER);

    // Create program
    GLuint programHandle = glCreateProgram();

    // Attach shaders
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);

    // Link program
    glLinkProgram(programHandle);

    // Check for errors
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE)
    {
        LOGE("GLSL Program Error");
        GLchar messages[1024];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        LOGE("%s", messages);
        return  -1;
    }

    // Delete shaders
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);

    return programHandle;
}


