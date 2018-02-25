package com.vrlib.Obj3D;

import java.nio.FloatBuffer;

/**
 * Created by sunny on 2017/11/15.
 */

public class Model3D {

    public int numFaces;

    private short[] indices;             // 顶点索引
    private float[] positions;           // 顶点位置
    private float[] normals;             // 法向量
    private float[] textureCoordinates;  // 纹理坐标


    private float[] morphMV;             // 表情库
    private float[] morphMN;             // 纹理坐标
    private int[][] arrayOfIntegers = new int[36][3];

    private float[] drawIndex = null;

    public Model3D(
            float[] vertices,
            float[] normals,
            float[] textureCoordinates,
            short[] indices)
    {
        this.positions = vertices;
        this.normals = normals;
        this.textureCoordinates = textureCoordinates;
        this.indices = indices;

        numFaces = indices.length;
    }

    public float[] getVertices() {
        return positions;
    }

    public float[] getNormals() {
        return normals;
    }

    public float[] getTextureCoordinates() {
        return textureCoordinates;
    }

    public short[] getIndices() {
        return indices;
    }


}
