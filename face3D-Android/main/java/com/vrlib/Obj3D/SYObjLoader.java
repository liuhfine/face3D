package com.vrlib.Obj3D;

import android.content.Context;
import android.util.Log;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.Buffer;
import java.util.ArrayList;
import java.util.Vector;

/**
 * Created by sunny on 2017/12/6.
 */

public class SYObjLoader {

    public final int numFaces;

    public final float[] normals;
    public final float[] textureCoordinates;
    public final float[] positions;
    public final short[] indexs;

    private ArrayList<float[][]> morphMV;   // 表情库
    private ArrayList<float[][]> morphMN;   // 纹理坐标
    private int expression_num;

    public final int usemtls;
//    public final float[] positionCount;
    public final float[] positionIndex;

    private static final String TAG = "SYObjLoader";

    public SYObjLoader(Context context, String file) {

        Vector<Float> vertices = new Vector<>();
        Vector<Float> normals = new Vector<>();
        Vector<Float> textures = new Vector<>();
        Vector<String> faces = new Vector<>();

        BufferedReader reader = null;
        int usemtl = 0; // 材质累加
        Vector<Float> positionsIndex = new Vector<>();

        try {
            InputStreamReader in = new InputStreamReader(context.getAssets().open(file));
            reader = new BufferedReader(in);

            // read file until EOF
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split("\\s+");

                switch (parts[0]) {
                    case "v":
                        // vertices
                        vertices.add(Float.valueOf(parts[1]));
                        vertices.add(Float.valueOf(parts[2]));
                        vertices.add(Float.valueOf(parts[3]));
                        break;
                    case "vt":
                        // textures
                        textures.add(Float.valueOf(parts[1]));
                        textures.add(1 - Float.valueOf(parts[2])); // vt.y = -vt.y  对y轴翻转
                        break;
                    case "vn":
                        // normals
                        normals.add(Float.valueOf(parts[1]));
                        normals.add(Float.valueOf(parts[2]));
                        normals.add(Float.valueOf(parts[3]));
                        break;
                    case "f":
                        // faces: vertex/texture/normal

                        faces.add(parts[1]);
                        faces.add(parts[2]);
                        faces.add(parts[3]);

                        if (parts.length > 4) // 矩形
                        {
                            faces.add(parts[1]);
                            faces.add(parts[3]);
                            faces.add(parts[4]);
                        }

                        break;
                    case "usemtl":
                        usemtl += 1;
                        positionsIndex.add((float)faces.size());
                        break;
                }
            }

        } catch (IOException e) {
            // cannot load or read file
        } finally {

            if (reader != null) {
                try {
                    reader.close();
                } catch (IOException e) {
                    //log the exception
                }
            }
        }

        usemtls = usemtl;
        numFaces = faces.size();

        // 计算每个材质的绘制下标
        positionsIndex.add((float)faces.size());
        positionIndex = new float[usemtls + 1];

        for (int i=0;i<positionIndex.length;i++)
        {
            positionIndex[i] = positionsIndex.get(i);
        }

        positions = new float[vertices.size()];
        this.normals = new float[normals.size()];
        textureCoordinates = new float[textures.size()];
        indexs = new short[faces.size()];

        int positionIndex = 0;
        int normalIndex = 0;
        int textureIndex = 0;

        for (int i=0;i<vertices.size();i++)
        {
            positions[i] = vertices.get(i);
            this.normals[i] = normals.get(i);

            if (i < textures.size())
                textureCoordinates[i] = textures.get(i);
        }

        for (String face : faces) {
            String[] parts = face.split("/");

            indexs[positionIndex] = (short) (Short.valueOf(parts[0]) - 1);

            positionIndex++;

//            int index = 3 * (Short.valueOf(parts[0]) - 1);
//            positions[positionIndex++] = vertices.get(index++);
//            positions[positionIndex++] = vertices.get(index++);
//            positions[positionIndex++] = vertices.get(index);

//            index = 2 * (Short.valueOf(parts[1]) - 1);
//            textureCoordinates[normalIndex++] = textures.get(index++);
//            // NOTE: Bitmap gets y-inverted
//            textureCoordinates[normalIndex++] = 1 - textures.get(index);
//
//            index = 3 * (Short.valueOf(parts[2]) - 1);
//            this.normals[textureIndex++] = normals.get(index++);
//            this.normals[textureIndex++] = normals.get(index++);
//            this.normals[textureIndex++] = normals.get(index);
        }


    }

    public void reloadExpression(Context context, String filePath, int expression_num)
    {

        if (this.positions.length < 1)
            return;

        this.expression_num = expression_num;

        BufferedReader reader = null;

        try {
            InputStreamReader in = new InputStreamReader(context.getAssets().open(filePath));
            reader = new BufferedReader(in);

            // read file until EOF
            String line;
            int index = 0;
            int index1 = 0;

            if (morphMV == null)
                morphMV = new ArrayList<>(this.positions.length / 3);

            float arrayW[][] = null;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split("\\s+");

                if (index % expression_num == 0)
                {
                    arrayW = new float[36][3];
                }

                if (index < expression_num)
                {
                    arrayW[index][0] = Float.valueOf(parts[0]).floatValue();
                    arrayW[index][1] = Float.valueOf(parts[1]).floatValue();
                    arrayW[index][2] = Float.valueOf(parts[2]).floatValue();
                }

                if (index == expression_num - 1)
                {
                    morphMV.add(arrayW);
                    index = -1;
                    index1 ++;
                }

                index++;
            }

//                Log.e("HL", "reloadExpression: "+ index1 + " --- "
//                            + morphMV.get(1)[2][0] + " "
//                            + morphMV.get(1)[2][1] + " "
//                            + morphMV.get(1)[2][2]);
//
//            Log.e(TAG, "reloadExpression: " + morphMV.size());


        }
        catch (Exception e)
        {
            e.printStackTrace();
        }finally {

            if (reader != null) {
                try {
                    reader.close();
                } catch (IOException e) {
                    //log the exception
                }
            }
        }
    }

    public float[] getVertices() {
        return this.positions;
    }

    public float[] getNormals() {
        return this.normals;
    }

    public float[] getTextureCoordinates() {
        return this.textureCoordinates;
    }

    public short[] getIndices() {
        return this.indexs;
    }

    public ArrayList<float[][]> getMorphMV() {
        return this.morphMV;
    }

    public int getVertexNum() {
        return this.positions.length / 3;
    }

    public int getExpressionNum() {
        return this.expression_num;
    }
}
