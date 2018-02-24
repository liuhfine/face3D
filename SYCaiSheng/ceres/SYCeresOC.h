//
//  SYCeresOC.h
//  SYCaiSheng
//
//  Created by sunny on 2018/1/3.
//  Copyright © 2018年 hl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYCeresOC : NSObject

// pc 端精度均为 double
typedef struct SYCeres
{
    double fp[36];  //  表情权重
//    double fp[48];
//    double fp[72];
    double ya[7];   //  偏航交
}cvv;

+ (void)sy_ceresFun;


+ (void)ceresFun:(struct SYCeres *)sy_ceres featurePoints:(const float *)points objVert:(float *)objVert expression72:(struct SYMorphVert *)expVert;

@end
