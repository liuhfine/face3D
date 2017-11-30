//
//  ViewController.m
//  SYCaiSheng
//
//  Created by sunny on 2017/11/20.
//  Copyright © 2017年 hl. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>
#import "ViewController.h"
//#import "SYSunnyMovieGLView.h"
#import "SY3DObjView.h"



#define Color [UIColor colorWithRed:237/255.0 green:82/255.0 blue:41/255.0 alpha:1]

@interface ViewController ()
<
 AVCaptureVideoDataOutputSampleBufferDelegate
>
{
    SY3DObjView *_objView;
}
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureVideoDataOutput *output;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, strong) AVCaptureConnection *videoConnection;

@property (nonatomic, strong) UIView *scanPreviewView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createCamera];
    [self createScanPreviewView];

    [self create3DView];
    
//    [self matrix];
}

- (void)create3DView
{
    CGFloat sizeX = ([UIScreen mainScreen].bounds.size.width - 60*2 );
    CGRect centerRect1 = CGRectMake(60, [UIScreen mainScreen].bounds.size.height / 4.0 - sizeX / 2.0, sizeX, sizeX);
    
    _objView = [[SY3DObjView alloc] initWithFrame:centerRect1];
    [self.view insertSubview:_objView atIndex:0];

}

- (void)viewDidAppear:(BOOL)animated
{

//    for (int i=0; i<10; i++) {
        [_objView reloadObjData];
//    }
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [_objView reloadObjData];
}


- (void)matrix
{
    /*
     // 示例二维数组： int example[5][10]
     // 数组的总数为：
     sizeof(example) / sizeof(int)       // sizeof(example)为该数组的大小(这里是5x10)，sizeof(int)为int类型的大小(4)
     // 数组列数为：
     sizeof(example[0])/sizeof(int)      // sizeof(example[0])为该数组一行的大小(这里是10)
     // 数组行数则为 ：
     ( sizeof(example) / sizeof(int) )/ ( sizeof(example[0]) / sizeof(int) )
     // 即是数组总数除以列数，化简就是 sizeof(example) / sizeof(example[0])
     */
    
    /* Accelerate/Accelerate.h https://developer.apple.com/documentation/accelerate
     
       vDSP API https://developer.apple.com/library/content/documentation/Performance/Conceptual/vDSP_Programming_Guide/About_vDSP/About_vDSP.html#//apple_ref/doc/uid/TP40005147-CH2-SW1
       vDSP_xxx 单精度浮点型  vDSP_xxxD双精度浮点型 vDSP_xxxi 整型
       vDSP_Stride __IA 步幅 1为逐点计算 2为间隔一位计算，一般为1
       vDSP_Length __N  m*n m行n列矩阵的行数，矩阵乘法需满足矩阵 m*n x n*H = m*h
     */
    
    
    
//    DSPComplex dfsfd = {real:3.0 ,imag:4.0};
# pragma mark - 矩阵运算
    /* 二位数组指针
     一维元素个数可以省略，二维必须声明
     matrixA[0] === matrixA === &matrixA[0][0]
     matrixA[1] === matrixA + 1 === &matrixA[1][0]
     */
    
    /* 矩阵相除 vDSP_mmul */
    float matrixA [3][3] = {{1, 2, 1},
                                {3, 1, 2},
                                {2, 1, 2}};
    
    float matrixB [3][1] = {{3},
                                {5},
                                {9}};
    
    float matrixC [3][1] = {3,5,9};
    
    float results [3][1] = {0};
    float resultss [3][1] = {0};
    
    vDSP_mmul(&matrixA[0][0], 1, &matrixB[0][0], 1, &results[0][0], 1, sizeof(matrixA) / sizeof(matrixA[0]), sizeof(matrixB[0]) / sizeof(float), sizeof(matrixA[0]) / sizeof(float));
    
    vDSP_vadd(results, 1, matrixC, 1, resultss, 1, 3);
    
    NSLog(@"矩阵运算(单精度浮点型) :%f %f %f",resultss[0][0],resultss[1][0],resultss[2][0]);
    
//    1492532240 1492532252 1492532240
    
    /* 矩阵相乘，在加第三个矩阵 vDSP_zmma */
//    DSPSplitComplex complexA;
//    complexA.realp = &matrixA[0][0];
//    complexA.imagp = {0};
//
//    DSPSplitComplex complexB;
//    complexB.realp = &matrixB[0][0];
//
//    DSPSplitComplex complexC;
//    complexC.realp = &matrixC[0][0];
//
//    DSPSplitComplex complexD;
//    complexD.realp = &results[0][0];
//
//    vDSP_zmma(&complexA, 1, &complexB, 1, &complexC, 1, &complexD, 1, 3, 1, 3);
//
//    NSLog(@"矩阵运算(单精度浮点型) :%f %f %f",*(complexD.realp),*(complexD.realp + 1),results[2][0]);
    
# pragma mark - 向量运算
//    const float v[] = {4.0,7.0};
//    const float s[] = {2.0,7.0};
//    float results[2];
    
    /* 向量相加 vDSP_vadd */
//    vDSP_vadd(v, 1, s, 1, results, 1, sizeof(v) / sizeof(float));
    
    /* 向量相乘 vDSP_vmul */
//    vDSP_vmul(v, 1, s, 1, results, 1, sizeof(v) / sizeof(float));
    
    /* 向量相除 vDSP_vdiv */
//    vDSP_vdiv(v, 1, s, 1, results, 1, sizeof(v) / sizeof(float));
    
    //    点乘的几何意义是可以用来表征或计算两个向量之间的夹角，以及在b向量在a向量方向上的投影，有公式：
    /* 向量点乘 vDSP_dotpr */
//    float dfdf;
//    vDSP_dotpr(v, 1, s, 1, &dfdf, sizeof(v) / sizeof(float));
    
    /***************************************************************/
    
//    const float v[] = {4.0,7.0};
//    const float s = 3.0;
//    float results[2];
    
    /* 向量和常数相除 vDSP_vsdiv */
//    vDSP_vsdiv(v, 1, &s, results, 1, sizeof(v) / sizeof(float));
    
    /* 向量和常数相乘 vDSP_vsmul */
//    vDSP_vsmul(v, 1, &s, results, 1, sizeof(v) / sizeof(float));
    
    /* 向量和常数相加 vDSP_vsadd */
//    vDSP_vsadd(v, 1, &s, results, 1, sizeof(v) / sizeof(float));
    
//    NSLog(@"向量和常数运算(单精度浮点型) :%f %f ",*results,*(results+1));
//    NSLog(@"向量运算(单精度浮点型) :%f %f ",*results,*(results+1));
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    //CVPixelBufferGetPlaneCount得到像素缓冲区平面数量，然后由CVPixelBufferGetBaseAddressOfPlane(索引)得到相应的通道，一般是Y、U、V通道存
    size_t planeCount = CVPixelBufferGetPlaneCount(imageBuffer);
    


    
    // 从容器中提取YUV数据
//    CVPixelBufferLockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
//    void *y_bity = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
//    void *u_bity = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 1);
//    void *v_bity = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 2);
 
//    void *yuvData = malloc(width*height*3);
//    for (int line=0; line<yuvData; ++line) {
//        memcmp(yuvData + line*, 1, 2)
//    }
//    NSLog(@"is video frame width:%d  planeCount:%d",CVPixelBufferGetPixelFormatType(imageBuffer),planeCount);

}


- (void)createCamera
{
    AVCaptureDevice *device;
    NSString *version = [UIDevice currentDevice].systemVersion;
    // 获取硬件设备
    if (version.doubleValue <= 10.0) {
        device = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].firstObject;
    } else {
        if (@available(iOS 10.0, *)) {
            device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
        } else {
            // Fallback on earlier versions
        }
    }
    
    // 初始化设备输入对象
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    self.input = input;
    
    // AVCaptureMetadataOutput 二维码数据
    self.output = [[AVCaptureVideoDataOutput alloc] init];
    //创建线程获取数据，捕获视频帧
    dispatch_queue_t captureQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [self.output setSampleBufferDelegate:self queue:captureQueue];
    // 抛弃过期帧
    [self.output setAlwaysDiscardsLateVideoFrames:YES];
    //设置输出格式为 yuv420 nv12 kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange   420p kCVPixelFormatType_420YpCbCr8PlanarFullRange
    [self.output setVideoSettings:@{
                                    (__bridge NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)
                                    }];
    
    // 保存Connection，用于在SampleBufferDelegate中判断数据来源（是Video/Audio？）
//    self.videoConnection = [self.output connectionWithMediaType:AVMediaTypeVideo];
    
    // 创建媒体会话
    self.session = [[AVCaptureSession alloc] init];
    
    [self.session beginConfiguration];
    
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
    
    // 会话添加输入输出
    if ([self.session canAddInput:input])
        [self.session addInput:input];
    
    if ([self.session canAddOutput:self.output])
        [self.session addOutput:self.output];
    
    [self.session commitConfiguration];
    
    [self.session startRunning];

    // 5.创建视频预览层，用于实时展示摄像头状态
    _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    CGFloat sizeX = ([UIScreen mainScreen].bounds.size.width - 60*2 );
    CGRect centerRect = CGRectMake(60, [UIScreen mainScreen].bounds.size.height / 4.0 * 3 - sizeX / 2.0, sizeX, sizeX);
    _captureVideoPreviewLayer.frame = centerRect;
    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//填充模式
    
    self.view.layer.masksToBounds = YES;
    [self.view.layer insertSublayer:_captureVideoPreviewLayer below:self.scanPreviewView.layer];
}


- (void)drawScanFrame
{
    CGRect centerRect = CGRectMake(0, 0, 200, 200);
    
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(centerRect.origin.x, centerRect.origin.y + centerRect.size.width / 4.0)];
    [linePath addLineToPoint:CGPointMake(centerRect.origin.x, centerRect.origin.y)];
    [linePath addLineToPoint:CGPointMake(centerRect.origin.x + centerRect.size.width / 4.0, centerRect.origin.y)];
    
    [linePath moveToPoint:CGPointMake(centerRect.origin.x + 3*centerRect.size.width / 4.0, centerRect.origin.y)];
    [linePath addLineToPoint:CGPointMake(centerRect.origin.x + centerRect.size.width, centerRect.origin.y)];
    [linePath addLineToPoint:CGPointMake(centerRect.origin.x + centerRect.size.width,centerRect.origin.y + centerRect.size.width / 4.0)];
    
    [linePath moveToPoint:CGPointMake(centerRect.origin.x + centerRect.size.width, centerRect.origin.y + 3 * centerRect.size.width / 4.0)];
    [linePath addLineToPoint:CGPointMake(centerRect.origin.x + centerRect.size.width, centerRect.origin.y + centerRect.size.width)];
    [linePath addLineToPoint:CGPointMake(centerRect.origin.x + 3 * centerRect.size.width / 4.0, centerRect.origin.y + centerRect.size.width)];
    
    [linePath moveToPoint:CGPointMake(centerRect.origin.x + centerRect.size.width / 4.0, centerRect.origin.y + centerRect.size.width)];
    [linePath addLineToPoint:CGPointMake(centerRect.origin.x, centerRect.origin.y + centerRect.size.width)];
    [linePath addLineToPoint:CGPointMake(centerRect.origin.x, centerRect.origin.y + 3 * centerRect.size.width / 4.0)];
    
    CAShapeLayer *layer = [CAShapeLayer  layer];
    layer.frame = CGRectMake(40, 150, 250, 250);
    layer.backgroundColor = [UIColor redColor].CGColor;
    
    layer.path = linePath.CGPath;
    layer.strokeColor = [UIColor cyanColor].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.lineWidth = 4;
    layer.lineJoin = kCALineJoinMiter;
    layer.lineCap = kCALineCapSquare;
    
    [self.scanPreviewView.layer addSublayer:layer];
}

- (void)createScanPreviewView
{
    self.scanPreviewView = [[UIView alloc] initWithFrame:self.view.frame];
    self.scanPreviewView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [self.view addSubview:self.scanPreviewView];
    
    // MARK: roundRectanglePath
    CGFloat sizeX = ([UIScreen mainScreen].bounds.size.width - 60*2 );
    
    CGRect centerRect1 = CGRectMake(60, [UIScreen mainScreen].bounds.size.height / 4.0 - sizeX / 2.0, sizeX, sizeX);
    UIBezierPath *centerPath1 = [UIBezierPath bezierPathWithRect:centerRect1];
    
    CGRect centerRect = CGRectMake(60, [UIScreen mainScreen].bounds.size.height / 4.0 * 3 - sizeX / 2.0, sizeX, sizeX);
    UIBezierPath *centerPath = [UIBezierPath bezierPathWithRect:centerRect];
    
    //create path
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.view.frame];
    [path appendPath:centerPath];
    [path appendPath:centerPath1];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    shapeLayer.fillRule = kCAFillRuleEvenOdd;
    shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
    //    shapeLayer.borderColor = [UIColor redColor].CGColor;
    //    shapeLayer.borderWidth = 10;
    self.scanPreviewView.layer.mask = shapeLayer;
    
    UILabel *botL = [[UILabel alloc] initWithFrame:CGRectMake(60, centerRect.origin.y + centerRect.size.height, [UIScreen mainScreen].bounds.size.width - 60*2, 30)];
    botL.numberOfLines = 0;
    botL.textAlignment = NSTextAlignmentCenter;
    botL.textColor = [UIColor redColor];
    botL.center = CGPointMake(self.view.frame.size.width / 2.0, botL.center.y);
    botL.text = @"scan face";
    
    [self.scanPreviewView addSubview:botL];
//
//    self.titleL = botL;
    
    // 边界校准线 1.线条绘制
    //    UIBezierPath *linePath = [UIBezierPath bezierPath];
    //    [linePath moveToPoint:CGPointMake(centerRect.origin.x, centerRect.origin.y + centerRect.size.width / 4.0)];
    //    [linePath addLineToPoint:CGPointMake(centerRect.origin.x, centerRect.origin.y)];
    //    [linePath addLineToPoint:CGPointMake(centerRect.origin.x + centerRect.size.width / 4.0, centerRect.origin.y)];
    //
    //    [linePath moveToPoint:CGPointMake(centerRect.origin.x + 3*centerRect.size.width / 4.0, centerRect.origin.y)];
    //    [linePath addLineToPoint:CGPointMake(centerRect.origin.x + centerRect.size.width, centerRect.origin.y)];
    //    [linePath addLineToPoint:CGPointMake(centerRect.origin.x + centerRect.size.width,centerRect.origin.y + centerRect.size.width / 4.0)];
    //
    //    [linePath moveToPoint:CGPointMake(centerRect.origin.x + centerRect.size.width, centerRect.origin.y + 3 * centerRect.size.width / 4.0)];
    //    [linePath addLineToPoint:CGPointMake(centerRect.origin.x + centerRect.size.width, centerRect.origin.y + centerRect.size.width)];
    //    [linePath addLineToPoint:CGPointMake(centerRect.origin.x + 3 * centerRect.size.width / 4.0, centerRect.origin.y + centerRect.size.width)];
    //
    //    [linePath moveToPoint:CGPointMake(centerRect.origin.x + centerRect.size.width / 4.0, centerRect.origin.y + centerRect.size.width)];
    //    [linePath addLineToPoint:CGPointMake(centerRect.origin.x, centerRect.origin.y + centerRect.size.width)];
    //    [linePath addLineToPoint:CGPointMake(centerRect.origin.x, centerRect.origin.y + 3 * centerRect.size.width / 4.0)];
    
    // 边界校准线 2.用矩形路径拼接
    const CGFloat lineWidth = 2;
    UIBezierPath *linePath = [UIBezierPath bezierPathWithRect:CGRectMake(centerRect.origin.x - lineWidth,
                                                                         centerRect.origin.y - lineWidth,
                                                                         centerRect.size.width / 4.0,
                                                                         lineWidth)];
    //        追加路径
    [linePath appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(centerRect.origin.x - lineWidth,
                                                                     centerRect.origin.y - lineWidth,
                                                                     lineWidth,
                                                                     centerRect.size.height / 4.0)]];
    
    [linePath appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(centerRect.origin.x + centerRect.size.width - centerRect.size.width / 4.0 + lineWidth,
                                                                     centerRect.origin.y - lineWidth,
                                                                     centerRect.size.width / 4.0,
                                                                     lineWidth)]];
    [linePath appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(centerRect.origin.x + centerRect.size.width ,
                                                                     centerRect.origin.y - lineWidth,
                                                                     lineWidth,
                                                                     centerRect.size.height / 4.0)]];
    
    [linePath appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(centerRect.origin.x - lineWidth,
                                                                     centerRect.origin.y + centerRect.size.width - centerRect.size.height / 4.0 + lineWidth,
                                                                     lineWidth,
                                                                     centerRect.size.height / 4.0)]];
    [linePath appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(centerRect.origin.x - lineWidth,
                                                                     centerRect.origin.y + centerRect.size.width,
                                                                     centerRect.size.width / 4.0,
                                                                     lineWidth)]];
    
    [linePath appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(centerRect.origin.x + centerRect.size.width,
                                                                     centerRect.origin.y + centerRect.size.width - centerRect.size.height / 4.0 + lineWidth,
                                                                     lineWidth,
                                                                     centerRect.size.height / 4.0)]];
    [linePath appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(centerRect.origin.x + centerRect.size.width - centerRect.size.width / 4.0 + lineWidth,
                                                                     centerRect.origin.y + centerRect.size.width,
                                                                     centerRect.size.width / 4.0,
                                                                     lineWidth)]];
    
    // 两种绘制边框方案 1.用线条 2.用矩形路径拼接
//        CAShapeLayer *layer = [CAShapeLayer  layer];
//        layer.frame = CGRectMake(40, 150, 250, 250);
//        layer.backgroundColor = [UIColor redColor].CGColor;
//
//        layer.path = linePath.CGPath;
//        layer.strokeColor = Color.CGColor;
//        layer.fillColor = [UIColor clearColor].CGColor;
//        layer.lineWidth = 2.0f;
//        layer.lineJoin = kCALineJoinMiter;
//        layer.lineCap = kCALineCapSquare;
    
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    pathLayer.path = linePath.CGPath;// 从贝塞尔曲线获取到形状
    pathLayer.fillColor = Color.CGColor; // 闭环填充的颜色
    //    pathLayer.lineCap     = kCALineCapSquare;
    //    pathLayer.lineJoin    = kCALineJoinMiter;
    //    pathLayer.strokeColor = Color.CGColor; // 边缘线的颜色
    //    pathLayer.lineWidth   = 2.0f;                           // 线条宽度
    [self.view.layer addSublayer:pathLayer];
    
    //        扫描条动画
//    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(centerRect.origin.x + 2,
//                                                                      centerRect.origin.y,
//                                                                      centerRect.size.width - 4,
//                                                                      2)];
//    line.image = [[UIImage imageNamed:@"line"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    line.tintColor = Color;
//    [self.view addSubview:line];
    
    // 上下游走动画
//    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
//    animation.fromValue = @0;
//    animation.toValue = [NSNumber numberWithFloat:centerRect.size.height];
//    animation.autoreverses = YES;
//    animation.duration = 3;
//    animation.repeatCount = FLT_MAX;
//    [line.layer addAnimation:animation forKey:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
