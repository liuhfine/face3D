//
// Created by sunny on 2018/2/7.
//

#ifndef PANORAMA_ANDROID_SYCERES_H
#define PANORAMA_ANDROID_SYCERES_H

#include "SYLoadObj.h"

typedef struct SYDelta
{
    double fp[36];  //  表情权重
//    double fp[48];
//    double fp[72];
    double ya[7];   //  偏航交
}cvv;

class SYCeres {

public:
    void ceresFun(struct SYDelta * sy_ceres, const float *points, SYLoadObj *objInfo);
};


#endif //PANORAMA_ANDROID_SYCERES_H
