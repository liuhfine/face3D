// Created with mtl2opengl.pl

/*
source files: ./jixiangwu.obj, ./out.mtl
materials: 6

Name: initialShadingGroup
Ka: 0.000, 0.000, 0.000
Kd: 1.000, 1.000, 1.000
Ks: 0, 0, 0
Ns: 1

Name: lambert5SG
Ka: 0.000, 0.000, 0.000
Kd: 0.000, 0.000, 0.000
Ks: 0, 0, 0
Ns: 1

Name: lambert7SG
Ka: 0.000, 0.000, 0.000
Kd: 1.000, 1.000, 1.000
Ks: 0, 0, 0
Ns: 1

Name: lambert12SG
Ka: 0.000, 0.000, 0.000
Kd: 0.000, 0.000, 0.000
Ks: 0, 0, 0
Ns: 1

Name: lambert13SG
Ka: 0.000, 0.000, 0.000
Kd: 0.000, 0.000, 0.000
Ks: 0, 0, 0
Ns: 1

Name: lambert14SG
Ka: 0.000, 0.000, 0.000
Kd: 0.000, 0.000, 0.000
Ks: 0, 0, 0
Ns: 1

*/


int outMTLNumMaterials = 5;

int outMTLFirst [5] = {
    0,
    576,
    1728,
    63906,
    67902,
};

int outMTLCount [5] = {
    576,
    1152,
    62178,
    3996,
};

//int outMTLNumMaterials = 6;

//int outMTLFirst [6] = {
//0,
//576,
//1728,
//1728,
//63906,
//63906,
//};
//
//int outMTLCount [6] = {
//576,
//1152,
//0,
//62178,
//0,
//3996,
//};

float outMTLAmbient [6][3] = {
0.000,0.000,0.000,
0.000,0.000,0.000,
0.000,0.000,0.000,
0.000,0.000,0.000,
0.000,0.000,0.000,
0.000,0.000,0.000,
};

float outMTLDiffuse [6][3] = {
1.000,1.000,1.000,
0.000,0.000,0.000,
1.000,1.000,1.000,
0.000,0.000,0.000,
0.000,0.000,0.000,
0.000,0.000,0.000,
};

float outMTLSpecular [6][3] = {
0,0,0,
0,0,0,
0,0,0,
0,0,0,
0,0,0,
0,0,0,
};

float outMTLExponent [6] = {
1,
1,
1,
1,
1,
1,
};

