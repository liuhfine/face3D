//
// Created by sunny on 2018/2/7.
//

#include "SYCeres.h"
#include "ceres/ceres.h"
#include "glog/logging.h"
#include "ceres/rotation.h"

using ceres::AutoDiffCostFunction;
using ceres::CostFunction;
using ceres::Problem;
using ceres::Solver;
using ceres::Solve;


int expressions_num;
double morphWeight[36];
double Transform[7] = { 0,0,0,0,0,0,1 };
SYLoadObj *_objInfo;

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
        _ov = _objInfo->getObjModelData()->vertexs + (mapping_index[pointnum] - 1) * 3;
        _vv = _objInfo->getExpressionModelData() + mapping_index[pointnum] - 1;

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
void SYCeres::ceresFun(struct SYDelta * sy_ceres, const float *points, SYLoadObj *objInfo)
{
    if (!sy_ceres || !points)
        return;

    if (!isFirst) {

        memset(sy_ceres->fp, 0, sizeof(sy_ceres->fp));
        isFirst = true;
    }

    _objInfo = objInfo;

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

    sy_ceres->ya[0] = Transform[0];
    sy_ceres->ya[1] = Transform[1];
    sy_ceres->ya[2] = Transform[2];
}
