//
//  InputMaterialTextureConfig.cs
//  AiferuFramework
//
//  Created by Aiferu on 2023/2/7.
//
//
#if UNITY_EDITOR
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
namespace AiferuFramework.ArtBrushTool
{
    /// <summary>
    /// �洢����ˢ�ݹ��ߵĳ־û�����
    /// </summary>
    [CreateAssetMenu(fileName = "ArtBrushToolData", menuName = "cs",order = 7)]
    public class ArtBrushToolData : ScriptableObject
    {
        //��Ҫ�洢������
        //1.BrushSize ��ˢ��С
        public int BrushSize;
        //2.ScaleRandom �ݶ��������С��Χ
        public float ScaleRandomMax;
        public float ScaleRandomMin;
        //3.Density ���ܶ�
        public int Density;
        //4.Plant��������
        public GameObject[] Plants;
        //5.����������Ӷ������
        public int PlantCount;
    }
}
#endif