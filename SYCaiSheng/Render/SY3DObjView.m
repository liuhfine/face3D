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
#import "ShaderProcessor.h"
#import "Transformations.h"

#import "facegenOBJ.h"
#import "FaceGenMTL.h"
#import "cubeOBJ.h"
#import "cubeMTL.h"

#define STRINGIFY(A) #A
#import "Shader.fsh"
#import "Shader.vsh"


struct AttributeHandles
{
    GLint   aVertex;
    GLint   aNormal;
    GLint   aTexture;
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
    self.transformations = [[Transformations alloc] initWithDepth:5.0f Scale:5.0f Translation:GLKVector2Make(0.0f, 0.0f) Rotation:GLKVector3Make(0.0f, 0.0f, 0.0f)];
    
    // Load Texture
    [self loadTexture:@"facegen_eyel_hi.jpg"];
    [self loadTexture:@"facegen_eyer_hi.jpg"];
    [self loadTexture:@"facegen_skin_hi.jpg"];

    // Create the GLSL program
    _program = [self.shaderProcessor BuildProgram:ShaderV with:ShaderF];
    glUseProgram(_program);
    
    // Extract the attribute handles
    _attributes.aVertex = glGetAttribLocation(_program, "aVertex");
    _attributes.aNormal = glGetAttribLocation(_program, "aNormal");
    _attributes.aTexture = glGetAttribLocation(_program, "aTexture");
    
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
    
    // Attach Texture
//    glUniform1i(_uniforms.uTexture, 0);
//    glUniform1i(_uniforms.uTexture, 1);
//    glUniform1i(_uniforms.uTexture, 2);
}

- (void)loadVertexForVBO
{
    GLuint vertexbo;
    // 创建顶点缓存对象
    glGenBuffers(1, &vertexbo);
    // 指定绑定的目标，取值为 GL_ARRAY_BUFFER（用于顶点数据） 或 GL_ELEMENT_ARRAY_BUFFER（用于索引数据）；
    glBindBuffer(GL_ARRAY_BUFFER, vertexbo);
    // 为顶点缓存对象分配空间 并将数据缓存
    glBufferData(GL_ARRAY_BUFFER, sizeof(facegenOBJVerts), facegenOBJVerts, GL_STATIC_DRAW);
    
    /* index buffer object ibo fece 顶点索引
    GLuint indexbo;
    glGenBuffers(1, &indexbo);//创建ibobuffer
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexbo);//指定buffer类型
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indexBuf), indexBuf, GL_STATIC_DRAW); //上传数据到buffer
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);//解除绑定
     */
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
static float rotationX;
- (void)reloadObjData
{
    const float m = GLKMathDegreesToRadians(0.5f);
    [self.transformations rotate:GLKVector3Make(rotationX+=30.0f, 0.0f, 0.0f) withMultiplier:m];
    
    if (!self.window)
    {
        return;
    }
    @synchronized(self)
    {
        [self render];
    }
}

static int num = 0;
- (void)render {
    
    // Clear Buffers
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );

    // Set View Matrices
    [self updateViewMatrices];
    glUniformMatrix4fv(_uniforms.uProjectionMatrix, 1, 0, _projectionMatrix.m);
    glUniformMatrix4fv(_uniforms.uModelViewMatrix, 1, 0, _modelViewMatrix.m);
    glUniformMatrix3fv(_uniforms.uNormalMatrix, 1, 0, _normalMatrix.m);
    
    // Attach Texture
//    glUniform1i(_uniforms.uTexture, 0);
    
    // Set View Mode
    glUniform1i(_uniforms.uMode, 1);
    
    /* Load OBJ Data 没使用VBO，每次渲染都从CPU拷贝顶点数据到GPU */
    glVertexAttribPointer(_attributes.aVertex, 3, GL_FLOAT, GL_FALSE, 0, facegenOBJVerts);      // facegenOBJVerts cubeOBJVerts
    glEnableVertexAttribArray(_attributes.aVertex);
     
    glVertexAttribPointer(_attributes.aNormal, 3, GL_FLOAT, GL_FALSE, 0, facegenOBJNormals);    // facegenOBJNormals cubeOBJNormals
    glEnableVertexAttribArray(_attributes.aNormal);
    
    glVertexAttribPointer(_attributes.aTexture, 2, GL_FLOAT, GL_FALSE, 0, facegenOBJTexCoords); // facegenOBJTexCoords cubeOBJTexCoords
    glEnableVertexAttribArray(_attributes.aTexture);
    
    /* VBO 预加载顶点数据，存储至图形卡缓存上
    glVertexAttribPointer(_attributes.aVertex, 3, GL_FLOAT, GL_FALSE, 0, 0);//顶点坐标起始位置
    glEnableVertexAttribArray(_attributes.aVertex);
//    glVertexAttribPointer(_attributes.aNormal, 3, GL_FLOAT, GL_FALSE, sizeof(facegenOBJVerts), 0);
//    glEnableVertexAttribArray(_attributes.aNormal);
//    glVertexAttribPointer(_attributes.aTexture, 2, GL_FLOAT, GL_FALSE, +sizeof(facegenOBJNormals), 0);
//    glEnableVertexAttribArray(_attributes.aTexture);
    */

    for(int i=0; i<FaceGenMTLNumMaterials; i++)
    {
        glUniform3f(_uniforms.uAmbient, FaceGenMTLAmbient[i][0], FaceGenMTLAmbient[i][1], FaceGenMTLAmbient[i][2]);
        glUniform3f(_uniforms.uDiffuse, FaceGenMTLDiffuse[i][0], FaceGenMTLDiffuse[i][1], FaceGenMTLDiffuse[i][2]);
        glUniform3f(_uniforms.uSpecular, FaceGenMTLSpecular[i][0], FaceGenMTLSpecular[i][1], FaceGenMTLSpecular[i][2]);
        glUniform1f(_uniforms.uExponent, FaceGenMTLExponent[i]);

        glUniform1i(_uniforms.uTexture, i);
        // Draw scene by material group
        glDrawArrays(GL_TRIANGLES, FaceGenMTLFirst[i], FaceGenMTLCount[i]);
    }

    // Disable Attributes
    glDisableVertexAttribArray(_attributes.aVertex);
    glDisableVertexAttribArray(_attributes.aNormal);
    glDisableVertexAttribArray(_attributes.aTexture);
    
//    glBindBuffer(GL_ARRAY_BUFFER, 0);//解除VBO绑定
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
