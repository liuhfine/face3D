//
//  SY3DObjView.m
//  SYCaiSheng
//
//  Created by sunny on 2017/11/27.
//  Copyright © 2017年 hl. All rights reserved.
//

#import "SY3DObjView.h"
#import <OpenGLES/ES2/gl.h>
#import <GLKit/GLKit.h>
#import <Accelerate/Accelerate.h>

#import "ShaderProcessor.h"
#import "Transformations.h"

//#import "jixiangwuOBJ.h"
//#import "outMTL.h"
//#import "EyeBlink_L_new.h"
//#import "JawOpen_new.h"

#define STRINGIFY(A) #A
#import "Shader.fsh"
#import "Shader.vsh"

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

@interface SY3DObjView()
{
    // Render
    GLuint  _program;
    GLuint  _texture;

    /** 帧缓冲区 */
    GLuint  _framebuffer;
    /** 渲染缓冲区 */
    GLuint  _renderBuffer;
    /** 渲染缓冲区 */
    GLuint _depthRenderBuffer;
    
    // View
    GLKMatrix4  _projectionMatrix;
    GLKMatrix4  _modelViewMatrix;
    GLKMatrix3  _normalMatrix;
    
    GLsizei     _viewScale;
    
    struct AttributeHandles _attributes;
    struct UniformHandles   _uniforms;
    struct BOHandles   _vbos;
    
    BOOL isExpression;
}
@property (strong, nonatomic) EAGLContext* glContext;
@property (strong, nonatomic) CAEAGLLayer *eaglLayer;
@property (strong, nonatomic) ShaderProcessor* shaderProcessor;
@property (strong, nonatomic) Transformations* transformations;
@end

@implementation SY3DObjView



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        if (![self doInit])
        {
            self = nil;
        }
    }
    return self;
}

#pragma mark - 设置openGL
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (void)destoryFrameAndRenderBuffer
{
    if (_framebuffer)
        glDeleteFramebuffers(1, &_framebuffer);
    
    if (_renderBuffer)
        glDeleteRenderbuffers(1, &_renderBuffer);

    if (_depthRenderBuffer)
        glDeleteFramebuffers(1, &_depthRenderBuffer);
    
    _framebuffer = 0;
    _renderBuffer = 0;
    _depthRenderBuffer = 0;
}

- (BOOL)createFrameAndRenderBuffer
{
    // 3D绘图一般绑定深度缓冲区，未绑定，开启enable深度测试无用
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.bounds.size.width * 2, self.bounds.size.height * 2);
    
    // openGL还需要在一块 buffer 上进行描绘，这块 buffer 就是 RenderBuffer（OpenGL ES 总共有三大不同用途的color buffer，depth buffer 和 stencil buffer
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    if (![_glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer])
    {
        NSLog(@"color_render_buffer渲染缓冲区失败");
    }
    
    // 通常也被称之为 FBO，它相当于 buffer(color, depth, stencil)的管理者，三大buffer 可以附加到一个 FBO 上。我们是用 FBO 来在 off-screen buffer上进行渲染
    glGenFramebuffers(1, &_framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
    
    // 检查帧缓冲状态
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"frame_buffer创建缓冲区错误 0x%x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }
    return YES;
}

- (void)layoutSubviews
{
    [EAGLContext setCurrentContext:_glContext];
    [self destoryFrameAndRenderBuffer];
    [self createFrameAndRenderBuffer];
    
    glViewport(0, 0, self.bounds.size.width * 2, self.bounds.size.height * 2);
}


- (BOOL)doInit
{
    self.eaglLayer = (CAEAGLLayer*) self.layer;
    self.eaglLayer.opaque = YES;
    self.eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
                                    kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                    nil];
    
    self.contentScaleFactor = [UIScreen mainScreen].scale;
    _viewScale = [UIScreen mainScreen].scale;
    
    _glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if(!_glContext || ![EAGLContext setCurrentContext:_glContext])
    {
        return NO;
    }
    
    // Initialize Class Objects
    self.shaderProcessor = [[ShaderProcessor alloc] init];
    
//    [self setupYUVTexture]; // 加载纹理
    
//    [self loadShader];    // 加载shader
    
//    glUseProgram(_program);  // useProgram
    
    [self setupGL];  //
    
//    [self setupVideoCache];
    
    return YES;
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:_glContext];
    
    // Enable depth test
    glEnable(GL_DEPTH_TEST);

    // Projection Matrix
    float aspectRatio = fabs(self.bounds.size.width / self.bounds.size.height);
    _projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45.0), aspectRatio, 0.1f, 400.0f);
    
    // ModelView Matrix
    _modelViewMatrix = GLKMatrix4Identity;
    
    // Initialize Model Pose
    self.transformations = [[Transformations alloc] initWithDepth:5.0f Scale:1.0f Translation:GLKVector2Make(0.0f, 0.0f) Rotation:GLKVector3Make(0.0f, 0.0f, 0.0f)];
    [self.transformations start];
    [self.transformations translate:GLKVector2Make(0.0f, 0.5f) withMultiplier:1.0f];
    
    // Load Texture
    [self loadTexture:@"meimao.jpg"];
    [self loadTexture:@"tou.jpg"];
    [self loadTexture:@"YJ.jpg"];

    // Create the GLSL program
    _program = [self.shaderProcessor BuildProgram:ShaderV with:ShaderF];
    glUseProgram(_program);
    
    // Extract the attribute handles
    _attributes.aVertex = glGetAttribLocation(_program, "aVertex");
    _attributes.aNormal = glGetAttribLocation(_program, "aNormal");
    _attributes.aTexture = glGetAttribLocation(_program, "aTexture");
    _attributes.aDelta = glGetAttribLocation(_program, "aDelta");
    
    // Extract the uniform handles
    _uniforms.uProjectionMatrix = glGetUniformLocation(_program, "uProjectionMatrix");
    _uniforms.uModelViewMatrix = glGetUniformLocation(_program, "uModelViewMatrix");
    _uniforms.uNormalMatrix = glGetUniformLocation(_program, "uNormalMatrix");
    _uniforms.uAmbient = glGetUniformLocation(_program, "uAmbient");
    _uniforms.uDiffuse = glGetUniformLocation(_program, "uDiffuse");
    _uniforms.uSpecular = glGetUniformLocation(_program, "uSpecular");
    _uniforms.uExponent = glGetUniformLocation(_program, "uExponent");
    _uniforms.uTexture = glGetUniformLocation(_program, "uTexture");
    _uniforms.uMode = glGetUniformLocation(_program, "uMode");
    
}

- (void)loadTexture:(NSString *)fileName
{

    NSDictionary* options = @{[NSNumber numberWithBool:YES] : GLKTextureLoaderOriginBottomLeft};
    
    NSError* error;
    NSString* path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    GLKTextureInfo* texture = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
    
    if(texture == nil)
        NSLog(@"Error loading file: %@", [error localizedDescription]);
   
    glActiveTexture(GL_TEXTURE0 + texture.name);
    glBindTexture(GL_TEXTURE_2D, texture.name);

    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    NSLog(@"glBindTexture id : %d", texture.name);
}

- (void)updateViewMatrices
{
    // ModelView Matrix
    _modelViewMatrix = [self.transformations getModelViewMatrix];
    
    // Normal Matrix
    // Transform object-space normals into eye-space
    _normalMatrix = GLKMatrix3Identity;
    bool isInvertible;
    _normalMatrix = GLKMatrix4GetMatrix3(GLKMatrix4InvertAndTranspose(_modelViewMatrix, &isInvertible));
}

#pragma mark - reloadData
- (void)updateExpressionWithVBO:(struct SYObjInfo *)objInfo
{
    if (!_vbos.vertexs || !objInfo)
        return;
    
    isExpression = YES;
    
    glBindBuffer(GL_ARRAY_BUFFER, _vbos.vertexs);
    glBufferSubData(GL_ARRAY_BUFFER, 0, objInfo->vertexNum * 3 * sizeof(float), objInfo->vertexs);
    glBindBuffer(GL_ARRAY_BUFFER, 0);

//    glBindBuffer(GL_ARRAY_BUFFER, _vbos.normals);
//    glBufferSubData(GL_ARRAY_BUFFER, objInfo->vertexNum * 3 * sizeof(float), objInfo->normalsNum * 3 * sizeof(float), objInfo->normals);
//    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
//    const float m = GLKMathDegreesToRadians(0.5f);
//    [self.transformations rotate:GLKVector3Make( -roll*100, pitch * 140, yaw) withMultiplier:m]; // pitch, roll, yaw  -roll*100

    if (!self.window)
    {
        return;
    }
    @synchronized(self)
    {
        [self render];
    }
}

static int face_num;
- (void)loadVertexForVBO:(struct SYObjInfo *)objInfo
{
    /*
     GL_STATIC_DRAW：表示该缓存区不会被修改；
     GL_DYNAMIC_DRAW：表示该缓存区会被周期性更改；
     GL_STREAM_DRAW：表示该缓存区会被频繁更改；
     
     指定绑定的目标
     GL_ARRAY_BUFFER（用于顶点数据）
     GL_ELEMENT_ARRAY_BUFFER（用于索引数据）
     */
    
    //    for (int i=0; i<objInfo->vertexNum; i++) {
    //        printf("vertexNum:%d %f %f %f \n", i,
    //               objInfo->vertexs[i * 3],
    //               objInfo->vertexs[i * 3 + 1],
    //               objInfo->vertexs[i * 3 + 2]);
    //    }
    
    glGenBuffers(1, &_vbos.vertexIndics);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _vbos.vertexIndics);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, objInfo->facesNum * 3 * sizeof(short), objInfo->faceIndexs, GL_STATIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    
    glGenBuffers(1, &_vbos.vertexs);
    glBindBuffer(GL_ARRAY_BUFFER, _vbos.vertexs);
    glBufferData(GL_ARRAY_BUFFER, objInfo->vertexNum * 3 * sizeof(float), objInfo->vertexs, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    glGenBuffers(1, &_vbos.normals);
    glBindBuffer(GL_ARRAY_BUFFER, _vbos.normals);
    glBufferData(GL_ARRAY_BUFFER, objInfo->normalsNum * 3 * sizeof(float), objInfo->normals, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    glGenBuffers(1, &_vbos.textures);
    glBindBuffer(GL_ARRAY_BUFFER, _vbos.textures);
    glBufferData(GL_ARRAY_BUFFER, objInfo->texCoordsNum * 2 * sizeof(float), objInfo->texCoords, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    face_num = objInfo->facesNum;
    
}

static float rotationX;
static int num = 0;
static float defaultScale = 0;

- (void)drawModelWithScale:(CGFloat)scale :(CGFloat)pitch :(CGFloat)roll :(CGFloat)yaw
{
    const float m = GLKMathDegreesToRadians(0.5f);
    num += 1; //
    rotationX+=0.6;
    
    [self.transformations rotate:GLKVector3Make(pitch, -roll, yaw) withMultiplier:m];
    

//    [self.transformations rotate:GLKVector3Make(pitch / 3.1415*180, roll / 3.1415 * 180 - 180, yaw / 3.1415 * 180 - 180) withMultiplier:m];
//    if (!defaultScale)
//        defaultScale = scale;
//    else {
//        float ddd;
//        if (defaultScale < 10.0) {
//            [self.transformations scale: 1.0];
//        }
//
//        if (defaultScale > 18.0) {
//            [self.transformations scale: 1.0 / [self.transformations getScaleStart]];
//        }
//
//        [self.transformations scale: ((defaultScale - scale + [self.transformations getScaleStart])/ [self.transformations getScaleStart])];
//
//        defaultScale = scale;
//    }
    
    if (!isExpression) {
        if (!self.window)
        {
            return;
        }
        @synchronized(self)
        {
            [self render];
        }
    }
}

int sy_outMTLFirst [5] = {
    0,
    576,
    1152,
    63330,
    63906,
};

const int sy_outMTLCount [5] = {
    576,
    576,
    62178,
    576,
    3996,
};

- (void)render {
    
    if (!face_num)
        return;
    
    // Clear Buffers
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );

    // Set View Matrices
    [self updateViewMatrices];
    glUniformMatrix4fv(_uniforms.uProjectionMatrix, 1, 0, _projectionMatrix.m);
    glUniformMatrix4fv(_uniforms.uModelViewMatrix, 1, 0, _modelViewMatrix.m);
    glUniformMatrix3fv(_uniforms.uNormalMatrix, 1, 0, _normalMatrix.m);
    
    // Set View Mode
    glUniform1i(_uniforms.uMode, 1);

    /* VBO 预加载顶点数据，存储至图形卡缓存上 */
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _vbos.vertexIndics);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vbos.normals);
    glVertexAttribPointer(_attributes.aNormal, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 3, 0);
    glEnableVertexAttribArray(_attributes.aNormal);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vbos.textures);
    glVertexAttribPointer(_attributes.aTexture, 2, GL_FLOAT, GL_FALSE, sizeof(float) * 2, 0);
    glEnableVertexAttribArray(_attributes.aTexture);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vbos.vertexs);
    glVertexAttribPointer(_attributes.aVertex, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 3, 0);
    glEnableVertexAttribArray(_attributes.aVertex);
    
    for (int i=0; i<5; i++) {

//        glUniform3f(_uniforms.uAmbient, outMTLAmbient[i][0], outMTLAmbient[i][1], outMTLAmbient[i][2]);
//        glUniform3f(_uniforms.uDiffuse, outMTLDiffuse[i][0], outMTLDiffuse[i][1], outMTLDiffuse[i][2]);
//        glUniform3f(_uniforms.uSpecular, outMTLSpecular[i][0], outMTLSpecular[i][1], outMTLSpecular[i][2]);
//        glUniform1f(_uniforms.uExponent, outMTLExponent[i]);

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

        glDrawElements(GL_TRIANGLES, sy_outMTLCount[i], GL_UNSIGNED_SHORT, (GLvoid*)(sizeof(short) * sy_outMTLFirst[i]));

    }
    
//    glDrawElements(GL_TRIANGLES, face_num * 3, GL_UNSIGNED_SHORT, 0);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);//解除VBO绑定
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [_glContext presentRenderbuffer:GL_RENDERBUFFER];
    
}

- (void)clearFrame
{
    if ([self window])
    {
        [EAGLContext setCurrentContext:_glContext];
        glClearColor(0.0, 0.0, 0.0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
        glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
        [_glContext presentRenderbuffer:GL_RENDERBUFFER];
    }
}

- (void)dealloc
{
    num = 0;
    isExpression = NO;
    
    if (_framebuffer) {
        glDeleteFramebuffers(1, &_framebuffer);
        _framebuffer = 0;
    }
    
    if (_renderBuffer) {
        glDeleteRenderbuffers(1, &_renderBuffer);
        _renderBuffer = 0;
    }
    
    if (_depthRenderBuffer) {
        glDeleteRenderbuffers(1, &_depthRenderBuffer);
        _depthRenderBuffer = 0;
    }
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
    
    if ([EAGLContext currentContext] == _glContext) {
        [EAGLContext setCurrentContext:nil];
    }
    
    _glContext = nil;
}

//    for(int i=0; i<outMTLNumMaterials; i++)
//    {
//
//        if (i < 2) {
//            glUniform1i(_uniforms.uTexture, 1);
//        }
//        if (i == 3) {
//            glUniform1i(_uniforms.uTexture, 2);
//        }
//
//        // Draw scene by material group
//        glDrawArrays(GL_TRIANGLES, outMTLFirst[i], outMTLCount[i]);
//    }

//    glDrawElements(GL_TRIANGLES, 4, GL_UNSIGNED_BYTE, 0);


//    glDrawArrays(GL_TRIANGLES, 0, jixiangwuOBJNumVerts);

// Disable Attributes
//    glDisableVertexAttribArray(_attributes.aVertex);
//    glDisableVertexAttribArray(_attributes.aNormal);
//    glDisableVertexAttribArray(_attributes.aTexture);
//    glDisableVertexAttribArray(_attributes.aDelta);

/* Load OBJ Data 没使用VBO，每次渲染都从CPU拷贝顶点数据到GPU
 glVertexAttribPointer(_attributes.aVertex, 3, GL_FLOAT, GL_FALSE, 0, jixiangwuOBJVerts);
 glEnableVertexAttribArray(_attributes.aVertex);
 
 glVertexAttribPointer(_attributes.aNormal, 3, GL_FLOAT, GL_FALSE, 0, jixiangwuOBJNormals);
 glEnableVertexAttribArray(_attributes.aNormal);
 
 glVertexAttribPointer(_attributes.aTexture, 2, GL_FLOAT, GL_FALSE, 0, jixiangwuOBJTexCoords);
 glEnableVertexAttribArray(_attributes.aTexture);
 
 if (num % 5 == 0) {
 glDisableVertexAttribArray(_attributes.aDelta);
 glVertexAttribPointer(_attributes.aDelta, 3, GL_FLOAT, GL_FALSE, 0, EyeBlink_L_new);
 glEnableVertexAttribArray(_attributes.aDelta);
 }
 
 if (num % 13 == 0)
 {
 glDisableVertexAttribArray(_attributes.aDelta);
 glVertexAttribPointer(_attributes.aDelta, 3, GL_FLOAT, GL_FALSE, 0, JawOpen_new);
 glEnableVertexAttribArray(_attributes.aDelta);
 }
 */

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
