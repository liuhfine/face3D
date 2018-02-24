//
//  SYCeresOC.m
//  SYCaiSheng
//
//  Created by sunny on 2018/1/3.
//  Copyright © 2018年 hl. All rights reserved.
//

#import "SYCeresOC.h"
#include "SYLoadObj.h"

#include "ceres/ceres.h"
#include "glog/logging.h"
#include "ceres/rotation.h"


using ceres::AutoDiffCostFunction;
using ceres::CostFunction;
using ceres::Problem;
using ceres::Solver;
using ceres::Solve;

using namespace std;

struct SYMorphVert *_morphVert1;
float *_objVert;

//typedef struct _morph_vert
//{
//    //float u[3];
//    float n[3];
//    float t[2];
//    float v[3];
//    float mv[72][3];    // morph target 0 vertex
//    float mn[72][3];
//}morph_vert;
//
//typedef struct _obj_vert
//{
//    float u[3];
//    float n[3];
//    float t[2];
//    float v[3];
//}obj_vert;

int expressions_num;
double morphWeight[36];
double Transform[7] = { 0,0,0,0,0,0,1 };

bool isceresed = false;

@implementation SYCeresOC

struct MorphableModel_Error {
    
    MorphableModel_Error(double observed_x, double observed_y, int pointnum)
    : observed_x(observed_x), observed_y(observed_y), pointnum(pointnum) {}
    
    template <typename T>
    bool operator()(const T* const weight, const T* const Transform, T* residuals) const
    {
        T p[3];
        struct SYMorphVert* _vv = nullptr;
        float *_ov = nullptr;
//        struct _obj_vert *_ov = nullptr;

        // 模型顶点数组 特征点的偏移量
        _ov = _objVert + (mapping_index[pointnum] - 1) * 3;
        _vv = _morphVert1 + mapping_index[pointnum] - 1;

//        for (int i = 0; i < 3; i++)
//        {
//            for (int j = 0; j < 72; j++)
//            {
//                std::cout << " _vv-----------> " << _vv->mv[j][0] << " " << _vv->mv[j][1] << " " << _vv->mv[j][2] << std::endl;
//            }
//
//            std::cout << " _ov-----------> " << _ov[3*i] << " " << _ov[3*i+1] << " " << _ov[3*i+2] << std::endl;
//        }

        p[0] = T(_ov[0]);
        p[1] = T(_ov[1]);
        p[2] = T(_ov[2]);

        for (int i = 0; i < 3; i++)
        {
            for (int j = 0; j < 36; j++)
            {
                p[i] = p[i] + weight[j] * T(_vv->mv[j][i]);
            }
        }

        T p_after[3];
        ceres::AngleAxisRotatePoint(Transform, p, p_after);
        p_after[0] = Transform[6] * p_after[0] + Transform[3];
        p_after[1] = Transform[6] * p_after[1] + Transform[4];
        p_after[2] = Transform[6] * p_after[2] + Transform[5];

        p_after[0] = p_after[0] * T(1026.15297811787) / p_after[2] + T(325.660438578019);
        p_after[1] = p_after[1] * T(1025.25738432616) / p_after[2] + T(219.702666996884);
//        // The error is the difference between the predicted and observed position.
////        T constraint = T(0);
//        /*for (int i = 0; i < 12; i++)
//         {
//         constraint = constraint + weight[i] * weight[i];
//         }*/
//
        residuals[0] = (p_after[0] - T(observed_x));
        residuals[1] = (p_after[1] - T(observed_y));

        for (int i = 2; i < 2 + 36; i++)
        {
            residuals[i] = T(3)*weight[i - 2];
        }
        
        return true;
    }
    
    static ceres::CostFunction* Create(const double observed_x,
                                       const double observed_y, const int pointnum)
    {
        return (new ceres::AutoDiffCostFunction<MorphableModel_Error, 37, 36, 7>(
            new MorphableModel_Error(observed_x, observed_y, pointnum)));
    }
    
    double observed_x;
    double observed_y;
    int pointnum;
    int mapping_index[66] = { -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1,-1, -1, -1, -1, -1, -1,
        5444,
        4767,
        2866,
        3383,
        384,
        1536,
        5097,
        4923,
        332,
        972,
        5088,
        4861,
        1942,
        5074,
        2784,
        712,
        5072,
        743,
        1953,
        2948,
        2910,
        2921,
        3717,
        3707,
        2993,
        4595,
        1042,
        1032,
        345,
        1113,
        5170,
        4474,
        440,
        437,
        1519,
        1676,
        4545,
        54,
        60,
        1245,
        1247,
        3138,
        3108,
        3058,
        1514,
        1178,
        1229,
        1225,
        3098
    };
};

bool isFirst = false;
+ (void)ceresFun:(struct SYCeres *)sy_ceres featurePoints:(const float *)points objVert:(float *)objVert expression72:(struct SYMorphVert *)expVert
{
    if (!sy_ceres || !points || !objVert || !expVert)
        return;
    
    _objVert = objVert; // 模型顶点数组
    _morphVert1 = expVert;
    
    if (!isFirst) {
//        expressions_num = 36;
        
        memset(sy_ceres->fp, 0, sizeof(sy_ceres->fp));
        
        isFirst = true;
    }
    
    ceres::Problem problem;
    for (int i = 17; i < 66; i++)
    {
        ceres::CostFunction* cost_function_up =
        
        MorphableModel_Error::Create(points[2*i], points[2*i + 1], i);
        
        problem.AddResidualBlock(cost_function_up,
                                 NULL,//  
                                 sy_ceres->fp, Transform);
    }
    
    ceres::Solver::Options options;
    options.linear_solver_type = ceres::DENSE_NORMAL_CHOLESKY;
    options.minimizer_progress_to_stdout = false;
    options.max_num_iterations = 10;
    
    ceres::Solver::Summary summary;
    ceres::Solve(options, &problem, &summary);
//    std::cout << summary.BriefReport() << "\n";
//    isceresed = true;
    
    // x,y,z 轴的偏航角
//    cout << " -------------> " << sy_ceres->fp[0] << " rull: " << sy_ceres->fp[1] << " raw：" << Transform[2] << endl;

    sy_ceres->ya[0] = Transform[0];
    sy_ceres->ya[1] = Transform[1];
    sy_ceres->ya[2] = Transform[2];
};

//struct CostFunctor {
//    template <typename T> bool operator()(const T* const x, T* residual) const {
//        residual[0] = 10.0 - x[0];
//        return true;
//    }
//};

//// 用于拟合曲线的点数量
//const int kNumObservations = 3;
//const double data[] = {
//    0.000000e+00, 1.133898e+00, //第1个点
//    7.500000e-02, 1.334902e+00, //第2个点
//    //..., 这里省略64个点
//    4.950000e+00, 4.669206e+00, //第67个点
//};
//
//// 构建CostFunction结构体
//struct ExponentialResidual {
//    // 输入一对坐标x,y
//    ExponentialResidual(double x, double y)
//    : x_(x), y_(y) {}
//    // 函数y = e^{mx + c}.
//    // 残差为 y_ - y
//    template <typename T> bool operator()(const T* const m,
//                                          const T* const c,
//                                          T* residual) const {
//        residual[0] = T(y_) - exp(m[0] * T(x_) + c[0]);
//        return true;
//    }
//
//private:
//    const double x_;
//    const double y_;
//};

+ (void)sy_ceresFun
{
//    google::InitGoogleLogging(0);
//
//    // m c 初始值
//    double m = 0.0;
//    double c = 0.0;
//
//    // 2.建立
//    Problem problem;
//    for (int i=0; i < kNumObservations; ++i) {
//        problem.AddResidualBlock(
//                                 // CostFunction为ExponentialResidual，
//                                 // 残差个数为1，参数1(x)维度为1，参数2(y)维度为1，
//                                 // 损失函数为CauchyLoss(0.5)
//                                 new AutoDiffCostFunction<ExponentialResidual, 1, 1, 1>(
//                                                                                        new ExponentialResidual(data[2 * i], data[2 * i + 1])),
//                                 new ceres::CauchyLoss(0.5),
//                                 &m, &c);
//    }
//
//    // 3.声明解算器，控制器
//    Solver::Options options;
//    options.max_num_iterations = 25;
//    options.linear_solver_type = ceres::DENSE_QR;
//    options.minimizer_progress_to_stdout = true;
//
//    // 4.结算过程报告输出
//    Solver::Summary summary;
//    Solve(options, &problem, &summary);
//    std::cout << summary.BriefReport() << "\n";
//    std::cout << "Initial m: " << 0.0 << " c: " << 0.0 << "\n";
//    std::cout << "Final   m: " << m << " c: " << c << "\n";

};

@end
