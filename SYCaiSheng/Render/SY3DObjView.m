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
    /**
     帧缓冲区
     */
    GLuint  _framebuffer;
    
    /**
     渲染缓冲区
     */
    GLuint  _renderBuffer;
    
    
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
    {
        glDeleteFramebuffers(1, &_framebuffer);
    }
    
    if (_renderBuffer)
    {
        glDeleteRenderbuffers(1, &_renderBuffer);
    }
    
    _framebuffer = 0;
    _renderBuffer = 0;
}

- (BOOL)createFrameAndRenderBuffer
{
    glGenFramebuffers(1, &_framebuffer);
    glGenRenderbuffers(1, &_renderBuffer);
    
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    
    if (![_glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer])
    {
        NSLog(@"attach渲染缓冲区失败");
    }
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"创建缓冲区错误 0x%x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }
    return YES;
}

- (void)layoutSubviews
{

    [EAGLContext setCurrentContext:_glContext];
    [self destoryFrameAndRenderBuffer];
    [self createFrameAndRenderBuffer];
    
    glViewport(0, 0, self.bounds.size.width*2, self.bounds.size.height*2);
}


- (BOOL)doInit
{
//    self.glLayer = [CAEAGLLayer layer];
//    self.glLayer.frame = self.glView.bounds;
//    [self.glView.layer addSublayer:self.glLayer];
//    self.glLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking:@NO, kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8};
    
    
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
    CGRect screen = [[UIScreen mainScreen] bounds];
    float aspectRatio = fabsf(screen.size.width / screen.size.height);
    _projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45.0), aspectRatio, 0.1, 10.1);
    
    // ModelView Matrix
    _modelViewMatrix = GLKMatrix4Identity;
    
    // Initialize Model Pose
//    self.transformations = [[Transformations alloc] initWithDepth:5.0f Scale:1.33f Translation:GLKVector2Make(0.0f, 0.0f) Rotation:GLKVector3Make(0.0f, 0.0f, 0.0f)];
    
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
}

- (void)loadTexture:(NSString *)fileName
{
    NSDictionary* options = @{[NSNumber numberWithBool:YES] : GLKTextureLoaderOriginBottomLeft};
    
    NSError* error;
    NSString* path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    GLKTextureInfo* texture = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
    if(texture == nil)
        NSLog(@"Error loading file: %@", [error localizedDescription]);
    
    glBindTexture(GL_TEXTURE_2D, texture.name);
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

- (void)reloadObjData
{
    if (!self.window)
    {
        return;
    }
    @synchronized(self)
    {
        [self render];
    }
}

- (void)render {
    // Clear Buffers
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Set View Matrices
    [self updateViewMatrices];
    glUniformMatrix4fv(_uniforms.uProjectionMatrix, 1, 0, _projectionMatrix.m);
    glUniformMatrix4fv(_uniforms.uModelViewMatrix, 1, 0, _modelViewMatrix.m);
    glUniformMatrix3fv(_uniforms.uNormalMatrix, 1, 0, _normalMatrix.m);
    
    // Attach Texture
    glUniform1i(_uniforms.uTexture, 0);
    
    // Set View Mode
    glUniform1i(_uniforms.uMode, 1);
    
    // Enable Attributes
    glEnableVertexAttribArray(_attributes.aVertex);
    glEnableVertexAttribArray(_attributes.aNormal);
    glEnableVertexAttribArray(_attributes.aTexture);
    
    // Load OBJ Data
    glVertexAttribPointer(_attributes.aVertex, 3, GL_FLOAT, GL_FALSE, 0, facegenOBJVerts);
    glVertexAttribPointer(_attributes.aNormal, 3, GL_FLOAT, GL_FALSE, 0, facegenOBJNormals);
    glVertexAttribPointer(_attributes.aTexture, 2, GL_FLOAT, GL_FALSE, 0, facegenOBJTexCoords);
    
    
    // Load MTL Data
    for(int i=0; i<FaceGenMTLNumMaterials; i++)
    {
        glUniform3f(_uniforms.uAmbient, FaceGenMTLAmbient[i][0], FaceGenMTLAmbient[i][1], FaceGenMTLAmbient[i][2]);
        glUniform3f(_uniforms.uDiffuse, FaceGenMTLDiffuse[i][0], FaceGenMTLDiffuse[i][1], FaceGenMTLDiffuse[i][2]);
        glUniform3f(_uniforms.uSpecular, FaceGenMTLSpecular[i][0], FaceGenMTLSpecular[i][1], FaceGenMTLSpecular[i][2]);
        glUniform1f(_uniforms.uExponent, FaceGenMTLExponent[i]);
        
        if (i==0)
            [self loadTexture:@"facegen_eyel_hi.jpg"];
        else if(i==1)
            [self loadTexture:@"facegen_eyer_hi.jpg"];
        else
            [self loadTexture:@"facegen_skin_hi.jpg"];
        
        // Draw scene by material group
        glDrawArrays(GL_TRIANGLES, FaceGenMTLFirst[i], FaceGenMTLCount[i]);
    }
    
    // Disable Attributes
    glDisableVertexAttribArray(_attributes.aVertex);
    glDisableVertexAttribArray(_attributes.aNormal);
    glDisableVertexAttribArray(_attributes.aTexture);
    
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [_glContext presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)dealloc
{
    
    if (_framebuffer) {
        glDeleteFramebuffers(1, &_framebuffer);
        _framebuffer = 0;
    }
    
    if (_renderBuffer) {
        glDeleteRenderbuffers(1, &_renderBuffer);
        _renderBuffer = 0;
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
