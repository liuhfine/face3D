//
//  SY3DObjView.h
//  SYCaiSheng
//
//  Created by sunny on 2017/11/27.
//  Copyright © 2017年 hl. All rights reserved.
//


#import <UIKit/UIKit.h>
#include "SYLoadObj.h"

@interface SY3DObjView : UIView

- (id)initWithFrame:(CGRect)frame;

//- (void)loadVertexForVBO:(float *)vertexs :(float *)normals :(float *)colors :(short *)indexs;

/**
 load obj data with

 @param objInfo obj data
 */
- (void)loadVertexForVBO:(struct SYObjInfo *)objInfo;

/**
 姿态

 @param scale vvvv
 @param pitch 俯仰
 @param roll 滚转
 @param yaw 眉心沿Y轴的偏航角
 */
- (void)drawModelWithScale:(CGFloat)scale :(CGFloat)pitch :(CGFloat)roll :(CGFloat)yaw;


/**
 表情

 @param objInfo 新模型数据
 */
- (void)updateExpressionWithVBO:(struct SYObjInfo *)objInfo;

//- (void)updateExpressionWithVBO:(const float *)vertexs;

@end

